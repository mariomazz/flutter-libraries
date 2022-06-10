library routing_gr;

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
  }) {
    _instance = this;
    _initialPage = initialPage;
    _builder = builder;
    _pages = _initializePages(pages);
    _connectivityManagement = connectivityManagement;
    _withoutConnection = withoutConnection;

    if (setPathUrlStrategy) {
      roSetPathUrlStrategy();
    }

    if (_connectivityManagement) {
      _initConnectivityService();
    }
  }

  static Routing? _instance;

  factory Routing() {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("routing is not initialized");
  }

  void _initConnectivityService() {
    _connectivity.stream.listen((event) {
      if (event == ConnectivityResultCS.none) {
        _internetAvailable = false;
      } else {
        _internetAvailable = true;
      }
      refresh();
    });
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
    routes: _buildRoutes(),
    errorBuilder: (context, state) {
      return _builder(state.location);
    },
    redirect: (state) {
      if (state.location == _initialRoute) {
        return _initialPage;
      }
      return null;
    },
    navigatorBuilder: (context, state, widget) {
      if (_connectivityManagement && _internetAvailable == false) {
        return _withoutConnection;
      }
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

  final ConnectivityService _connectivity = ConnectivityService();

  bool? _internetAvailable;

  late Widget _withoutConnection;

  late final bool _connectivityManagement;

  // end connectivity_service

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

class Listenable with ChangeNotifier {
  void notify() {
    return notifyListeners();
  }
}
