library authentication;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession with ChangeNotifier {
  AuthSession.init({required AuthConfigurations configurations}) {
    _instance = this;
    _configurations = configurations;
    _init();
  }

  factory AuthSession() {
    if (_instance != null) {
      return _instance!;
    }
    throw Exception("AuthSession not implemented");
  }

  static AuthSession? _instance;

  late final AuthConfigurations _configurations;

  final StreamController<SessionData> _authController =
      BehaviorSubject<SessionData>();

  Stream<bool> get isAuth =>
      _authController.stream.map<bool>((event) => event.isAuth);

  Stream<String?> get accessToken =>
      _authController.stream.map<String?>((event) => event.accessToken);

  String? get currentAccessToken => _authService.session?.accessToken;

  bool? get currentIsAuth => _authService.session?.isAuth;

  late final _AuthService _authService =
      _AuthService(configurations: _configurations);

  void _init() {
    _authService.authStream.listen((session) {
      _authController.add(session);
      notifyListeners();
    });
  }

  Future<void> login() async {
    return await _authService.login();
  }

  Future<void> logout() async {
    return await _authService.logout();
  }

  Future<void> refreshSession() async {
    return await _authService.refreshSession();
  }
}

class _AuthService {
  _AuthService({required AuthConfigurations configurations}) {
    _configurations = configurations;
    _init();
  }

  late final AuthConfigurations _configurations;

  final StreamController<SessionData> _authController =
      BehaviorSubject<SessionData>();

  Stream<SessionData> get authStream => _authController.stream;

  SessionData? _currentSession;

  SessionData? get session => _currentSession;

  final FlutterAppAuth _appAuthService = const FlutterAppAuth();

  void _init() async {
    _authController.stream.listen((event) {
      _currentSession = event;
    });

    _authController.add((await _loadSession()));
  }

  Future<void> login() async {
    await _login();
  }

  Future<void> logout() async {
    await _logout();
  }

  Future<void> refreshSession() async {
    await _refreshSession();
  }

  // storage
  Future<SharedPreferences> get _storage async {
    return await SharedPreferences.getInstance();
  }

  late final _dbLoginKey =
      "auth__${_configurations.clientId}${_configurations.redirectUrl}${_configurations.authorizationEndpoint}";
  // end storage

  // service

