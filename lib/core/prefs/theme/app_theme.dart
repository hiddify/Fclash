import 'package:clashify/core/prefs/theme/theme_prefs.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

extension AppTheme on ThemePrefs {
  static final schemeColor = FlexSchemeColor.from(
    primary: const Color.fromRGBO(66, 100, 225, 1),
  );

  ThemeData get light {
    return FlexThemeData.light(
      colors: schemeColor,
      appBarStyle: FlexAppBarStyle.primary,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
    );
  }

  ThemeData get dark {
    return FlexThemeData.dark(
      colors: schemeColor.toDark(),
      appBarStyle: FlexAppBarStyle.primary,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
      darkIsTrueBlack: darkIsBlack,
    );
  }
}
