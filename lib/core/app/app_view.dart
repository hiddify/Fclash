import 'package:fclash/core/prefs/locale/locale.dart';
import 'package:fclash/core/prefs/theme/theme.dart';
import 'package:fclash/core/router/router.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppView extends HookConsumerWidget with PresLogger {
  const AppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(AppRouter.provider);
    final locale = ref.watch(LocaleController.provider).locale;
    final theme = ref.watch(ThemeController.provider);

    return MaterialApp.router(
      routerConfig: router.config,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocale.locales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: theme.themeMode,
      theme: theme.light,
      darkTheme: theme.dark,
      title: 'Clashify',
    );
  }
}
