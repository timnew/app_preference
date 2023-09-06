import 'dart:async';

import 'package:logging/logging.dart';

final appPreferenceLogger = Logger('AppPreference');

typedef NullableSerializer<T> = String? Function(T value);
typedef NullableDeserializer<T> = T Function(String? data);

typedef Serializer<T> = String Function(T value);
typedef Deserializer<T> = T Function(String data);

mixin AppPreferenceAdaptor {
  /// Read a value from the storage that directly supported
  FutureOr<T> read<T>(String key, T defaultValue);

  /// Write a value to the storage that directly supported
  FutureOr<void> write<T>(String key, T value);

  /// Read string or null, used by serializer
  FutureOr<String?> serializerRead(String key) => read(key, null);

  /// Write string or null, used by serializer
  FutureOr<void> serializerWrite(String key, String? value) => write(key, value);
}
