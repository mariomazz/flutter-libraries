class WebTokenRequest {
  String clientId;
  String redirectUrl;
  final String authorizationEndpoint;
  final String tokenEndpoint;

  String? clientSecret;
  List<String>? scopes;
  String? issuer;
  String? discoveryUrl;
  Map<String, String>? parameter;
  bool allowInsecureConnections;
  bool preferEphemeralSession;
  WebTokenRequest({
    required this.clientId,
    required this.redirectUrl,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.parameter,
    this.clientSecret,
    this.scopes,
    this.issuer,
    this.discoveryUrl,
    this.allowInsecureConnections = false,
    this.preferEphemeralSession = false,
  });
}
