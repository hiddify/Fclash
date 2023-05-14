import 'dart:io';

import 'package:clashify/services/notification/notification_service.dart';
import 'package:clashify/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // TODO: handle action
}

// ignore: unreachable_from_main
class LocalNotificationService with InfraLogger implements NotificationService {
  LocalNotificationService(this.flutterLocalNotificationsPlugin);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? payload;

  @override
  Future<void> init() async {
    loggy.debug('initializing');
    const initializationSettings = InitializationSettings(
      linux: LinuxInitializationSettings(defaultActionName: 'act'),
      macOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings("fclash"),
    );

    await _initDetails();
    await _initChannels();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _initDetails() async {
    if (kIsWeb || Platform.isLinux) return;
    final initialDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (initialDetails?.didNotificationLaunchApp ?? false) {
      payload = initialDetails!.notificationResponse?.payload;
      loggy.debug('app launched from notification, payload: $payload');
      // TODO: use payload
    }
  }

  Future<void> _initChannels() async {
    // TODO: manage channels
  }

  @override
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // TODO: complete
    loggy.debug('received notification response, $notificationResponse');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    String? body,
    NotificationDetails? details,
    String? payload,
  }) async {
    loggy.debug('showing notification');
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details ??
          const NotificationDetails(
            linux: LinuxNotificationDetails(
              urgency: LinuxNotificationUrgency.normal,
            ),
            macOS: DarwinNotificationDetails(),
            android: AndroidNotificationDetails(
              "cn.kingtous.fclash",
              "fclash",
            ),
          ),
      payload: payload,
    );
  }

  @override
  Future<void> removeNotification(int id) async {
    loggy.debug('removing notification');
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
