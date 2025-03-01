import 'dart:async';
import 'dart:convert';

import 'package:app_preference/src/function_types.dart';
import 'package:flutter/foundation.dart';

import 'contract.dart';

Future<T> wrapFutureOr<T>(FutureOr<T> value) =>
    value is Future<T> ? value : SynchronousFuture(value);

FutureOr<T> futureOrNullFallback<T>(FutureOr<T?> value, T defaultValue) =>
    value is Future<T?>
        ? value.then((value) => value ?? defaultValue) as FutureOr<T>
        : value ?? defaultValue;

Future<void> nopAsyncValueSetter(dynamic value) => SynchronousFuture(null);

RawValueDeserializer<T> wrapJsonDeserializer<T>(
  JsonDeserializer<T> deserializer,
  T defaultValue,
) =>
    (String? data) => data == null
        ? defaultValue
        : deserializer(
            jsonDecode(data) as Map<String, dynamic>,
          );

RawValueSerializer<T> wrapJsonSerializer<T>(
  JsonSerializer<T> serializer,
  T defaultValue,
) =>
    (T value) => value == defaultValue ? null : jsonEncode(serializer(value));

extension AdapterExtension on AppPreferenceAdapter {
  AsyncValueSetter<T> createDirectWriter<T>(String key) =>
      (T value) => wrapFutureOr(write(key, value));

  AsyncValueSetter<T> createSerializedWriter<T>(
    String key,
    RawValueSerializer<T> serializer,
  ) =>
      (T value) => wrapFutureOr(serializerWrite(key, serializer(value)));

  FutureOr<T> deserializedRead<T>(
      String key, RawValueDeserializer<T> deserializer) {
    final value = serializerRead(key);

    if (value is Future<String?>) {
      return value.then((value) => deserializer(value));
    } else {
      return deserializer(value);
    }
  }
}
