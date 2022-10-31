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

class ChangeNotifierExtension<T extends ValueClass<D>, D>
    extends ChangeNotifier {
  ChangeNotifierExtension() {
    _init();
  }


  D? value; 

  // ignore: unused_field
  void Function(T)? _fn;

  void listener(void Function(T) fn) {
    _fn = fn;
  }

  void _init() {
    addListener(() {
      if (_fn != null) {
        // _fn!(this.);
      }
    });
  }

  /*  @override
  void removeListener() {
    _fn = null;
    super.removeListener(() {});
  } */

  @override
  void dispose() {
    _fn = null;

    super.dispose();
  }
}

abstract class ValueClass<T> {
  T get value;
}

class Person implements ValueClass<String> {
  @override
  String get value => "CIAO";
}

class Name extends ChangeNotifierExtension<Person, String> {
  void init() {
    listener((data) {});
  }
}
