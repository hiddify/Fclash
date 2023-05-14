import 'package:clashify/features/proxies/notifier/notifier.dart';
import 'package:clashify/features/proxies/widgets/widgets.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxiesPage extends HookConsumerWidget with PresLogger {
  const ProxiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ProxiesNotifier.provider);
    final notifier = ref.watch(ProxiesNotifier.provider.notifier);

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
          if (state.isSystemProxy) {
            await notifier.clearSystemProxy();
          } else {
            await notifier.setSystemProxy();
          }
        },
        child: state.isSystemProxy
            ? const Icon(Icons.wifi_off)
            : const Icon(Icons.wifi),
      ),
    );
  }
}
