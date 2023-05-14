import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/router/router.dart';
import 'package:clashify/features/home/widgets/profile_tile.dart';
import 'package:clashify/features/profiles/profiles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProfilesBottomSheet extends HookConsumerWidget {
  const ProfilesBottomSheet({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final themeData = Theme.of(context);

    final profiles =
        ref.watch(ProfilesNotifier.provider.select((value) => value.profiles));
    final notifier = ref.watch(ProfilesNotifier.provider.notifier);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        MultiSliver(
          children: [
            SliverPinnedHeader(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.profiles.pageTitle.titleCase,
                        style: themeData.textTheme.titleLarge,
                      ),
                      const Gap(4),
                      // TODO: use icon button, show help dialog
                      const Icon(Icons.help_outline_outlined),
                    ],
                  ),
                  const Gap(8),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(AppRouter.provider)
                                .push(Routes.newProfile);
                          },
                          icon: const Icon(Icons.add),
                          label: Text(t.home.addNewProfile.titleCase),
                        ),
                        const VerticalDivider(thickness: 0.5),
                        TextButton.icon(
                          onPressed: () {
                            // TODO: start scanning
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(t.home.scanQr.titleCase),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 0.5,
                    height: 8,
                    indent: 16,
                    endIndent: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        SliverList.builder(
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return ProfileTile(
              profile,
              onTap: (context) async {
                if (!profile.active) {
                  await notifier.selectActiveProfile(profile.id);
                }
              },
            );
          },
          itemCount: profiles.length,
        ),
      ],
    );
  }
}
