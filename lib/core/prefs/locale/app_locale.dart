import 'package:dartx/dartx.dart';
import 'package:fclash/gen/translations.g.dart';
import 'package:flutter/widgets.dart';

export 'package:fclash/gen/translations.g.dart' hide AppLocale;

enum AppLocale {
  en;

  Locale get locale {
    return Locale(name);
  }

  static List<Locale> get locales =>
      AppLocale.values.map((e) => e.locale).toList();

  static AppLocale fromString(String e) {
    return AppLocale.values.firstOrNullWhere((element) => element.name == e) ??
        AppLocale.en;
  }

  static AppLocale deviceLocale() {
    return AppLocale.fromString(
      AppLocaleUtils.findDeviceLocale().languageCode,
    );
  }

  TranslationsEn translations() {
    final appLocale = AppLocaleUtils.parse(name);
    return appLocale.build();
  }
}
