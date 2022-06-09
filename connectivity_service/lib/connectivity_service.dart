library connectivity_service;

import 'dart:async';
import 'dart:io';
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

  static final Connectivity _connectivity = Connectivity();

  final StreamController<ConnectivityResultCS> _streamController =
      BehaviorSubject<ConnectivityResultCS>();

  Stream<ConnectivityResultCS> get stream => _streamController.stream;

  void _init() async {
    _connectivity.onConnectivityChanged.listen((value) async {
      await checkConnectivity().then((value) {
        _streamController.add(value);
      });
    });
    await checkConnectivity().then((value) {
      _streamController.add(value);
    });
  }

  void disose() {
    _streamController.close();
  }

  static ConnectivityResultCS _from(ConnectivityResult result) {
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

  static Future<ConnectivityResultCS> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
          'www.google.com'); // google address for validity issues
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return await _connectivity
            .checkConnectivity()
            .then<ConnectivityResultCS>((value) {
          return _from(value);
        });
      }
      throw Exception();
    } on SocketException catch (_) {
      return ConnectivityResultCS.none;
    }
  }
}

enum ConnectivityResultCS { bluetooth, wifi, ethernet, mobile, none }
