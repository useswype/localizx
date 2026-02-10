import 'dart:ui';

abstract class ILocalizePreferences {
  Future savePreferredLocale(Locale locale);

  Future<Locale?> getPreferredLocale();
}
