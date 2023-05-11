class Routes {
  const Routes(this.path);

  final String path;

  static const Routes proxies = Routes('/proxies');
  static const Routes profiles = Routes('/profiles');
  static const Routes settings = Routes('/settings');
  static const Routes logs = Routes('/logs');
  static const Routes connections = Routes('/connections');
  static const Routes about = Routes('/about');

  factory Routes.profile(String id) => Routes('/profiles/$id');
}
