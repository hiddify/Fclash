import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/router/router.dart';
import 'package:clashify/features/home/widgets/widgets.dart';
import 'package:clashify/features/profiles/profiles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final activeProfile = ref.watch(
      ProfilesNotifier.provider.select((value) => value.selectedProfile),
    );

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(t.general.appTitle.titleCase),
                pinned: true,
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      await ref.read(AppRouter.provider).push(Routes.settings);
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              if (activeProfile == null) ...[
                const EmptyProfilesBody(),
              ] else ...[
                SliverToBoxAdapter(
                  child: ActiveProfileCard(activeProfile),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: 86,
                    ),
                    child: ConnectionDetailsBody(),
                  ),
                ),
              ]
            ],
          ),
          if (activeProfile != null) const AdvancedSettingsButton(),
        ],
      ),
    );
  }
}
