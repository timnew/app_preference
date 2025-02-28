// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

class LoggerSpy with IterableMixin<LogRecord> {
  Level? _previousLevel;
  StreamSubscription<LogRecord>? _subscription;

  void setUp() {
    print('Setup LoggerSpy...');
    reset();
    _previousLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    _subscription = Logger.root.onRecord.listen(call);
  }

  void tearDown() {
    print('Tear down LoggerSpy...');
    Logger.root.level = _previousLevel;
    _subscription?.cancel();
    _subscription = null;
  }

  final List<LogRecord> records = [];

  void call(LogRecord record) {
    records.add(record);
    print(record);
    if (record.error != null) {
      print(record.error);
    }
  }

  void reset() {
    records.clear();
  }

  @override
  Iterator<LogRecord> get iterator => records.iterator;
}

LoggerSpy useLoggerSpy() {
  final spy = LoggerSpy();

  setUp(spy.setUp);
  tearDown(spy.tearDown);

  return spy;
}

extension LogRecordHelper on Iterable<LogRecord> {
  Iterable<LogRecord> whereFromLogger(String name) =>
      where((record) => record.loggerName == name);

  Iterable<LogRecord> whereHasError() =>
      where((record) => record.error != null);
}

const isLogRecord = TypeMatcher<LogRecord>();

extension LogRecordTypeMatcherExtension on TypeMatcher<LogRecord> {
  TypeMatcher<LogRecord> havingName(dynamic name) =>
      having((r) => r.loggerName, 'loggerName', name);

  TypeMatcher<LogRecord> havingLevel(dynamic level) =>
      having((r) => r.level, 'level', level);

  TypeMatcher<LogRecord> havingMessage(dynamic message) =>
      having((r) => r.message, 'message', message);

  TypeMatcher<LogRecord> havingError(dynamic error) =>
      having((r) => r.error, 'error', error);
}
