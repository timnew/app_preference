import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart';

import 'contract.dart';
import 'internal.dart';

class AppPreference<T> {
  final Logger _logger;
  final Atom _atom;

  /// A future that resolves when the preference is ready to use.
  late final Future<void> ready;

  AsyncValueSetter<T> _writeValue;
  Completer<void> _writeCompleter = Completer()..complete(null);

  /// A future that resolves when the preference is written.
  Future<void> get writeDone => _writeCompleter.future;

  AppPreference._(
    String key,
    FutureOr<T> readValue,
    this._writeValue,
  )   : _logger = Logger('AppPreference.$key'),
        _atom = Atom(name: 'AppPreference.$key') {
    _init(readValue);
  }

  void _init(FutureOr<T> readValue) {
    if (readValue is Future<T>) {
      _logger.fine('Start async reading...');
      ready = _performAsyncRead(readValue);
    } else {
      _value = readValue;
      ready = SynchronousFuture(null);
      _logger.fine('Initialization succeeded');
    }
  }

  Future<void> _performAsyncRead(Future<T> readValue) async {
    try {
      _value = await readValue;
    } catch (ex, stackTrace) {
      _logger.severe('Failed to read value', ex, stackTrace);
      rethrow;
    }
    _logger.fine('Initialization succeeded');
  }

  late T _value;

  /// The current value of the preference.
  T get value {
    _atom.reportRead();
    return _value;
  }

  /// Set the value of the preference.
  set value(T v) {
    if (_value == v) {
      _logger.info('Set the same value, skip writing');
      return;
    }
    _logger.fine('Prepare to write...');
    _atom.reportWrite(v, _value, () {
      _value = v;
      _logger.fine('In memory value is set');
      _asyncWrite(v).ignore();
    });
  }

  Future<void> _asyncWrite(T newValue) async {
    _logger.info('Write new value...');
    final completer = _writeCompleter = Completer();

    try {
      await _writeValue(newValue);
      completer.complete();
      _logger.info('Write succeeded');
    } catch (ex, stackTrace) {
      _logger.severe('Failed to write value', ex, stackTrace);
      completer.completeError(ex, stackTrace);
    }
  }

  /// Create a new [AppPreference] instance with value type that directly supported by [adapter]
  AppPreference.direct({
    required AppPreferenceAdaptor adaptor,
    required String key,
    required T defaultValue,
  }) : this._(
          key,
          adaptor.read(key, defaultValue),
          adaptor.createSimpleWriter(key),
        );

  /// Create a new [AppPreference] instance with value type that not directly supported by [adapter]
  AppPreference.nullableSerialized({
    required AppPreferenceAdaptor adaptor,
    required String key,
    required NullableSerializer<T> serializer,
    required NullableDeserializer<T> deserializer,
  }) : this._(
          key,
          adaptor.deserializedRead(key, deserializer),
          adaptor.createSerializedWriter(key, serializer),
        );

  AppPreference.serialized({
    required AppPreferenceAdaptor adaptor,
    required String key,
    required T defaultValue,
    required Serializer<T> serializer,
    required Deserializer<T> deserializer,
  }) : this._(
          key,
          adaptor.deserializedRead(
            key,
            wrapDeserializer(deserializer, defaultValue),
          ),
          adaptor.createSerializedWriter(key, serializer),
        );

  /// Create a new [AppPreference] instance that cached in memory, could be used for testing.
  AppPreference.memory(
    FutureOr<T> value, {
    String key = 'memory',
    AsyncValueSetter<T> writeValue = nopAsyncValueSetter,
  }) : this._(key, value, writeValue);
}

extension AppPreferenceEnsuredExtension<T, AP extends AppPreference<T>> on AP {
  /// Wait until the preference is ready to use.
  /// Could be used as an async factory for [AppPreference].
  Future<AP> ensuredCreation() async {
    await ready;
    return this;
  }

  /// Read the value of the preference when it is ready.
  Future<T> ensuredRead() async {
    await ready;
    return value;
  }

  /// Ensure the value is really written to the storage.
  Future<AP> ensuredWrite(T value) async {
    this.value = value;
    await writeDone;
    return this;
  }
}
