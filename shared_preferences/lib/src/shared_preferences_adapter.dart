import 'dart:async';

import 'package:app_preference/app_preference.dart';
import 'package:app_preference/app_preference_plugin_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter for [SharedPreferences] to be used with [AppPreference].
class SharedPreferencesAdapter with AppPreferenceAdapter {
  final SharedPreferences _prefs;

  /// Create a new [SharedPreferencesAdapter].
  const SharedPreferencesAdapter(this._prefs);

  /// Read a value from [SharedPreferences].
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

  /// Read a value from [SharedPreferences] using a serializer.
  @override
  String? serializerRead(String key) => _prefs.getString(key);

  /// Write a value to [SharedPreferences] using a serializer.
  @override
  Future<void> serializerWrite(String key, String? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }
}
