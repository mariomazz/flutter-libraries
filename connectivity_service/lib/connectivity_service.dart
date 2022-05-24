library connectivity_service;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  // singleton

  ConnectivityService._instance() {
    _init();
  }

  static final ConnectivityService _connectivityInstance =
      ConnectivityService._instance();

  factory ConnectivityService() {
    return _connectivityInstance;
  }

  // end singleton

  final Connectivity _connectivity = Connectivity();

  final StreamController<ConnectivityResult> _streamController =
      BehaviorSubject<ConnectivityResult>();

  Stream<ConnectivityResult> get stream => _streamController.stream;

  void _init() {
    _connectivity.onConnectivityChanged.listen((value) {
      _streamController.add(value);
    });

    _connectivity.checkConnectivity().then((value) {
      _streamController.add(value);
    });
  }

  void disose() {
    _streamController.close();
  }
}
