import 'package:flutter/widgets.dart';
import 'package:localizx/localizx.dart';

class LocalizationProvider extends InheritedWidget {
  final LocalizedAppState state;

  const LocalizationProvider({
    super.key,
    required super.child,
    required this.state,
  });

  static LocalizationProvider of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<LocalizationProvider>())!;

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) => true;
}
