import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'localizx_gen.dart';

Builder localizxKeysBuilder(BuilderOptions options) {
  return SharedPartBuilder([LocalizxGen()], 'static_keys_generator');
}
