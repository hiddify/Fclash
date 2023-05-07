import 'dart:io';

import 'package:fclash/services/notification/local_notification_service.dart';
import 'package:fclash/services/notification/stub_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  factory NotificationService() {
    if (Platform.isWindows) return StubNotificationService();
    return LocalNotificationService(FlutterLocalNotificationsPlugin());
  }

  Future<void> init();

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  );

  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  });

  Future<void> removeNotification(int id);
}
