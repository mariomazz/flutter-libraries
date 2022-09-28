import 'dart:async';

extension StreamExtension on Stream {
  Future<T> toFuture<T>() {
    final c = Completer<T>();
    listen((data) {
      if (!c.isCompleted) {
        c.complete(data);
      }
    });
    return c.future;
  }

  static Stream<T> withMulti<T>(List<Stream<T>> streams) {
    return Stream<T>.multi(
      (c) {
        for (var e in streams) {
          c.addStream(e);
        }
      },
      isBroadcast: true,
    );
  }
}
