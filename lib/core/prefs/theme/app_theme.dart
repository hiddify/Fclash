import 'package:fclash/core/prefs/theme/theme_prefs.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

extension AppTheme on ThemePrefs {
  ThemeData get light {
    return FlexThemeData.light(
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
    );
  }

  ThemeData get dark {
    return FlexThemeData.dark(
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
      darkIsTrueBlack: darkIsBlack,
    );
  }
}
