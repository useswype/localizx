import 'package:flutter/widgets.dart';

import 'localization_provider.dart';
import 'localized_app.dart';

class LocalizedAppState extends State<LocalizedApp> {
  void onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) =>
      LocalizationProvider(state: this, child: widget.child);
}
