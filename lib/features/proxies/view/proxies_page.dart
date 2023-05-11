import 'package:fclash/core/clash/clash.dart';
import 'package:fclash/features/proxies/notifier/notifier.dart';
import 'package:fclash/features/proxies/widgets/widgets.dart';
import 'package:fclash/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxiesPage extends HookConsumerWidget with PresLogger {
  const ProxiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ProxiesNotifier.provider);
    final isSystemProxy = ref
        .watch(ClashController.provider.select((value) => value.isSystemProxy));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const DesktopAppBar(child: ProxiesAppBar()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final selector = state.selectors[index];
                return ProxySelector(selector, null);
              },
              childCount: state.selectors.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isSystemProxy) {
            await ref
                .read(ClashController.provider.notifier)
                .clearSystemProxy();
          } else {
            await ref.read(ClashController.provider.notifier).setSystemProxy();
          }
        },
        child:
            isSystemProxy ? const Icon(Icons.wifi_off) : const Icon(Icons.wifi),
      ),
    );
  }
}
