import 'dart:async';
import 'dart:convert';

import 'package:app_preference/app_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_native/json_native.dart';
import 'package:logging/logging.dart';
import 'package:mobx/mobx.dart' hide when;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../support/logger_spy.dart';
import '../support/observable_spy.dart';
import '../support/test_model.dart';

@GenerateNiceMocks([MockSpec<AppPreferenceAdapter>()])
import 'app_preference_test.mocks.dart';

void main() {
  group('AppPreference', () {
    const key = 'key';
    const strDefault = 'default';
    const strValue = 'value';
    const strNewValue = 'new';
    const name = 'AppPreference.$key';

    const modelDefault = TestModel.empty;
    const modelValue = TestModel(key: 'key', value: 100);
    final modelValueJson = jsonEncode(modelValue.toJson());
    const modelNew = TestModel(key: 'anotherKey', value: 400);
    final modelNewJson = jsonEncode(modelNew.toJson());

    final error = Exception('test error');

    late MockAppPreferenceAdapter adapter;
    late Completer<String?> readCompleter;
    late Completer<void> writeCompleter;

    setUp(() {
      adapter = MockAppPreferenceAdapter();
      readCompleter = Completer<String?>();
      writeCompleter = Completer<void>();
    });

    group('.direct', () {
      late AppPreference<String> pref;

      AppPreference<String> createPref(FutureOr<String?> value) {
        when(adapter.read<String>(captureAny)).thenAnswer((_) => value);
        when(adapter.write(captureAny, captureAny)).thenAnswer((_) => writeCompleter.future);

        return pref = AppPreference<String>.direct(
          adapter: adapter,
          key: key,
          defaultValue: strDefault,
        );
      }

      VerificationResult verifyAdapterRead() => verify(adapter.read<String>(captureAny));

      VerificationResult verifyAdapterWritten() =>
          verify(adapter.write<String>(captureAny, captureAny));

      void verifyNoAdapterWritten() => verifyNever(adapter.write<String>(any, any));

      final loggerSpy = useLoggerSpy();

      test('should support sync read', () {
        createPref(strValue);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.fulfilled);
        expect(pref.value, strValue);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should support sync read fallback to default', () {
        createPref(null);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.fulfilled);
        expect(pref.value, strDefault);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should support async read', () async {
        createPref(readCompleter.future);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.pending);

        readCompleter.complete(strValue);
        await pref.ready;

        expect(observableReady.status, FutureStatus.fulfilled);

        expect(pref.value, strValue);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should support async read fallback to default', () async {
        createPref(readCompleter.future);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.pending);

        readCompleter.complete(null);
        await pref.ready;

        expect(observableReady.status, FutureStatus.fulfilled);

        expect(pref.value, strDefault);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should report error when read failed', () async {
        createPref(readCompleter.future);

        readCompleter.completeError(error);
        // Offer opportunity for the async result to propagate
        await expectLater(pref.ready, throwsException);

        expect(
          loggerSpy.whereHasError().single,
          isLogRecord
              .havingError(error)
              .havingMessage(contains('read'))
              .havingLevel(Level.SEVERE)
              .havingName(name),
        );
      });

      test('should support async write', () async {
        createPref(strValue);

        pref.value = strNewValue;

        final observableWriteDone = ObservableFuture(pref.writeDone);

        expect(observableWriteDone.status, FutureStatus.pending);

        writeCompleter.complete();
        await pref.writeDone;

        expect(observableWriteDone.status, FutureStatus.fulfilled);

        expect(verifyAdapterWritten().captured, [key, strNewValue]);
      });

      test('should report error when writing failed', () async {
        createPref(strValue);

        pref.value = strNewValue;

        writeCompleter.completeError(error);
        await expectLater(pref.writeDone, throwsException);

        expect(
          loggerSpy.whereHasError().single,
          isLogRecord
              .havingError(error)
              .havingMessage(contains('write'))
              .havingLevel(Level.SEVERE)
              .havingName(name),
        );
      });

      test('should support write more than once', () async {
        createPref(strDefault);
        writeCompleter.complete();

        pref.value = strValue;
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, strValue],
        );

        pref.value = strNewValue;
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, strNewValue],
        );
      });

      test('should not hang when save the same value', () async {
        createPref(strDefault);

        pref.value = strValue;

        writeCompleter.complete();
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, strValue],
        );

        pref.value = strValue;
        await pref.writeDone;

        verifyNoAdapterWritten();
      });

      test('should not error if a write is triggered before current one finished', () async {
        createPref(strDefault);

        pref.value = strValue;
        final future1 = pref.writeDone;

        pref.value = strNewValue;
        final future2 = pref.writeDone;

        writeCompleter.complete();

        await future1;
        await future2;

        expect(verifyAdapterWritten().captured.last, strNewValue);
      });
    });

    group(".serialized", () {
      late AppPreference<TestModel> pref;

      AppPreference<TestModel> createPref(FutureOr<String?> value) {
        when(adapter.serializerRead(captureAny)).thenAnswer((_) => value);
        when(adapter.serializerWrite(captureAny, captureAny))
            .thenAnswer((_) => writeCompleter.future);

        return pref = AppPreference<TestModel>.serialized(
          adapter: adapter,
          key: key,
          defaultValue: modelDefault,
          serializer: (model) => model.toJson(),
          deserializer: TestModel.fromJson,
        );
      }

      VerificationResult verifyAdapterRead() => verify(adapter.serializerRead(captureAny));

      VerificationResult verifyAdapterWritten() =>
          verify(adapter.serializerWrite(captureAny, captureAny));

      void verifyNoAdapterWritten() => verifyNever(adapter.serializerWrite(any, any));

      final loggerSpy = useLoggerSpy();

      test('should support sync read', () {
        createPref(modelValueJson);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.fulfilled);
        expect(pref.value, modelValue);

        expect(verify(adapter.serializerRead(captureAny)).captured.single, key);
      });

      test('should support sync read fallback to default', () {
        createPref(null);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.fulfilled);
        expect(pref.value, modelDefault);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should support async read', () async {
        createPref(readCompleter.future);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.pending);

        readCompleter.complete(modelValueJson);
        await pref.ready;

        expect(observableReady.status, FutureStatus.fulfilled);

        expect(pref.value, modelValue);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should support async read fallback to default', () async {
        createPref(readCompleter.future);

        final observableReady = ObservableFuture(pref.ready);
        expect(observableReady.status, FutureStatus.pending);

        readCompleter.complete(null);
        await pref.ready;

        expect(observableReady.status, FutureStatus.fulfilled);

        expect(pref.value, modelDefault);

        expect(verifyAdapterRead().captured.single, key);
      });

      test('should report error when read failed', () async {
        createPref(readCompleter.future);

        readCompleter.completeError(error);
        // Offer opportunity for the async result to propagate
        await expectLater(pref.ready, throwsException);

        expect(
          loggerSpy.whereHasError().single,
          isLogRecord
              .havingError(error)
              .havingMessage(contains('read'))
              .havingLevel(Level.SEVERE)
              .havingName(name),
        );
      });

      test('should support async write', () async {
        createPref(modelValueJson);

        pref.value = modelNew;

        final observableWriteDone = ObservableFuture(pref.writeDone);

        expect(observableWriteDone.status, FutureStatus.pending);

        writeCompleter.complete();
        await pref.writeDone;

        expect(observableWriteDone.status, FutureStatus.fulfilled);

        expect(verifyAdapterWritten().captured, [key, modelNewJson]);
      });

      test('should report error when writing failed', () async {
        createPref(modelValueJson);

        pref.value = modelNew;

        writeCompleter.completeError(error);
        await expectLater(pref.writeDone, throwsException);

        expect(
          loggerSpy.whereHasError().single,
          isLogRecord
              .havingError(error)
              .havingMessage(contains('write'))
              .havingLevel(Level.SEVERE)
              .havingName(name),
        );
      });

      test('should support write more than once', () async {
        createPref(null);
        writeCompleter.complete();

        pref.value = modelValue;
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, modelValueJson],
        );

        pref.value = modelNew;
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, modelNewJson],
        );
      });

      test('should not hang when save the same value', () async {
        createPref(null);

        pref.value = modelValue;

        writeCompleter.complete();
        await pref.writeDone;

        expect(
          verifyAdapterWritten().captured,
          [key, modelValueJson],
        );

        pref.value = modelValue;
        await pref.writeDone;

        verifyNoAdapterWritten();
      });

      test('should not error if a write is triggered before current one finished', () async {
        createPref(null);

        pref.value = modelValue;
        final future1 = pref.writeDone;

        pref.value = modelNew;
        final future2 = pref.writeDone;

        writeCompleter.complete();

        await future1;
        await future2;

        expect(verifyAdapterWritten().captured.last, modelNewJson);
      });
    });

    group("memory", () {
      test("it should set initial value", () {
        final pref = AppPreference<String>.memory(strDefault);

        expect(pref.value, strDefault);
      });

      test("it should set initial async value", () async {
        final pref = await AppPreference<String>.memory(Future.value(strDefault)).ensuredCreation();

        expect(pref.value, strDefault);
      });

      test("it should update value", () {
        final pref = AppPreference<String>.memory(strDefault);

        pref.value = strNewValue;

        expect(pref.value, strNewValue);
      });
    });
    group('monitor changes', () {
      test('should monitor changes', () async {
        final pref = AppPreference<String>.memory(strDefault);

        final changes = useObservableSpy(() => pref.value);

        expect(changes, [strDefault]);

        pref.value = strValue;

        expect(changes, [strDefault, strValue]);

        pref.value = strNewValue;

        expect(changes, [strDefault, strValue, strNewValue]);

        changes.dispose();
      });
    });
  });
}