  Future<SessionData?> _login() async {
    try {
      final AuthorizationTokenResponse? requestLogin =
          await _appAuthService.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _configurations.clientId,
          _configurations.redirectUrl,
          scopes: _configurations.scopes,
          issuer: _configurations.issuer,
          preferEphemeralSession: false,
          promptValues: ["login"],
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _configurations.authorizationEndpoint,
            tokenEndpoint: _configurations.tokenEndpoint,
            endSessionEndpoint: _configurations.endSessionEndpoint,
          ),
          additionalParameters: _configurations.additionalParameter,
        ),
      );
      if (!(requestLogin?.accessToken != null &&
          requestLogin?.idToken != null &&
          requestLogin?.accessTokenExpirationDateTime != null &&
          requestLogin?.refreshToken != null)) {
        throw Exception("requestLogin value null");
      }
      final AuthStorageData authData = AuthStorageData(
        accessToken: requestLogin!.accessToken!,
        expiryDate: requestLogin.accessTokenExpirationDateTime!,
        refreshToken: requestLogin.refreshToken!,
        idToken: requestLogin.idToken!,
      );

      final setLoginTokens =
          await (await _storage).setString(_dbLoginKey, authData.toJson());

      if (setLoginTokens) {
        final session =
            SessionData(isAuth: true, accessToken: authData.accessToken);
        _authController.add(session);
        return session;
      } else {
        throw Exception("tokens not saved");
      }
    } catch (e) {
      if (kDebugMode) {
        print("_login => $e");
      }
      return null;
    }
  }

  Future<SessionData?> _refreshSession() async {
    try {
      final String? loginDataString = (await _storage).getString(_dbLoginKey);
      if (loginDataString != null) {
        final loginData = AuthStorageData.fromJson(loginDataString);

        final TokenResponse? requestRefreshToken = await _appAuthService.token(
          TokenRequest(
            _configurations.clientId,
            _configurations.redirectUrl,
            discoveryUrl: _configurations.discoveryUrl,
            refreshToken: loginData.refreshToken,
            scopes: _configurations.scopes,
            additionalParameters: _configurations.additionalParameter,
          ),
        );

        if (!(requestRefreshToken?.accessToken != null &&
            requestRefreshToken?.idToken != null &&
            requestRefreshToken?.accessTokenExpirationDateTime != null &&
            requestRefreshToken?.refreshToken != null)) {
          throw Exception("requestRefresh value null");
        }

        final AuthStorageData refreshData = AuthStorageData(
          accessToken: requestRefreshToken!.accessToken!,
          expiryDate: requestRefreshToken.accessTokenExpirationDateTime!,
          refreshToken: requestRefreshToken.refreshToken!,
          idToken: requestRefreshToken.idToken!,
        );

        final setRefreshTokens =
            await (await _storage).setString(_dbLoginKey, refreshData.toJson());

        if (setRefreshTokens) {
          final session =
              SessionData(isAuth: true, accessToken: refreshData.accessToken);
          _authController.add(session);
          return session;
        } else {
          throw Exception("tokens not saved");
        }
      } else {
        throw Exception("accessToken not found");
      }
    } catch (e) {
      if (kDebugMode) {
        print("_refreshSession => $e");
      }
      return null;
    }
  }

  Future<void> _logout() async {
    final clearLoginTokens = await (await _storage).remove(_dbLoginKey);

    if (clearLoginTokens) {
      _authController.add(SessionData(isAuth: false, accessToken: null));
      return;
    }
  }

  Future<SessionData> _loadSession() async {
    try {
      final storageInstance = (await _storage).getString(_dbLoginKey);

      final loginSessionLoaded = storageInstance != null;

      if (loginSessionLoaded) {
        final loginData = AuthStorageData.fromJson(storageInstance);

        final dateNow = DateTime.now().toUtc();
        final expiryDate = loginData.expiryDate.toUtc();

        if (expiryDate.isAfter(dateNow)) {
          return SessionData(isAuth: true, accessToken: loginData.accessToken);
        }

        if (expiryDate.isBefore(dateNow)) {
          final refreshSession = await _refreshSession();
          if (refreshSession != null) {
            return refreshSession;
          }
        }
      } else {
        return SessionData(isAuth: false, accessToken: null);
      }

      return SessionData(isAuth: false, accessToken: null);
    } catch (e) {
      return SessionData(isAuth: false, accessToken: null);
    }
  }

  // end service
}

class AuthConfigurations {
  final String clientId;
  final String tenantId;
  final String redirectUrl;
  final String issuer;
  final String discoveryUrl;
  final String postLogoutRedirectUrl;
  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String endSessionEndpoint;
  final Map<String, String> additionalParameter;
  final List<String> scopes;

  AuthConfigurations({
    required this.clientId,
    required this.tenantId,
    required this.redirectUrl,
    required this.issuer,
    required this.discoveryUrl,
    required this.postLogoutRedirectUrl,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.endSessionEndpoint,
    required this.additionalParameter,
    required this.scopes,
  });

  AuthConfigurations copyWith({
    String? clientId,
    String? tenantId,
    String? redirectUrl,
    String? issuer,
    String? discoveryUrl,
    String? postLogoutRedirectUrl,
    String? authorizationEndpoint,
    String? tokenEndpoint,
    String? endSessionEndpoint,
    Map<String, String>? additionalParameter,
    List<String>? scopes,
  }) {
    return AuthConfigurations(
      clientId: clientId ?? this.clientId,
      tenantId: tenantId ?? this.tenantId,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      issuer: issuer ?? this.issuer,
      discoveryUrl: discoveryUrl ?? this.discoveryUrl,
      postLogoutRedirectUrl:
          postLogoutRedirectUrl ?? this.postLogoutRedirectUrl,
      authorizationEndpoint:
          authorizationEndpoint ?? this.authorizationEndpoint,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
      endSessionEndpoint: endSessionEndpoint ?? this.endSessionEndpoint,
      additionalParameter: additionalParameter ?? this.additionalParameter,
      scopes: scopes ?? this.scopes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'tenantId': tenantId,
      'redirectUrl': redirectUrl,
      'issuer': issuer,
      'discoveryUrl': discoveryUrl,
      'postLogoutRedirectUrl': postLogoutRedirectUrl,
      'authorizationEndpoint': authorizationEndpoint,
      'tokenEndpoint': tokenEndpoint,
      'endSessionEndpoint': endSessionEndpoint,
      'additionalParameter': additionalParameter,
      'scopes': scopes,
    };
  }

