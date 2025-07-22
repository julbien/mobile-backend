import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// handles user auth and session
class AuthService {
  // keys for local storage
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userUsernameKey = 'user_username';
  static const String _userPhoneKey = 'user_phone';
  static const String _rememberMeKey = 'remember_me';
  static const String _rememberedEmailKey = 'remembered_email';

  // saves auth token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // gets auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // saves user data locally
  static Future<void> saveUserData({
    required String userId,
    required String email,
    String? username,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    if (username != null) {
      await prefs.setString(_userUsernameKey, username);
    }
    if (phone != null) {
      await prefs.setString(_userPhoneKey, phone);
    }
  }

  // gets user data from local storage
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_userEmailKey),
      'username': prefs.getString(_userUsernameKey),
      'phone': prefs.getString(_userPhoneKey),
    };
  }

  // checks if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // saves "Remember Me" preference
  static Future<void> saveRememberMe(bool rememberMe, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await prefs.setString(_rememberedEmailKey, email);
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
  }

  // gets "Remember Me" preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // gets remembered email
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberedEmailKey);
  }

  // logs out the user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userUsernameKey);
    await prefs.remove(_userPhoneKey);
    // clears session cookies
    ApiService.clearSessionCookies();
  }
} 