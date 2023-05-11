import 'package:fclash/core/router/app_routes.dart';
import 'package:fclash/core/wrapper/wrapper.dart';
import 'package:fclash/features/connections/view/connections_page.dart';
import 'package:fclash/features/logs/view/logs_page.dart';
import 'package:fclash/features/profile_detail/view/view.dart';
import 'package:fclash/features/profiles/view/view.dart';
import 'package:fclash/features/proxies/view/proxies_page.dart';
import 'package:fclash/features/settings/view/settings_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppRouter {
  static final provider = Provider((ref) => AppRouter());

  RouterConfig<Object> get config => _router;

  late final _router = GoRouter(
    initialLocation: Routes.proxies.path,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: _routes,
  );

  int get currentTabIndex {
    final index = tabs.indexWhere(_router.location.startsWith);
    return index >= 0 ? index : 0;
  }

  Future<void> push(Routes route, {Object? extra}) async {
    await _router.push(route.path, extra: extra);
  }

  Future<void> changeTab(int index) async {
    return _router.go(tabs[index]);
  }

  List<String> get tabs => [
        Routes.proxies.path,
        Routes.profiles.path,
        Routes.connections.path,
        Routes.logs.path,
        Routes.settings.path,
      ];

  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  final List<RouteBase> _routes = [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ResponsiveWrapper(child);
      },
      routes: [
        GoRoute(
          path: Routes.proxies.path,
          name: 'proxies',
          builder: (context, state) {
            return const ProxiesPage();
          },
        ),
        GoRoute(
          path: Routes.profiles.path,
          name: 'profiles',
          builder: (context, state) {
            return const ProfilesPage();
          },
          routes: [
            GoRoute(
              path: ":id",
              builder: (context, state) {
                final profileId = state.pathParameters['id'];

                return ProfileDetailPage(profileId!);
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.connections.path,
          name: 'connections',
          builder: (context, state) {
            return const ConnectionsPage();
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
          builder: (context, state) {
            return const SettingsPage();
          },
        ),
      ],
    ),
  ];
}
