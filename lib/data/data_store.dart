import 'dart:async';
import 'dart:convert';

import 'package:fclash/data/data_providers.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ItemsDataStore<T> extends Notifier<List<T>> with InfraLogger {
  @override
  List<T> build() {
    return [];
  }

  @visibleForTesting
  SharedPreferences get prefs => ref.read(Data.sharedPreferences);
  @visibleForTesting
  String keyGen(String id);

  T mapFrom(Map<String, dynamic> json);
  Map<String, dynamic> mapTo(T item);

  final Map<String, T> _values = {};

  Future<void> init() async {
    final keys =
        prefs.getKeys().where((e) => e.startsWith(keyGen(''))).toList();
    loggy.debug("keys matching [${keyGen('')}] = $keys");
    final possiblyNullItems = await Future.wait(keys.map(_get));
    loggy.debug("items for keys= $possiblyNullItems");
    for (int i = 0; i < keys.length; i++) {
      final item = possiblyNullItems[i];
      loggy.debug("key[${keys[i]}] - index[$i] => $item");
      if (item == null) continue;
      _values[keys[i]] = item;
    }
    state = _values.values.toList();
  }

  Future<T?> get(String id) async {
    return _get(keyGen(id));
  }

  Future<T?> _get(String key) async {
    final persistedString = prefs.getString(key);
    loggy.debug('persisted string for key: [$key] => $persistedString');
    if (persistedString == null) return null;
    try {
      final json = jsonDecode(persistedString);
      return mapFrom(json as Map<String, dynamic>);
    } catch (e) {
      loggy.warning('error getting item key:[$key]: $e');
      return null;
    }
  }

  // Stream<List<T>> watchAll() async* {
  //   final keys = prefs.getKeys().where((e) => e.startsWith(keyGen('')));
  //   final possiblyNullItems = await Future.wait(keys.map(_get));
  //   yield possiblyNullItems.whereNotNull().toList();
  // }

  Future<void> createOrUpdate(String id, T item) async {
    loggy.debug('setting [${keyGen(id)}] to $item');
    await prefs.setString(keyGen(id), jsonEncode(mapTo(item)));
    _values.update(
      keyGen(id),
      (value) => item,
      ifAbsent: () => item,
    );
    state = _values.values.toList();
  }

  Future<void> delete(String id) async {
    loggy.debug('deleting [${keyGen(id)}]');
    await prefs.remove(keyGen(id));
    _values.remove(keyGen(id));
    state = _values.values.toList();
  }
}
