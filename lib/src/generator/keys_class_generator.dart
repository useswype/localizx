import 'package:code_builder/code_builder.dart';

import 'annotations/localize_keys_options.dart';
import 'localized_item.dart';

class KeysClassGenerator {
  static Reference get stringType =>
      TypeReference((trb) => trb..symbol = "String");

  static Class generateClass(LocalizeKeysOptions options,
      List<LocalizedItem> items, String className) {
    return Class(
      (x) => x
        ..name = className.substring(2)
        ..fields.addAll(items
            .map((translation) => generateField(translation, options))
            .toList()),
    );
  }

  static Field generateField(LocalizedItem item, LocalizeKeysOptions options) {
    return Field(
      (x) => x
        ..name = item.fieldName
        ..type = stringType
        ..static = true
        ..modifier = FieldModifier.constant
        ..assignment = literalString(item.key).code,
    );
  }
}
