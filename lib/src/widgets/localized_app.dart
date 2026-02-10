import 'package:flutter/widgets.dart';
import 'package:localizx/localizx.dart';

class LocalizedApp extends StatefulWidget {
  final Widget child;

  final LocalizationDelegate delegate;

  const LocalizedApp(
    this.delegate,
    this.child, {
    super.key,
  });

  @override
  LocalizedAppState createState() => LocalizedAppState();

  static LocalizedApp of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<LocalizedApp>()!;
}
