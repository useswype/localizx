import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

import 'annotation_generator.dart';
import 'annotations/localize_keys_options.dart';
import 'keys_class_generator.dart';
import 'localized_item.dart';
import 'string_casing.dart';

class LocalizxGen extends AnnotationGenerator<LocalizeKeysOptions> {
  static List<String> reservedKeys = const ["0", "1", "else"];

  const LocalizxGen();

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    validateClass(element);

    var className = element.name;
    validateClassName(className);

    final options = parseOptions(annotation);

    List<LocalizedItem> translations;

    try {
      translations = await getKeyMap(buildStep, options);
    } on FormatException catch (_) {
      throw InvalidGenerationSourceError("Ths JSON format is invalid.");
    }

    final file = Library((lb) => lb
      ..body.addAll([
        KeysClassGenerator.generateClass(options, translations, className!)
      ]));

    final DartEmitter emitter = DartEmitter(allocator: Allocator.none);

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format('${file.accept(emitter)}');
  }

  LocalizeKeysOptions parseOptions(ConstantReader annotation) {
    return LocalizeKeysOptions(
      path: annotation.peek("path")!.stringValue,
    );
  }

  Future<List<LocalizedItem>> getKeyMap(
    BuildStep step,
    LocalizeKeysOptions options,
  ) async {
    // Use a thread-safe-ish structure (Dart is single threaded, so this is safe)
    final mapping = <String, List<String>>{};

    // 1. Find assets
    final assets = await step
        .findAssets(Glob(
          options.path,
          recursive: true,
        ))
        .toList();

    // 2. Parallel Processing
    // We map every asset to a Future and run them all at once.
    await Future.wait(assets.map((entity) async {
      final content = await step.readAsString(entity);
      final Map<String, dynamic> jsonMap = json.decode(content);

      // 3. Optimized Recursive Parser
      // We pass the global 'mapping' or a temporary accumulator directly.
      fillTranslationMap(jsonMap, mapping);
    }));

    // 4. Convert to Output List
    return mapping.entries.map((e) {
      return LocalizedItem(
        e.key,
        e.value,
        Casing.camelCase(e.key),
      );
    }).toList();
  }

  /// Optimized helper: Returns void, modifies the accumulator directly.
  void fillTranslationMap(
    Map<String, dynamic> jsonNode,
    Map<String, List<String>> accumulator, [
    String? parentKey,
  ]) {
    for (var entry in jsonNode.entries) {
      final keyStr = entry.key;

      // Calculate the new key
      String currentKey;
      if (LocalizxGen.reservedKeys.contains(keyStr)) {
        currentKey = parentKey ?? keyStr;
      } else {
        currentKey = parentKey != null ? "$parentKey.$keyStr" : keyStr;
      }

      final value = entry.value;

      if (value is String) {
        // Direct insertion.
        // utilizing putIfAbsent is slightly slower than direct check if you want max speed,
        // but this logic maintains your list accumulation requirement.
        (accumulator[currentKey] ??= []).add(value);
      } else if (value is Map<String, dynamic>) {
        // RECURSION: Pass the existing accumulator down. No copying!
        fillTranslationMap(value, accumulator, currentKey);
      }
    }
  }

  Map<String, String> getTranslationMap(
    Map<String, dynamic> jsonMap, {
    String? parentKey,
  }) {
    final map = <String, String>{};

    for (var entry in jsonMap.keys) {
      String? key;

      if (reservedKeys.contains(entry)) {
        key = parentKey;
      } else {
        key = parentKey != null ? "$parentKey.$entry" : entry;
      }

      if (key == null) continue;

      var value = jsonMap[entry];

      if (value is String) {
        map.putIfAbsent(key, () => value);
      } else {
        var entries = getTranslationMap(value, parentKey: key);

        map.addAll(entries);
      }
    }

    return map;
  }

  void validateClassName(String? className) {
    if (className == null ||
        className.isEmpty ||
        !className.startsWith("_\$")) {
      throw InvalidGenerationSourceError(
          "The annotated class name (currently '$className') must start with _\$. For example _\$Keys or _\$LocalizationKeys");
    }
  }

  void validateClass(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          "The annotated element is not a Class! LocalizeKeysOptions should be used on Classes.",
          element: element);
    }
  }
}
