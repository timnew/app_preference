import 'dart:async';

import 'package:logging/logging.dart';

final appPreferenceLogger = Logger('AppPreference');

mixin AppPreferenceAdaptor {
  /// Read a value from the storage that directly supported
  FutureOr<T?> read<T>(String key);

  /// Write a value to the storage that directly supported
  FutureOr<void> write<T>(String key, T value);

  /// Read string or null, used by serializer
  FutureOr<String?> serializerRead(String key) => read(key);

  /// Write string or null, used by serializer
  FutureOr<void> serializerWrite(String key, String? value) => write(key, value);
}
