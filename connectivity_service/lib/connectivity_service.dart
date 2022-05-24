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

  final StreamController<ConnectivityResultCS> _streamController =
      BehaviorSubject<ConnectivityResultCS>();

  Stream<ConnectivityResultCS> get stream => _streamController.stream;

  void _init() {
    _connectivity.onConnectivityChanged.listen((value) {
      _streamController.add(_from(value));
    });

    _connectivity.checkConnectivity().then((value) {
      _streamController.add(_from(value));
    });
  }

  void disose() {
    _streamController.close();
  }

  ConnectivityResultCS _from(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
        return ConnectivityResultCS.bluetooth;
      case ConnectivityResult.ethernet:
        return ConnectivityResultCS.ethernet;
      case ConnectivityResult.wifi:
        return ConnectivityResultCS.wifi;
      case ConnectivityResult.mobile:
        return ConnectivityResultCS.mobile;
      default:
        return ConnectivityResultCS.none;
    }
  }
}

enum ConnectivityResultCS { bluetooth, wifi, ethernet, mobile, none }
