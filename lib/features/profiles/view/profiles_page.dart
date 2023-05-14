// import 'package:clashify/core/router/router.dart';
// import 'package:clashify/features/profiles/notifier/notifier.dart';
// import 'package:clashify/features/profiles/widgets/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class ProfilesPage extends HookConsumerWidget {
//   const ProfilesPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(ProfilesNotifier.provider);

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (context, index) {
//                 final profile = state.profiles[index];
//                 final isActive = state.selectedProfile?.id == profile.id;
//                 return ProfileTile(
//                   profile: profile,
//                   isActive: isActive,
//                   onTap: () async {
//                     await ref
//                         .read(ProfilesNotifier.provider.notifier)
//                         .selectActiveProfile(profile.id);
//                   },
//                 );
//               },
//               childCount: state.profiles.length,
//             ),
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           ref.read(AppRouter.provider).push(Routes.profile('new'));
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
