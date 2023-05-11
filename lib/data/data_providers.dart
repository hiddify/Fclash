import 'package:dio/dio.dart';
import 'package:fclash/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const clashBaseUrl = "http://127.0.0.1:$clashExtPort";
const clashExtPort = 22345;
const timeout = Duration(milliseconds: 15000);

abstract class Data {
  /// shared preferences instance
  ///
  /// * must be overridden in bootstrapping process
  static final sharedPreferences = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('sharedPreferences must be overridden'),
    name: 'shared preferences',
  );

  static final dio = Provider(
    (ref) => Dio(
      BaseOptions(
        baseUrl: clashBaseUrl,
        connectTimeout: timeout,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      ),
    ),
  );

  static final preferences = Provider<Preferences>(
    (ref) => Preferences.basic(
      sharedPreferences: ref.read(sharedPreferences),
    ),
  );
}
