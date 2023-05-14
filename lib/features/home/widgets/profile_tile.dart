import 'package:clashify/core/core_providers.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileTile extends HookConsumerWidget {
  const ProfileTile(
    this.profile, {
    super.key,
    this.onTap,
  });

  final Profile profile;
  final void Function(BuildContext context)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(Core.translations);
    final subInfo = profile.subInfo;

    final themeData = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onTap?.call(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  children: [
                    TextSpan(
                      text: profile.name,
                      style: themeData.textTheme.titleMedium,
                    ),
                    const TextSpan(text: " • "),
                    TextSpan(
                      text: t.home.updatedTimeAgo(
                        timeAgo: timeago.format(profile.lastUpdate),
                      ),
                    ),
                  ],
                ),
              ),
              if (subInfo?.isValid ?? false)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(t.home.subscriptionState.remaining),
                    const Gap(16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTrafficByteSize(
                              subInfo!.consumption,
                              subInfo.total!,
                            ),
                            style: themeData.textTheme.titleMedium,
                          ),
                          LinearProgressIndicator(
                            value: subInfo.ratio,
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
