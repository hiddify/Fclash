import 'dart:io';

import 'package:clashify/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FilesEditorService with InfraLogger {
  late final Directory _clashDirectory;

  Future<void> init() async {
    loggy.debug('initializing');
    final supportDir = await getApplicationSupportDirectory();
    _clashDirectory = Directory(p.join(supportDir.path, "clash"));
  }

  String getConfigPath(String configName) {
    return p.join(_clashDirectory.path, "$configName.yaml");
  }

  Future<String> getConfigData(String configName) async {
    final path = getConfigPath(configName);
    final file = File(path);
    if (!await file.exists()) {
      throw Exception();
    }
    return file.readAsString();
  }

  Future<void> createOrUpdateConfig(
    String configName,
    String yamlContent,
  ) async {
    final path = getConfigPath(configName);
    final file = File(path);
    await file.writeAsString(yamlContent);
  }

  Future<void> deleteConfig(String configName) async {
    final path = getConfigPath(configName);
    final file = File(path);
    await file.delete();
  }
}
