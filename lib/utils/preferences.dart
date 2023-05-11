import 'package:shared_preferences/shared_preferences.dart';

abstract class Preferences {
  const Preferences();

  const factory Preferences.basic({
    required SharedPreferences sharedPreferences,
    String? prefix,
  }) = _BasicPreferences;

  SharedPreferences get _sharedPreferences;

  /// An optional prefix that will be used for all keys when provided.
  String? get _prefix;

  int getInt(String key, int defaultValue);
  double getDouble(String key, double defaultValue);
  bool getBool(String key, bool defaultValue);
  String getString(String key, String defaultValue);
  List<String> getStringList(String key, List<String> defaultValue);

  void setInt(String key, int value);
  void setDouble(String key, double value);
  // ignore: avoid_positional_boolean_parameters
  void setBool(String key, bool value);
  void setString(String key, String value);
  void setStringList(String key, List<String> value);

  void remove(String key) => _sharedPreferences.remove(_buildKey(key));

  String _buildKey(String key) {
    if (_prefix?.isNotEmpty ?? false) return '$_prefix.$key';

    return key;
  }

  bool contains(String key) {
    return _sharedPreferences.containsKey(key);
  }

  List<String> getKeys() {
    return _sharedPreferences.getKeys().toList();
  }
}

class _BasicPreferences extends Preferences {
  const _BasicPreferences({
    required SharedPreferences sharedPreferences,
    String? prefix,
  })  : _sharedPreferences = sharedPreferences,
        _prefix = prefix;

  @override
  final SharedPreferences _sharedPreferences;

  @override
  final String? _prefix;

  @override
  int getInt(String key, int defaultValue) =>
      _sharedPreferences.getInt(_buildKey(key)) ?? defaultValue;

  @override
  double getDouble(String key, double defaultValue) =>
      _sharedPreferences.getDouble(_buildKey(key)) ?? defaultValue;

  @override
  bool getBool(String key, bool defaultValue) =>
      _sharedPreferences.getBool(_buildKey(key)) ?? defaultValue;

  @override
  String getString(String key, String defaultValue) =>
      _sharedPreferences.getString(_buildKey(key)) ?? defaultValue;

  @override
  List<String> getStringList(String key, List<String> defaultValue) =>
      _sharedPreferences.getStringList(_buildKey(key)) ?? defaultValue;

  @override
  void setInt(String key, int value) =>
      _sharedPreferences.setInt(_buildKey(key), value);

  @override
  void setDouble(String key, double value) =>
      _sharedPreferences.setDouble(_buildKey(key), value);

  @override
  void setBool(String key, bool value) =>
      _sharedPreferences.setBool(_buildKey(key), value);

  @override
  void setString(String key, String value) =>
      _sharedPreferences.setString(_buildKey(key), value);

  @override
  void setStringList(String key, List<String> value) =>
      _sharedPreferences.setStringList(_buildKey(key), value);
}
