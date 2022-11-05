import 'dart:async';
import 'package:flutter/material.dart';
import 'stream.dart';
import 'utils/utils.dart';

extension ListenableExtension on Listenable {
  Stream<void> toStream() {
    final StreamController<void> ctr = StreamController<void>.broadcast();
    void f() {}
    addListener(() {
      ctr.add(f());
    });
    return ctr.stream;
  }

  static Listenable fromMultiStream(List<Stream> streams) =>
      MultipleChangeNotifier(StreamExtension.withMulti(streams));

  static Listenable fromMulti(List<Listenable> listenables) =>
      MultipleChangeNotifier(StreamExtension.withMulti(
          listenables.map((e) => e.toStream()).toList()));
}
