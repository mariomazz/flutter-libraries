import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'models/auth_configuration.dart';
import 'models/auth_data.dart';
import 'models/auth_storage.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider.create();

  static AuthProvider? _instance;

  static Future<AuthProvider> init(
      {required AuthConfigurations configurations,
      Future<void> Function(AuthData data)? listenable}) async {
    _instance = AuthProvider.create();
    _instance!._configurations = configurations;
    _instance!.listenable = listenable;
    _instance!._setSession(await _instance!.loadSession());

    return _instance!;
  }

  factory AuthProvider() {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("AuthProvider not initialized");
  }

  late final AuthConfigurations _configurations;

  late final Future<void> Function(AuthData data)? listenable;

  late final _authService =
      AuthService(configurations: _configurations, dbLoginKey: _dbLoginKey);

  late final _dbLoginKey =
      "auth__${_configurations.clientId}${_configurations.redirectUrl}${_configurations.authorizationEndpoint}";

  final _sessionNull = AuthData(isAuth: false);

  late AuthData _session;

  AuthData get current => _session;

  String? get currentAccessToken => current.accessToken;

  bool get currentIsAuth => current.isAuth;

  bool? get isAuthorized => current.isAuthorized;

  String? get userId => current.userId;

  Future<SharedPreferences> get _storage async {
    return await SharedPreferences.getInstance();
  }

  Future<AuthData> loadSession() async {
    try {
      final storageInstance = (await _storage).getString(_dbLoginKey);

      if (storageInstance != null) {
        final loginData = AuthStorageData.fromJson(storageInstance);
        final session = AuthData(
          isAuth: true,
          accessToken: loginData.accessToken,
          userId: loginData.userId,
        );

        return session;
      } else {
        return _sessionNull;
      }
    } catch (e) {
      return _sessionNull;
    }
  }

  Future<String?> refreshSession() async {
    final refreshData = await _authService.refreshSession();
    await _instance!.listenable?.call(refreshData);
    _setSession(refreshData, notify: true);
    return refreshData.accessToken;
  }

  Future<void> login() async {
    final authData = await _authService.login();
    await _instance!.listenable?.call(authData);
    return _setSession(authData, notify: true);
  }

  Future<void> logout() async {
    await _authService.logout();
    await _instance!.listenable?.call(_sessionNull);
    return _setSession(_sessionNull, notify: true);
  }

  void setAuthorization(bool authorized) {
    final session = _session;
    session.isAuthorized = authorized;
    return _setSession(session, notify: true);
  }

  void _setSession(AuthData data, {bool notify = false}) {
    _session = data;
    if (notify) {
      return notifyListeners();
    }
  }
}
