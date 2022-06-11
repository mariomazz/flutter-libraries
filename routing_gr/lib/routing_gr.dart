library routing_gr;

import 'dart:async';
import 'package:connectivity_service/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

class Routing {
  // init

  Routing.init({
    required String initialPage,
    required List<String> pages,
    required Widget Function(String page) builder,
    bool setPathUrlStrategy = false,
    bool connectivityManagement = false,
    Widget withoutConnection = const WithoutConnection(),
    bool authManagement = false,
    Widget withoutAuthentication = const WithoutAuthentication(),
    StreamController<bool>? authentication,
  }) {
    _instance = this;
    _initialPage = initialPage;
    _builder = builder;
    _pages = _initializePages(pages);

    // connectivity
    _connectivityManagement = connectivityManagement;
    _withoutConnection = withoutConnection;
    if (_connectivityManagement) {
      _initConnectivityService();
    }
    // end connectivity

    // authentication
    _authentication = authentication;
    _authManagement = authManagement;
    _withoutAuthentication = withoutAuthentication;
    if (_authManagement) {
      _initAuthService();
    }
    // end authentication

    if (setPathUrlStrategy) {
      roSetPathUrlStrategy();
    }
  }

  static Routing? _instance;

  factory Routing() {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("routing is not initialized");
  }

  late final List<String> _pages;

  late final String _initialPage;

  late final Widget Function(String page) _builder;

  static const _initialRoute = "/";

  List<String> _initializePages(List<String> pages) {
    return pages
        .where((e) => e.contains(_initialRoute) && e != _initialRoute)
        .toSet()
        .toList();
  }

  // end init

  RouterDelegate<Object> get delegate => _go.routerDelegate;

  RouteInformationParser<Object> get parser => _go.routeInformationParser;

  // save browsing data

  Object? getExtra(String page) => _stackObj[page];

  final Map<String, Object?> _stackObj = {};

  void _pushObj(Object? obj, String path) =>
      obj != null ? _stackObj.addAll({path: obj}) : () {};

  // end save browsing data

  // GoRouter

  List<GoRoute> _buildRoutes() {
    return _pages.map((e) {
      return GoRoute(
        path: e,
        builder: (context, state) {
          _pushObj(state.extra, e);
          return _builder(e);
        },
      );
    }).toList();
  }

  late final GoRouter _go = GoRouter(
    initialLocation: _initialPage,
    routes: [..._buildRoutes(), _connectivityGoRoute, _loginGoRoute],
    errorBuilder: (context, state) {
      return _builder(state.location);
    },
    redirect: (state) {
      if (state.location == _initialRoute) {
        return _initialPage;
      }
      if (_connectivityManagement && _internetAvailable == false) {
        return _connectivityRoute;
      }
      if (_authManagement && _isAuth == false) {
        print("loginRoute");

        return _loginRoute;
      }
      return null;
    },
    navigatorBuilder: (context, state, widget) {
      return widget;
    },
    refreshListenable: _listenable,
  );

  // end GoRouter

  // navigations

  void go(String page, {Object? extra}) => _go.go(page, extra: extra);

  void push(String page, {Object? extra}) => _go.push(page, extra: extra);

  void pop() => _go.pop();

  // end navigations

  static void roSetPathUrlStrategy() {
    setPathUrlStrategy();
  }

  // routing refresh

  final _listenable = Listenable();

  void refresh() {
    return _listenable.notify();
  }

  // end routing refresh

  // connectivity_service

  static const _connectivityRoute = "/connectivityPage";

  late final _connectivityGoRoute = GoRoute(
    path: _connectivityRoute,
    builder: (context, state) {
      return _withoutConnection;
    },
  );

  final ConnectivityService _connectivity = ConnectivityService();

  bool? _internetAvailable;

  late Widget _withoutConnection;

  late final bool _connectivityManagement;

  void _initConnectivityService() {
    _connectivity.stream.listen((event) {
      if (event == ConnectivityResultCS.none) {
        _internetAvailable = false;
      } else {
        _internetAvailable = true;
      }
      print("internet available");
      refresh();
    });
  }

  // end connectivity_service

  // auth service

  static const _loginRoute = "/loginPage";

  late final _loginGoRoute = GoRoute(
    path: _loginRoute,
    builder: (context, state) {
      return _withoutAuthentication;
    },
  );

  late final StreamController<bool>? _authentication;

  bool? _isAuth;

  late Widget _withoutAuthentication;

  late final bool _authManagement;

  void _initAuthService() {
    _authentication?.stream.listen((event) {
      _isAuth = event;
      print("auth service");
      refresh();
    });
  }

  // auth service

}

class WithoutConnection extends StatelessWidget {
  const WithoutConnection({Key? key}) : super(key: key);
  final Widget _withoutConnection = const Scaffold(
    body: Center(
      child: Text("Non sei connesso alla rete"),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return _withoutConnection;
  }
}

class WithoutAuthentication extends StatelessWidget {
  const WithoutAuthentication({Key? key}) : super(key: key);
  final Widget _withoutAuthentication = const Scaffold(
    body: Center(
      child: Text("Non sei autenticato, effettua login"),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return _withoutAuthentication;
  }
}

class Listenable with ChangeNotifier {
  void notify() {
    return notifyListeners();
  }
}
