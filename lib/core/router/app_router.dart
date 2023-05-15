// import 'package:clashify/core/router/app_routes.dart';
// import 'package:clashify/core/wrapper/wrapper.dart';
// import 'package:clashify/features/connections/view/connections_page.dart';
// import 'package:clashify/features/logs/view/logs_page.dart';
// import 'package:clashify/features/profile_detail/view/view.dart';
// import 'package:clashify/features/profiles/view/view.dart';
// import 'package:clashify/features/proxies/view/proxies_page.dart';
// import 'package:clashify/features/settings/view/settings_page.dart';
// import 'package:flutter/widgets.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class AppRouter {
//   static final provider = Provider((ref) => AppRouter());

//   RouterConfig<Object> get config => _router;

//   late final _router = GoRouter(
//     initialLocation: Routes.proxies.path,
//     navigatorKey: _rootNavigatorKey,
//     debugLogDiagnostics: true,
//     routes: _routes,
//   );

//   int get currentTabIndex {
//     final index = tabs.indexWhere(_router.location.startsWith);
//     return index >= 0 ? index : 0;
//   }

//   Future<void> push(Routes route, {Object? extra}) async {
//     await _router.push(route.path, extra: extra);
//   }

//   Future<void> changeTab(int index) async {
//     return _router.go(tabs[index]);
//   }

//   List<String> get tabs => [
//         Routes.proxies.path,
//         Routes.profiles.path,
//         Routes.connections.path,
//         Routes.logs.path,
//         Routes.settings.path,
//       ];

//   static final _rootNavigatorKey =
//       GlobalKey<NavigatorState>(debugLabel: 'root');
//   static final _shellNavigatorKey =
//       GlobalKey<NavigatorState>(debugLabel: 'shell');

//   final List<RouteBase> _routes = [
//     ShellRoute(
//       navigatorKey: _shellNavigatorKey,
//       builder: (context, state, child) {
//         return ResponsiveWrapper(child);
//       },
//       routes: [
//         GoRoute(
//           path: Routes.proxies.path,
//           name: 'proxies',
//           builder: (context, state) {
//             return const ProxiesPage();
//           },
//         ),
//         GoRoute(
//           path: Routes.profiles.path,
//           name: 'profiles',
//           builder: (context, state) {
//             return const ProfilesPage();
//           },
//           routes: [
//             GoRoute(
//               path: ":id",
//               builder: (context, state) {
//                 final profileId = state.pathParameters['id'];

//                 return ProfileDetailPage(profileId!);
//               },
//             ),
//           ],
//         ),
//         GoRoute(
//           path: Routes.connections.path,
//           name: 'connections',
//           builder: (context, state) {
//             return const ConnectionsPage();
//           },
//         ),
//         GoRoute(
//           path: Routes.logs.path,
//           name: 'logs',
//           builder: (context, state) {
//             return const LogsPage();
//           },
//         ),
//         GoRoute(
//           path: Routes.settings.path,
//           name: 'settings',
//           builder: (context, state) {
//             return const SettingsPage();
//           },
//         ),
//       ],
//     ),
//   ];
// }

import 'package:clashify/core/router/app_routes.dart';
import 'package:clashify/features/home/view/view.dart';
import 'package:clashify/features/logs/view/view.dart';
import 'package:clashify/features/profile_detail/view/view.dart';
import 'package:clashify/features/profiles/profiles.dart';
import 'package:clashify/features/settings/view/view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppRouter {
  static final provider = Provider((ref) => AppRouter());

  RouterConfig<Object> get config => _router;

  late final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: _routes,
  );

  Future<void> push(Routes route, {Object? extra}) async {
    await _router.push(route.path, extra: extra);
  }

  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  final List<RouteBase> _routes = [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: Routes.profile(':id').path,
      name: 'profile',
      builder: (context, state) {
        // TODO: handle null id
        final profileId = state.pathParameters['id'];
        final String? profileUrl;
        if (state.extra is String) {
          profileUrl = state.extra! as String;
        } else {
          profileUrl = null;
        }
        return ProfileDetailPage(
          profileId!,
          url: profileUrl,
        );
      },
    ),
    GoRoute(
      path: Routes.logs.path,
      name: 'logs',
      builder: (context, state) {
        return const LogsPage();
      },
    ),
    GoRoute(
      path: Routes.settings.path,
      name: 'settings',
      pageBuilder: (context, state) {
        return const MaterialPage(
          fullscreenDialog: true,
          child: SettingsPage(),
        );
      },
    ),
  ];
}
