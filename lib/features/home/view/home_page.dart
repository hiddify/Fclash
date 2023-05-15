import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/router/router.dart';
import 'package:clashify/features/home/notifier/notifier.dart';
import 'package:clashify/features/home/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final activeProfile =
        ref.watch(HomeNotifier.provider.select((value) => value.activeProfile));
    final router = ref.watch(AppRouter.provider);

    return Scaffold(
      drawer: NavigationDrawer(
        children: [
          NavigationDrawerDestination(
            icon: const Icon(Icons.home),
            label: Text(t.home.pageTitle.titleCase),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.article),
            label: Text(t.logs.pageTitle.titleCase),
          ),
        ],
        onDestinationSelected: (value) async {
          switch (value) {
            case 0:
              return router.push(Routes.home);
            case 1:
              return router.push(Routes.logs);
          }
        },
      ),
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
              // TODO: handle loading and failure
              ...activeProfile.maybeWhen(
                data: (activeProfile) => [
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
                ],
                orElse: () => [const EmptyProfilesBody()],
              ),
            ],
          ),
          // TODO: animate
          if (activeProfile.hasData) const AdvancedSettingsButton(),
        ],
      ),
    );
  }
}
