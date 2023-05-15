import 'package:clashify/core/core_providers.dart';
import 'package:clashify/core/router/router.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/features/profiles/profiles.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ActiveProfileCard extends HookConsumerWidget {
  const ActiveProfileCard(this.profile, {super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  // child: Text(
                  //   profile.name,
                  //   style: Theme.of(context).textTheme.titleMedium,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          shape: Theme.of(context).bottomSheetTheme.shape,
                          clipBehavior: Clip.antiAlias,
                          builder: (context) {
                            return DraggableScrollableSheet(
                              expand: false,
                              builder: (context, scrollController) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ProfilesModal(
                                    scrollController: scrollController,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Gap(4),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(AppRouter.provider).push(Routes.newProfile);
                  },
                  label: Text(t.home.addNewProfile.titleCase),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (profile.hasSubscriptionInfo) ...[
              const Divider(thickness: 0.5),
              SubscriptionInfoTile(profile.subInfo!),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class SubscriptionInfoTile extends StatelessWidget {
  const SubscriptionInfoTile(this.subInfo, {super.key});

  final SubscriptionInfo subInfo;

  @override
  Widget build(BuildContext context) {
    if (!subInfo.isValid) return const SizedBox.shrink();

    final themeData = Theme.of(context);

    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      formatTrafficByteSize(
                        subInfo.consumption,
                        subInfo.total!,
                      ),
                      style: themeData.textTheme.titleMedium,
                    ),
                  ),
                  const Text('traffic'),
                ],
              ),
              LinearProgressIndicator(
                value: subInfo.ratio,
                minHeight: 6,
              ),
            ],
          ),
        ),
        const Gap(8),
        const Icon(Icons.refresh, size: 44),
        const Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subInfo.isExpired)
              const Text('expired')
            else
              Text(
                formatExpireDuration(subInfo.remaining),
                style: themeData.textTheme.titleSmall,
              ),
            Text(
              'remaining',
              style: themeData.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