  factory AuthConfigurations.fromMap(Map<String, dynamic> map) {
    return AuthConfigurations(
      clientId: map['clientId'] ?? '',
      tenantId: map['tenantId'] ?? '',
      redirectUrl: map['redirectUrl'] ?? '',
      issuer: map['issuer'] ?? '',
      discoveryUrl: map['discoveryUrl'] ?? '',
      postLogoutRedirectUrl: map['postLogoutRedirectUrl'] ?? '',
      authorizationEndpoint: map['authorizationEndpoint'] ?? '',
      tokenEndpoint: map['tokenEndpoint'] ?? '',
      endSessionEndpoint: map['endSessionEndpoint'] ?? '',
      additionalParameter: Map<String, String>.from(map['additionalParameter']),
      scopes: List<String>.from(map['scopes']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthConfigurations.fromJson(String source) =>
      AuthConfigurations.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthConfigurations(clientId: $clientId, tenantId: $tenantId, redirectUrl: $redirectUrl, issuer: $issuer, discoveryUrl: $discoveryUrl, postLogoutRedirectUrl: $postLogoutRedirectUrl, authorizationEndpoint: $authorizationEndpoint, tokenEndpoint: $tokenEndpoint, endSessionEndpoint: $endSessionEndpoint, additionalParameter: $additionalParameter, scopes: $scopes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthConfigurations &&
        other.clientId == clientId &&
        other.tenantId == tenantId &&
        other.redirectUrl == redirectUrl &&
        other.issuer == issuer &&
        other.discoveryUrl == discoveryUrl &&
        other.postLogoutRedirectUrl == postLogoutRedirectUrl &&
        other.authorizationEndpoint == authorizationEndpoint &&
        other.tokenEndpoint == tokenEndpoint &&
        other.endSessionEndpoint == endSessionEndpoint &&
        mapEquals(other.additionalParameter, additionalParameter) &&
        listEquals(other.scopes, scopes);
  }

  @override
  int get hashCode {
    return clientId.hashCode ^
        tenantId.hashCode ^
        redirectUrl.hashCode ^
        issuer.hashCode ^
        discoveryUrl.hashCode ^
        postLogoutRedirectUrl.hashCode ^
        authorizationEndpoint.hashCode ^
        tokenEndpoint.hashCode ^
        endSessionEndpoint.hashCode ^
        additionalParameter.hashCode ^
        scopes.hashCode;
  }
}

class AuthStorageData {
  final String accessToken;
  final String idToken;
  final DateTime expiryDate;
  final String refreshToken;
  AuthStorageData({
    required this.accessToken,
    required this.idToken,
    required this.expiryDate,
    required this.refreshToken,
  });

  AuthStorageData copyWith({
    String? accessToken,
    String? idToken,
    DateTime? expiryDate,
    String? refreshToken,
  }) {
    return AuthStorageData(
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      expiryDate: expiryDate ?? this.expiryDate,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'idToken': idToken,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'refreshToken': refreshToken,
    };
  }

  factory AuthStorageData.fromMap(Map<String, dynamic> map) {
    return AuthStorageData(
      accessToken: map['accessToken'] ?? '',
      idToken: map['idToken'] ?? '',
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      refreshToken: map['refreshToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthStorageData.fromJson(String source) =>
      AuthStorageData.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AuthStorageData(accessToken: $accessToken, idToken: $idToken, expiryDate: $expiryDate, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthStorageData &&
        other.accessToken == accessToken &&
        other.idToken == idToken &&
        other.expiryDate == expiryDate &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        idToken.hashCode ^
        expiryDate.hashCode ^
        refreshToken.hashCode;
  }
}

class SessionData {
  final String? accessToken;
  final bool isAuth;

  SessionData({required this.isAuth, this.accessToken});
}
