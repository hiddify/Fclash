import 'package:clashify/services/notification/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class StubNotificationService implements NotificationService {
  @override
  Future<void> init() async {
    return;
  }

  @override
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {}

  @override
  Future<void> removeNotification(int id) async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  }) async {}
}
