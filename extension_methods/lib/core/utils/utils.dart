import 'dart:async';
import 'package:flutter/material.dart';

class MultipleChangeNotifier extends ChangeNotifier {
  MultipleChangeNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract class Setable {
  int get key;
}
