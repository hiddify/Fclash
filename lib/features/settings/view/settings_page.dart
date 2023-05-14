import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/prefs/theme/theme.dart';
import 'package:clashify/features/settings/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);

    final theme = ref.watch(ThemeController.provider);
    final themeController = ref.watch(ThemeController.provider.notifier);
    // final clashOverrides = ref.watch(Facade.clash);
    // final clashController = ref.watch(Facade.clash);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.general.settings.titleCase),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(t.settings.appearance.titleCase),
          ),
          ListTile(
            title: Text(t.settings.themeMode.titleCase),
            trailing: ThemeModeSwitch(
              themeMode: theme.themeMode,
              onChanged: (value) {
                themeController.change(themeMode: value);
              },
            ),
            onTap: () {
              if (Theme.of(context).brightness == Brightness.light) {
                themeController.change(themeMode: ThemeMode.dark);
              } else {
                themeController.change(themeMode: ThemeMode.light);
              }
            },
          ),
          SwitchListTile(
            title: Text(t.settings.darkIsBlack.titleCase),
            value: theme.darkIsBlack,
            onChanged: (value) {
              themeController.change(darkIsBlack: value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(t.settings.proxy.titleCase),
          ),
          // ListTile(
          //   title: Text(t.settings.httpPort),
          //   trailing: Text(clashOverrides.overrides.httpPort.toString()),
          //   onTap: () {
          //     SettingsInputDialog<int>(
          //       title: t.settings.httpPort,
          //       initialValue: clashOverrides.overrides.httpPort,
          //       onConfirm: (value) async {
          //         final input = int.tryParse(value);
          //         if (input == null) return;
          //         await clashController.changeOverrides(httpPort: some(input));
          //       },
          //     ).show(context);
          //   },
          // ),
        ],
      ),
    );
  }
}
