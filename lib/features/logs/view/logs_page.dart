import 'package:clashify/core/core_providers.dart';
import 'package:clashify/features/logs/notifier/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class LogsPage extends HookConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final state = ref.watch(LogsNotifier.provider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(t.logs.pageTitle.titleCase),
            pinned: true,
          ),
          SliverList.builder(
            itemBuilder: (context, index) {
              final log = state.logs[index];
              return ListTile(
                title: Text(log.message),
              );
            },
            itemCount: state.logs.length,
          ),
        ],
      ),
    );
  }
}
