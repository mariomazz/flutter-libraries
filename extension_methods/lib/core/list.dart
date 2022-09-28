import 'dart:math';

extension ListExtension<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T data) key) {
    final map = <K, List<T>>{};
    for (var e in this) {
      (map[key(e)] ??= []).add(e);
    }
    return map;
  }

  T randomItem() => this[Random().nextInt(length)];
  List<T> afterShuffle() => this..shuffle();
}


