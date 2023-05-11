// import 'dart:convert';

// import 'package:fclash/data/data_providers.dart';
// import 'package:fclash/utils/preferences.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// typedef ReactivePrefStoreProvider<T>
//     = NotifierProvider<ReactivePrefStore<T>, T>;

// mixin PrefStore<T> {
//   String get key;
//   T get defaultValue;
//   T Function(Map<String, dynamic> json)? get mapFrom;
//   Map<String, dynamic> Function(T item)? get mapTo;
//   Preferences get prefs;

//   Future<T> get() async {
//     if (mapFrom != null && mapTo != null) {
//       return mapFrom!(
//         jsonDecode(prefs.getString(key, jsonEncode(mapTo!(defaultValue)))),
//       );
//     } else if (T is bool) {
//       return prefs.getBool(key, defaultValue as bool) as T;
//     } else if (T is int) {
//       return prefs.getInt(key, defaultValue as int) as T;
//     } else if (T is String) {
//       return prefs.getString(key, defaultValue as String) as T;
//     } else if (T is double) {
//       return prefs.getDouble(key, defaultValue as double) as T;
//     }
//     throw Exception();
//   }

//   Future<void> update(T pref) async {
//     if (mapTo != null) {
//       return prefs.setString(key, jsonEncode(mapTo!(pref)));
//     } else if (T is bool) {
//       return prefs.setBool(key, pref as bool);
//     } else if (T is int) {
//       return prefs.setInt(key, pref as int);
//     } else if (T is String) {
//       return prefs.setString(key, pref as String);
//     } else if (T is double) {
//       return prefs.setDouble(key, pref as double);
//     }
//     throw Exception();
//   }
// }

// class SimplePrefStore<T> with PrefStore<T> {
//   SimplePrefStore({
//     required this.prefs,
//     required this.key,
//     required this.defaultValue,
//     this.mapFrom,
//     this.mapTo,
//   });

//   @override
//   final Preferences prefs;
//   @override
//   final String key;
//   @override
//   final T defaultValue;
//   @override
//   final T Function(Map<String, dynamic> json)? mapFrom;
//   @override
//   final Map<String, dynamic> Function(T item)? mapTo;
// }

// class ReactivePrefStore<T> extends Notifier<T> with PrefStore<T> {
//   ReactivePrefStore({
//     required this.key,
//     required this.defaultValue,
//     this.mapFrom,
//     this.mapTo,
//   });

//   @override
//   final String key;
//   @override
//   final T defaultValue;
//   @override
//   final T Function(Map<String, dynamic> json)? mapFrom;
//   @override
//   final Map<String, dynamic> Function(T item)? mapTo;

//   @override
//   Preferences get prefs => ref.read(Data.preferences);

//   @override
//   T build() {
//     return defaultValue;
//   }

//   @override
//   Future<T> get() async {
//     final result = await super.get();
//     state = result;
//     return state;
//   }

//   @override
//   Future<void> update(T pref) async {
//     await super.update(pref);
//     state = pref;
//   }
// }

import 'dart:convert';

import 'package:fclash/data/data_providers.dart';
import 'package:fclash/utils/loggers.dart';
import 'package:fclash/utils/preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef ReactivePrefStoreProvider<T>
    = NotifierProvider<ReactivePrefStore<T>, T>;

mixin PrefStore<T> implements LoggerMixin {
  String get key;
  T get defaultValue;
  T Function(Map<String, dynamic> json)? get mapFrom;
  Map<String, dynamic> Function(T item)? get mapTo;
  Preferences get prefs;

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

class SimplePrefStore<T> with PrefStore<T>, InfraLogger {
  SimplePrefStore({
    required this.prefs,
    required this.key,
    required this.defaultValue,
    this.mapFrom,
    this.mapTo,
  });

  @override
  final Preferences prefs;
  @override
  final String key;
  @override
  final T defaultValue;
  @override
  final T Function(Map<String, dynamic> json)? mapFrom;
  @override
  final Map<String, dynamic> Function(T item)? mapTo;
}

class ReactivePrefStore<T> extends Notifier<T> with PrefStore<T>, InfraLogger {
  ReactivePrefStore({
    required this.key,
    required this.defaultValue,
    this.mapFrom,
    this.mapTo,
  });

  @override
  final String key;
  @override
  final T defaultValue;
  @override
  final T Function(Map<String, dynamic> json)? mapFrom;
  @override
  final Map<String, dynamic> Function(T item)? mapTo;

  @override
  Preferences get prefs => ref.read(Data.preferences);

  @override
  T build() {
    return defaultValue;
  }

  @override
  Future<T> get() async {
    final result = await super.get();
    state = result;
    return state;
  }

  @override
  Future<void> update(T pref) async {
    await super.update(pref);
    state = pref;
  }
}
