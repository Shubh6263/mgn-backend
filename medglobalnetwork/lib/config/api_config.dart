class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String registerEndpoint = '/api/v1/auth/register';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String profileEndpoint = '/api/v1/users/me';
}
