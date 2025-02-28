import 'dart:async';

import 'package:app_preference/app_preference.dart';
import 'package:app_preference/app_preference_plugin_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageAdapter with AppPreferenceAdapter {
  final FlutterSecureStorage _storage;

  const SecureStorageAdapter(this._storage);

  @override
  Future<T?> read<T>(String key) async {
    assert(
      () {
        return isSameTypeOrNullable<T, String>();
      }(),
      'Unsupported type: $T',
    );

    return (await _storage.read(key: key)) as T?;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    assert(
      () {
        return isSameTypeOrNullable<T, String>();
      }(),
      'Unsupported type: $T',
    );

    await _storage.write(key: key, value: value as String?);
  }
}
