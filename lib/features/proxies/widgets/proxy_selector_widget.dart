// import 'package:fclash/domain/models/clash_proxy.dart';
// import 'package:fclash/features/proxy/notifier/notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class ProxySelector extends HookConsumerWidget {
//   const ProxySelector(this.selector, this.delay, {Key? key}) : super(key: key);

//   final ClashProxy selector;
//   final int? delay;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifier = ref.watch(ProxyNotifier.provider.notifier);

//     return ExpansionTile(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(selector.name),
//           IconButton(
//             onPressed: () async {
//               if (selector.proxies == null) return;
//               await notifier.testDelays(
//                   selector.proxies!.map((e) => e.proxyName).toList());
//             },
//             icon: Icon(Icons.abc),
//           ),
//         ],
//       ),
//       subtitle: Text(selector.now ?? ''),
//       initiallyExpanded: false,
//       children: [
//         ...selector.proxies?.map((e) => ProxySelectorItem(
//                   name: e.proxyName,
//                   isSelected: e.proxyName == selector.now,
//                   onSelect: () async {
//                     await notifier.changeProxy(selector.name, e.proxyName);
//                   },
//                 )) ??
//             [],
//       ],
//     );
//   }
// }

// class ProxySelectorItem extends HookConsumerWidget {
//   const ProxySelectorItem({
//     Key? key,
//     required this.name,
//     this.delay,
//     required this.isSelected,
//     required this.onSelect,
//   }) : super(key: key);

//   final String name;
//   final int? delay;
//   final bool isSelected;
//   final VoidCallback onSelect;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ListTile(
//       title: Text(name),
//       selected: isSelected,
//       onTap: onSelect,
//     );
//   }
// }

import 'package:fclash/domain/models/clash_proxy.dart';
import 'package:fclash/domain/models/clash_proxy_group.dart';
import 'package:fclash/features/proxies/notifier/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxySelector extends HookConsumerWidget {
  const ProxySelector(this.selector, this.delay, {super.key});

  final ClashProxyGroup selector;
  final int? delay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(ProxiesNotifier.provider.notifier);

    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(selector.name),
          IconButton(
            onPressed: () async {
              if (selector.proxies == null) return;
              // await notifier.testDelays(
              //   selector.proxies!.map((e) => e.name).toList(),
              // );
            },
            icon: const Icon(Icons.abc),
          ),
        ],
      ),
      subtitle: Text(selector.now ?? ''),
      children: [
        ...selector.proxies?.map(
              (e) => ProxySelectorItem(
                proxy: e,
                isSelected: e.name == selector.now,
                onSelect: () async {
                  await notifier.changeProxy(selector.name, e.name);
                },
              ),
            ) ??
            [],
      ],
    );
  }
}

class ProxySelectorItem extends HookConsumerWidget {
  const ProxySelectorItem({
    super.key,
    required this.proxy,
    this.delay,
    required this.isSelected,
    required this.onSelect,
  });

  final ClashProxy proxy;
  final int? delay;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(proxy.name),
      trailing: Text(proxy.delay.toString()),
      selected: isSelected,
      onTap: onSelect,
    );
  }
}
