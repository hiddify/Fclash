import 'package:clashify/core/prefs/theme/theme_prefs.dart';
import 'package:clashify/data/data_providers.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeController extends Notifier<ThemePrefs> with AppLogger {
  static final provider =
      NotifierProvider<ThemeController, ThemePrefs>(ThemeController.new);

  @override
  ThemePrefs build() {
    return const ThemePrefs();
  }

  Preferences get _prefs => ref.read(Data.preferences);

  Future<void> init() async {
    loggy.debug('initializing');
    state = state.copyWith(
      themeMode: ThemeMode.values[_prefs.getInt("theme_mode", 0)],
      darkIsBlack: _prefs.getBool('dark_is_black', false),
    );
  }

  Future<void> change({
    ThemeMode? themeMode,
    bool? darkIsBlack,
  }) async {
    loggy.debug('changing theme: mode=$themeMode, darkIsBlack=$darkIsBlack');
    if (themeMode != null) {
      _prefs.setInt('theme_mode', themeMode.index);
    }
    if (darkIsBlack != null) {
      _prefs.setBool('dark_is_black', darkIsBlack);
    }
    state = state.copyWith(
      themeMode: themeMode ?? state.themeMode,
      darkIsBlack: darkIsBlack ?? state.darkIsBlack,
    );
  }
}
