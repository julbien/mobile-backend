// API configurations
class ApiConfig {
  // link for backend
  static const String baseUrl = 'https://mobile-backend-tt6t.onrender.com';
  // user related API link 
  static const String userBaseUrl = 'https://mobile-backend-tt6t.onrender.com/api/user';

  static const String signUpEndpoint = '/api/auth/register';
  static const String signInEndpoint = '/api/auth/login';
  static const String userProfileEndpoint = '/profile';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password/';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';
  static const String healthEndpoint = '/health';
  static const String changePasswordEndpoint = '/change-password';

  // connection timeout in miliseconds
  static const int connectionTimeout = 30000;
  // recieve timeout in miliseconds
  static const int receiveTimeout = 30000;
  // for debug prints
  static const bool debugMode = true;
}