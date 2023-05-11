import 'package:fclash/services/auto_start_service.dart';
import 'package:fclash/services/clash/clash.dart';
import 'package:fclash/services/notification/notification.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:proxy_manager/proxy_manager.dart';

abstract class Services {
  static final notification = Provider((ref) => NotificationService());
  static final proxyManager = Provider((ref) => ProxyManager());
  static final clash = Provider<ClashService>(
    (ref) => ClashServiceImpl(
      proxyManager: ref.read(proxyManager),
    ),
  );
  static final autoStart = Provider((ref) => AutoStartService());
}
