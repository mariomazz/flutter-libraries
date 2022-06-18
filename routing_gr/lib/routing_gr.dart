import 'dart:async';

import 'package:connectivity_service/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:widgets/progress.dart';
import 'package:widgets/resolve_snapshot.dart';

class Routing {
  // init

  Routing.init({
    required RoutingConfigurations configurations,
  }) {
    _instance = this;

    _configurations = configurations;

    _initialPage = _configurations.initialPage;
    _builder = _configurations.builder;
    _pages = _initializePages(_configurations.pages);
    _errorBuilder = _configurations.errorBuilder;

    // connectivity
    _connectivityManagement = _configurations.connectivityManagement;
    _withoutConnection = _configurations.withoutConnection;
    if (_connectivityManagement) {
      _initConnectivityService();
    }
    // end connectivity

    // authentication
    _authentication = _configurations.authentication;
    _authManagement = _configurations.authManagement;
    _withoutAuthentication = _configurations.withoutAuthentication;
    _authenticationProgress = _configurations.authenticationProgress;
    // end authentication

    if (_configurations.setPathUrlStrategy) {
      _roSetPathUrlStrategy();
    }
  }

  static Routing? _instance;

  factory Routing() {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("routing is not initialized");
  }

  late final RoutingConfigurations _configurations;

  late final Widget _errorBuilder;

  late final List<String> _pages;

  late final String _initialPage;

  late final Widget? Function(String page) _builder;

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

  RouteInformationProvider get routeProvider => _go.routeInformationProvider;

  BuildContext? get key => _go.navigator?.context;

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
          return _builder(e) ?? _errorBuilder;
        },
      );
    }).toList();
  }

  late final GoRouter _go = GoRouter(
    initialLocation: _initialPage,
    routes: _buildRoutes(),
    errorBuilder: (context, state) {
      return _errorBuilder;
    },
    redirect: (state) {
      if (state.location == _initialRoute) {
        return _initialPage;
      }
      return null;
    },
    navigatorBuilder: (context, state, widget) {
      if (notConnect) {
        return NavigatorCS(child: _withoutConnection);
      }

      if (authentication) {
        return AuthenticationBuilder(
          controller: _authentication!,
          withoutAuthentication: _withoutAuthentication,
          builder: widget,
          authenticationProgress: _authenticationProgress,
        );
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

  static void _roSetPathUrlStrategy() {
    setPathUrlStrategy();
  }

  // routing refresh

  late final _listenable = Listenable();

  void refresh() {
    _listenable.notify();
  }

  // end routing refresh

  // connectivity_service

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
      refresh();
    });
  }

  bool get notConnect {
    return (_connectivityManagement && _internetAvailable == false);
  }

  // end connectivity_service

  // auth service

  late final StreamController<bool>? _authentication;

  late Widget _withoutAuthentication;

  late Widget _authenticationProgress;

  late final bool _authManagement;

  bool get authentication {
    return (_authManagement && _authentication != null);
  }

  // auth service

}

class AuthenticationBuilder extends StatelessWidget {
  const AuthenticationBuilder({
    Key? key,
    required this.controller,
    required this.withoutAuthentication,
    required this.builder,
    required this.authenticationProgress,
  }) : super(key: key);

  final StreamController<bool> controller;
  final Widget withoutAuthentication;
  final Widget builder;
  final Widget authenticationProgress;

  @override
  Widget build(BuildContext context) {
    return NavigatorCS(
      child: StreamBuilder<bool>(
        stream: controller.stream,
        builder: (context, snapshot) {
          return ResolveSnapshot<bool>(
            snapshot: snapshot,
            onData: (data) {
              if (data) {
                return builder;
              }
              return withoutAuthentication;
            },
            onError: withoutAuthentication,
            loading: authenticationProgress,
          );
        },
      ),
    );
  }
}

class NavigatorCS extends StatelessWidget {
  const NavigatorCS({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onPopPage: (_, __) => false,
      pages: [
        MaterialPage(
          child: child,
        )
      ],
    );
  }
}

class WithoutConnection extends StatelessWidget {
  const WithoutConnection({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Non sei connesso alla rete"),
      ),
    );
  }
}

class WithoutAuthentication extends StatelessWidget {
  const WithoutAuthentication({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Non sei autenticato, effettua login"),
      ),
    );
  }
}

class NotFound extends StatelessWidget {
  const NotFound({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("404 NOT FOUND"),
      ),
    );
  }
}

class Listenable with ChangeNotifier {
  void notify() {
    return notifyListeners();
  }
}

class RoutingConfigurations {
  final String initialPage;
  final List<String> pages;
  Widget? Function(String page) builder;
  final Widget errorBuilder;
  final bool setPathUrlStrategy;
  final bool connectivityManagement;
  final Widget withoutConnection;
  final bool authManagement;
  final Widget withoutAuthentication;
  final StreamController<bool>? authentication;
  final Widget authenticationProgress;

  RoutingConfigurations({
    required this.initialPage,
    required this.pages,
    required this.builder,
    this.errorBuilder = const NotFound(),
    this.setPathUrlStrategy = false,
    this.connectivityManagement = false,
    this.withoutConnection = const WithoutConnection(),
    this.authManagement = false,
    this.withoutAuthentication = const WithoutAuthentication(),
    this.authentication,
    this.authenticationProgress =
        const Scaffold(backgroundColor: Colors.white, body: ProgressCS()),
  });
}
