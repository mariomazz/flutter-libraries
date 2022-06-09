library routing_gr;

import 'package:flutter/foundation.dart';
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
  }) {
    _instance = this;
    _initialPage = initialPage;
    _builder = builder;
    _pages = _initializePages(pages);

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
    routes: _buildRoutes(),
    errorBuilder: (context, state) {
      return _builder(state.location);
    },
    redirect: (state) {
      if (kDebugMode) {
        print("GoRouterBuild");
      }
      if (state.location == _initialRoute) {
        return _initialPage;
      }
      return null;
    },
    navigatorBuilder: (context, state, widget) {
      if (kDebugMode) {
        print("GoRouterBuild");
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

  // listenable class

  final _listenable = Listenable();
  void refresh() {
    return _listenable.notify();
  }
}

class Listenable with ChangeNotifier {
  void notify() {
    return notifyListeners();
  }
}
