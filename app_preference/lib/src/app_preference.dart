import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart';

import 'contract.dart';
import 'function_types.dart';
import 'internal.dart';

/// An observable value holder that can be used to store and retrieve app preferences.
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
    required AppPreferenceAdapter adapter,
    required String key,
    required T defaultValue,
  }) : this._(
          key,
          futureOrNullFallback(adapter.read(key), defaultValue),
          adapter.createDirectWriter(key),
        );

  /// Create a new [AppPreference] instance with value type that not directly supported by [adapter]
  /// [jsonSerializer] and [jsonDeserializer] will be used to serialize and deserialize the value to/from `Map<String, dynamic>`,
  /// which later can be convert to/fom JSON string via `jsonEncode` and `jsonDecode`.
  AppPreference.serialized({
    required AppPreferenceAdapter adapter,
    required String key,
    required T defaultValue,
    required JsonSerializer<T> serializer,
    required JsonDeserializer<T> deserializer,
  }) : this.customSerialized(
          adapter: adapter,
          key: key,
          serializer: wrapJsonSerializer(serializer, defaultValue),
          deserializer: wrapJsonDeserializer(deserializer, defaultValue),
        );

  /// Create a new [AppPreference] instance with value type that not directly supported by [adapter] with custom serializer and deserializer.
  /// [serializer] and [deserializer] need to handle the null value properly, which might be returned by [adapter].
  AppPreference.customSerialized({
    required AppPreferenceAdapter adapter,
    required String key,
    required RawValueSerializer<T> serializer,
    required RawValueDeserializer<T> deserializer,
  }) : this._(
          key,
          adapter.deserializedRead(key, deserializer),
          adapter.createSerializedWriter(key, serializer),
        );

  /// Create a new [AppPreference] instance that cached in memory, could be used for testing.
  AppPreference.memory(
    FutureOr<T> value, {
    String key = 'memory',
    AsyncValueSetter<T> onWrite = nopAsyncValueSetter,
  }) : this._(key, value, onWrite);

  /// Create a [Stream] that emits the current value and its future changes.
  Stream<T> asStream() {
    late final ReactionDisposer disposer;
    late final StreamController<T> controller;

    controller = StreamController(
      onListen: () {
        disposer = autorun((_) => controller.add(value));
      },
      onCancel: () {
        disposer.call();
      },
    );

    return controller.stream;
  }

  /// Subscribe to value and its future changes.
  /// [listener] would be notified for current value
  ///
  /// A [ReactionDisposer] is returned, which can be used to unsubscribe.
  ReactionDisposer subscribe(ValueListener<T> listener) =>
      autorun((_) => listener(value));

  /// Subscribe to value's future changes.
  /// [listener] will be notified for all value changed, but not the current value.
  ///
  /// A [ReactionDisposer] is returned, which can be used to unsubscribe.
  ReactionDisposer subscribeChanges(ValueListener<T> listener) =>
      reaction((_) => value, listener);

  /// [listener] will be notified when [predicate] returns `true`
  /// Subscription disposes itself after [listener] is called once.
  ///
  /// A [ReactionDisposer] is returned, which can be used to unsubscribe.
  ReactionDisposer notifyWhen(Predict<T> predict, ValueListener<T> listener) =>
      when((_) => predict(value), () => listener(value));

  /// [Logger] that receives logs from all [AppPreference] instances.
  static Logger get logger => Logger('AppPreference');

  /// Subscribe to all logs from all [AppPreference] instances.
  /// Could be useful to bridge [AppPreference] logs to other logging system if app isn't using [Logger].
  static StreamSubscription<LogRecord> onLog(
          ValueListener<LogRecord> listener) =>
      logger.onRecord.listen(listener);

  /// Subscribe to all errors from all [AppPreference] instances.
  /// Could be useful to bridge [AppPreference] errors to error reporting system if app isn't using [Logger].
  static StreamSubscription<LogRecord> onError(ErrorListener errorListener) =>
      onLog((log) {
        if (log.error == null) return;

        errorListener(log.message, log.error!, log.stackTrace);
      });
}

/// Extension methods for [AppPreference]
/// All methods here works on derived type of [AppPreference]
///
/// Example:
/// ```dart
/// class MySecret extends AppPreference<String> {
///   MySecret(SecureStorageAdapter adapter): super.direct(
///     adapter: adapter,
///     key: 'my_secret',
///     defaultValue: 'i do not know',
///   );
/// }
///
/// Future<MySecret> createMySecret(SecureStorageAdapter adapter) => MySecrete(adapter).ensuredCreation();
/// ```
/// `createMySecret` returns `Future<MySecrete>` instead of `Future<AppPreference<String>>`
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
