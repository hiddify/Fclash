import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class EmptyProfilesBody extends HookConsumerWidget {
  const EmptyProfilesBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.home.emptyProfilesMsg.sentenceCase),
          const SizedBox(height: 16),
          Wrap(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  // TODO: read clipboard
                  await ref.read(AppRouter.provider).push(
                        Routes.profile('new'),
                        extra:
                            'https://raw.githubusercontent.com/AzadNetCH/Clash/main/AzadNet.yml',
                      );
                },
                icon: const Icon(Icons.content_paste),
                label: Text(t.home.addFromClipboard.sentenceCase),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(t.home.scanQr.sentenceCase),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
