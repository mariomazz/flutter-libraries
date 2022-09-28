extension IterableExtension<T> on Iterable<T> {
  Map<K, Iterable<T>> groupBy<K>(K Function(T data) key) {
    final map = <K, Iterable<T>>{};
    for (var e in this) {
      (map[key(e)] ??= []).toList().add(e);
    }
    return map;
  }
}
