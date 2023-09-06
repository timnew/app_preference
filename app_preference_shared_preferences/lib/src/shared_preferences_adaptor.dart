import 'dart:async';

import 'package:app_preference/app_preference_plugin_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAdaptor with AppPreferenceAdaptor {
  final SharedPreferences _prefs;

  const SharedPreferencesAdaptor(this._prefs);

  @override
  T? read<T>(String key) {
    assert(
      () {
        return isSameTypeOrNullable<T, String>() ||
            isSameTypeOrNullable<T, int>() ||
            isSameTypeOrNullable<T, double>() ||
            isSameTypeOrNullable<T, bool>() ||
            isSameTypeOrNullable<T, List<String>>();
      }(),
      'Unsupported type: $T',
    );

    return _prefs.get(key) as T?;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    assert(
      () {
        return isSameTypeOrNullable<T, String>() ||
            isSameTypeOrNullable<T, int>() ||
            isSameTypeOrNullable<T, double>() ||
            isSameTypeOrNullable<T, bool>() ||
            isSameTypeOrNullable<T, List<String>>();
      }(),
      'Unsupported type: $T',
    );

    if (value == null) {
      await _prefs.remove(key);
    } else if (isSameTypeOrNullable<T, String>()) {
      await _prefs.setString(key, value as String);
    } else if (isSameTypeOrNullable<T, int>()) {
      await _prefs.setInt(key, value as int);
    } else if (isSameTypeOrNullable<T, double>()) {
      await _prefs.setDouble(key, value as double);
    } else if (isSameTypeOrNullable<T, bool>()) {
      await _prefs.setBool(key, value as bool);
    } else if (isSameTypeOrNullable<T, List<String>>()) {
      await _prefs.setStringList(key, value as List<String>);
    } else {
      throw UnsupportedError("Type $T is not supported");
    }
  }

  @override
  String? serializerRead(String key) => _prefs.getString(key);

  @override
  Future<void> serializerWrite(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }
}
