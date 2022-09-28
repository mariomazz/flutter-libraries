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

  static Listenable fromMulti(List<Stream> streams) =>
      MultipleChangeNotifier(StreamExtension.withMulti(streams));
}
