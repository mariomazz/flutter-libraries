import 'dart:math';
import 'package:extension_methods/core/string.dart';
import 'utils/utils.dart';

extension ListExtension<T> on List<T> {
  String createQueryParameters({
    required String key,
    bool questionMarker = true,
  }) {
    String value = questionMarker ? "?" : "";
    for (var element in this) {
      value += "$key=${element.toString()}&";
    }
    return value.removeLast(test: (e) => e.endsWith("&"));
  }

  Map<K, List<T>> groupBy<K>(K Function(T data) key) {
    final map = <K, List<T>>{};
    for (var e in this) {
      (map[key(e)] ??= []).add(e);
    }
    return map;
  }

  T randomItem() => this[Random().nextInt(length)];

  List<T> afterShuffle() => this..shuffle();

  List<T> sortWithTest({bool Function(T a, T b)? test}) {
    for (int a = 0; a < length; a += 1) {
      for (int b = 0; b < length - 1; b += 1) {
        if (test == null ? false : test(this[b], this[b + 1])) {
          final array = invertValue(b, b + 1);
          for (int i = 0; i < array.length; i += 1) {
            this[i] = array[i];
          }
        }
      }
    }
    return this;
  }

  List<T> invertValue(int i1, int i2) {
    if (isEmpty) {
      return this;
    }

    final app = this[i1];
    this[i1] = this[i2];
    this[i2] = app;
    return this;
  }
}

extension Ext<T extends Setable> on List<T> {
  List<T> toSet() {
    final allKeys = map((e) => e.key).toSet().toList();
    final app = <T>[];
    for (var key in allKeys) {
      app.add(firstWhere((e) => e.key == key,
          orElse: () => throw Exception("KEY not Found")));
    }

    return app;
  }
}
