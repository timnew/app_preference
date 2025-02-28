import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

class ObservableSpy<T> with IterableMixin<T> {
  final List<T> changes = [];
  late final VoidCallback dispose;

  ObservableSpy(ValueGetter<T> getValue) {
    dispose = autorun((_) => changes.add(getValue())).call;
  }

  @override
  Iterator<T> get iterator => changes.iterator;
}

ObservableSpy<T> useObservableSpy<T>(ValueGetter<T> getValue) =>
    ObservableSpy<T>(getValue);
