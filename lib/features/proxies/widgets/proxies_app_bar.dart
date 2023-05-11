import 'package:fclash/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ProxiesAppBar extends HookConsumerWidget {
  const ProxiesAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...RouterMode.values.map(
            (e) => RawChip(
              label: Text(e.name.titleCase),
              onPressed: () {},
              labelStyle: Theme.of(context).textTheme.titleLarge,
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }
}
