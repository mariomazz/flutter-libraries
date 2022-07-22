class WebTokenResponse {
  WebTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpirationDateTime,
    required this.idToken,
    this.tokenType,
    this.tokenAdditionalParameters,
  });

  /// The access token returned by the authorization server.
  final String accessToken;

  /// The refresh token returned by the authorization server.
  final String refreshToken;

  /// Indicates when [accessToken] will expire.
  ///
  /// To ensure applications have continue to use valid access tokens, they
  /// will generally use the refresh token to get a new access token
  /// before it expires.
  final DateTime accessTokenExpirationDateTime;

  /// The id token returned by the authorization server.
  final String idToken;

  /// The type of token returned by the authorization server.
  String? tokenType;

  /// Contains additional parameters returned by the authorization server from making the token request.
  Map<String, dynamic>? tokenAdditionalParameters;
}
