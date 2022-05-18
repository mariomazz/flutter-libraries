library extension_methods;

import 'dart:math';

extension ExString on String {
  bool equals(String other) {
    return this == other;
  }

  bool notEquals(String other) {
    return this != other;
  }

  bool equalsAny(List<String> other) {
    for (var value in other) {
      if (equals(value)) {
        return true;
      }
    }

    return false;
  }
}

extension ExList<T> on List<T> {
  T randomItem() => this[Random().nextInt(length)];
  List<T> afterShuffle() => this..shuffle();
}
