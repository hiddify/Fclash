import 'package:fclash/features/connections/notifier/notifier.dart';
import 'package:fclash/features/connections/widgets/widgets.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConnectionsPage extends HookConsumerWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ConnectionsNotifier.provider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DesktopAppBar(
            child: ConnectionsAppBar(
              upload: state.connection.totalUpload,
              download: state.connection.totalDownload,
              onCloseAllConnections: () async {
                await ref
                    .read(ConnectionsNotifier.provider.notifier)
                    .closeAll();
              },
            ),
          ),
          // SliverList(
          //   delegate: SliverChildBuilderDelegate(
          //     (context, index) {
          //       final connection = state.connection.
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
