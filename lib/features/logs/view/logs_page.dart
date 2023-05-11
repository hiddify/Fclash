import 'package:fclash/features/logs/notifier/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogsPage extends HookConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(LogsNotifier.provider);

    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          final clashLog = state.logs[index];
          return ListTile(
            title: Text(clashLog.message),
            subtitle: Text(clashLog.time.toIso8601String()),
            leading: Text(clashLog.level.name),
          );
        },
        itemCount: state.logs.length,
      ),
    );
  }
}
