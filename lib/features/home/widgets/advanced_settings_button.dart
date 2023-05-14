import 'package:clashify/core/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class AdvancedSettingsButton extends HookConsumerWidget {
  const AdvancedSettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: InkWell(
          onTap: () {
            // TODO: show bottom sheet
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.settings),
                const SizedBox(width: 16),
                Text(
                  t.home.advanced.titleCase,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
