import 'dart:async';

import 'package:flutter/foundation.dart';

import 'contract.dart';

Future<T> wrapFutureOr<T>(FutureOr<T> value) {
  if (value is Future<T>) {
    return value;
  } else {
    return SynchronousFuture(value);
  }
}

Future<void> nopAsyncValueSetter(dynamic value) => SynchronousFuture(null);

NullableDeserializer<T> wrapDeserializer<T>(Deserializer<T> deserializer, T defaultValue) =>
    (String? data) => data == null ? defaultValue : deserializer(data);

extension AdapterExtension on AppPreferenceAdaptor {
  AsyncValueSetter<T> createSimpleWriter<T>(String key) =>
      (T value) => wrapFutureOr(write(key, value));

  AsyncValueSetter<T> createSerializedWriter<T>(
    String key,
    NullableSerializer<T> serializer,
  ) =>
      (T value) => wrapFutureOr(serializerWrite(key, serializer(value)));

  FutureOr<T> deserializedRead<T>(String key, NullableDeserializer<T> deserializer) {
    final value = serializerRead(key);

    if (value is Future<String?>) {
      return value.then((value) => deserializer(value));
    } else {
      return deserializer(value);
    }
  }
}
