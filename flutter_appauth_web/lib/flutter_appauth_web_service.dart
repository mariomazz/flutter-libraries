import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'app_auth_web_plugin.dart';
import 'web_token_request.dart';
import 'web_token_response.dart';

class FlutterAppAuthWeb {
  final AppAuthWebPlugin _appAuthWebPlugin = AppAuthWebPlugin();

  FlutterAppAuthWeb._privateConstructor();

  static final FlutterAppAuthWeb instance =
      FlutterAppAuthWeb._privateConstructor();

  factory FlutterAppAuthWeb() {
    return instance;
  }

  Future<WebTokenResponse?> authenticate(WebTokenRequest request) async {
    final response = await _appAuthWebPlugin.authorizeAndExchangeCode(
      AuthorizationTokenRequest(request.clientId, request.redirectUrl,
          issuer: request.issuer,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: request.authorizationEndpoint,
            tokenEndpoint: request.tokenEndpoint,
          ),
          scopes: request.scopes,
          preferEphemeralSession: false,
          additionalParameters: request.parameter),
    );

    if (response != null) {
      final asfTokenResponse = WebTokenResponse(
          accessToken: response.accessToken ?? "",
          refreshToken: response.refreshToken ?? "",
          accessTokenExpirationDateTime:
              response.accessTokenExpirationDateTime ?? DateTime.now(),
          idToken: response.idToken ?? "",
          tokenType: response.tokenType,
          tokenAdditionalParameters: response.tokenAdditionalParameters);
      return asfTokenResponse;
    }
    return null;
  }

  Future<WebTokenResponse?> refresh(
      String refreshToken, WebTokenRequest request) async {
    try {
      if (refreshToken == '') {
        throw Exception('Refresh token can\'t be empty');
      }

      final TokenResponse response = await _appAuthWebPlugin.token(
        TokenRequest(
          request.clientId,
          request.redirectUrl,
          discoveryUrl: request.discoveryUrl,
          refreshToken: refreshToken,
          scopes: request.scopes,
          additionalParameters: request.parameter,
          grantType: "refresh_token",
        ),
      );
      final refreshTokenResponse = WebTokenResponse(
        accessToken: response.accessToken ?? "",
        refreshToken: response.refreshToken ?? "",
        accessTokenExpirationDateTime:
            response.accessTokenExpirationDateTime ?? DateTime.now(),
        idToken: response.idToken ?? "",
      );
      return refreshTokenResponse;
    } catch (e) {
      throw Exception('Refresh token request failed');
    }
  }
}
