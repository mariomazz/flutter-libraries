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

  static final Connectivity? _connectivity = _initConnectivity();

  final StreamController<ConnectivityResultCS> _streamController =
      BehaviorSubject<ConnectivityResultCS>();

  Stream<ConnectivityResultCS> get stream => _streamController.stream;

  void _init() async {
    final platformValid = _checkPlatform();
    if (platformValid) {
      _connectivity?.onConnectivityChanged.listen((value) async {
        await checkConnectivity().then((value) {
          _streamController.add(value);
        });
      });
      await checkConnectivity().then((value) {
        _streamController.add(value);
      });
    } else {
      _streamController.add(ConnectivityResultCS.wifi);
    }
  }

  void dispose() {
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
        return _from((await _connectivity?.checkConnectivity()) ??
            ConnectivityResult.wifi);
      }
      throw Exception();
    } on SocketException catch (_) {
      return ConnectivityResultCS.none;
    } catch (e) {
      return ConnectivityResultCS.none;
    }
  }

  static Connectivity? _initConnectivity() {
    if (_checkPlatform()) {
      return Connectivity();
    }
    return null;
  }

  static bool _checkPlatform() {
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }
}

enum ConnectivityResultCS { bluetooth, wifi, ethernet, mobile, none }
