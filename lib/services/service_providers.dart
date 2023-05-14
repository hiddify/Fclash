import 'package:clashify/services/auto_start_service.dart';
import 'package:clashify/services/clash/clash.dart';
import 'package:clashify/services/files_editor_service.dart';
import 'package:clashify/services/notification/notification.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Services {
  static final notification = Provider((_) => NotificationService());

  static final filesEditor = Provider((_) => FilesEditorService());

  static final clash = Provider<ClashService>(
    (_) => ClashServiceImpl(),
  );

  static final autoStart = Provider((_) => AutoStartService());
}
