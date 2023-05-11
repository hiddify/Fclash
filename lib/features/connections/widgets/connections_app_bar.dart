import 'package:fclash/core/core_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ConnectionsAppBar extends HookConsumerWidget {
  const ConnectionsAppBar({
    super.key,
    required this.upload,
    required this.download,
    required this.onCloseAllConnections,
  });

  final double upload;
  final double download;
  final VoidCallback onCloseAllConnections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final themeData = Theme.of(context);

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              text: "${t.connections.total.titleCase}: ",
              children: [
                TextSpan(text: "↑ ${formatByteSize(upload)}"),
                const TextSpan(text: ' | '),
                TextSpan(text: "↓ ${formatByteSize(download)}"),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: onCloseAllConnections,
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                themeData.colorScheme.error,
              ),
              foregroundColor:
                  MaterialStatePropertyAll(themeData.colorScheme.onError),
            ),
            child: Text(t.connections.closeAll.titleCase),
          ),
        ],
      ),
    );
  }
}
