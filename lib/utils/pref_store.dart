import 'dart:convert';

import 'package:clashify/utils/loggers.dart';
import 'package:clashify/utils/preferences.dart';

class PrefStore<T> with InfraLogger {
  PrefStore({
    required this.prefs,
    required this.key,
    required this.defaultValue,
    this.mapFrom,
    this.mapTo,
    this.onUpdate,
  });

  final Preferences prefs;
  final String key;
  final T defaultValue;
  final T Function(Map<String, dynamic> json)? mapFrom;
  final Map<String, dynamic> Function(T item)? mapTo;
  final void Function(T value)? onUpdate;

  Future<T> get() async {
    loggy.debug('getting key: [$key] of type: [$T]');
    if (mapFrom != null && mapTo != null) {
      return mapFrom!(
        jsonDecode(prefs.getString(key, jsonEncode(mapTo!(defaultValue))))
            as Map<String, dynamic>,
      );
    } else if (T == bool) {
      return prefs.getBool(key, defaultValue as bool) as T;
    } else if (T == int) {
      return prefs.getInt(key, defaultValue as int) as T;
    } else if (T == String) {
      return prefs.getString(key, defaultValue as String) as T;
    } else if (T == double) {
      return prefs.getDouble(key, defaultValue as double) as T;
    }
    loggy.error('[$T] was not handled for key: [$key]');
    throw Exception();
  }

  Future<void> update(T pref) async {
    await _update(pref);
    onUpdate?.call(pref);
  }

  Future<void> _update(T pref) async {
    if (mapTo != null) {
      return prefs.setString(key, jsonEncode(mapTo!(pref)));
    } else if (T == bool) {
      return prefs.setBool(key, pref as bool);
    } else if (T == int) {
      return prefs.setInt(key, pref as int);
    } else if (T == String) {
      return prefs.setString(key, pref as String);
    } else if (T == double) {
      return prefs.setDouble(key, pref as double);
    }
    throw Exception();
  }
}
