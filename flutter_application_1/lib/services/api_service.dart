import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

// handles all api requests
class ApiService {
  // for session management
  static final Map<String, String> _sessionCookies = {};
  
  // sets session cookies after login
  static void setSessionCookies(Map<String, String> cookies) {
    _sessionCookies.clear();
    _sessionCookies.addAll(cookies);
  }
  
  // gets cookie header for requests
  static String getCookieHeader() {
    if (_sessionCookies.isEmpty) return '';
    return _sessionCookies.entries
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
  }
  
  // clears session cookies on logout
  static void clearSessionCookies() {
    _sessionCookies.clear();
  }
  
  // for user sign-up
  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required bool agreedTerms,
    required bool agreedPrivacy,
  }) async {
    try {
      print('Attempting to sign up with email: $email');
      print('API URL:  [32m${ApiConfig.baseUrl}${ApiConfig.signUpEndpoint} [0m');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signUpEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone': phoneNumber,
          'password': password,
          'agreed_terms': agreedTerms,
          'agreed_privacy': agreedPrivacy,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      print('Sign up response status: ${response.statusCode}');
      print('Sign up response body: ${response.body}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Sign up successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Sign up failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to sign up: $errorBody');
      }
    } catch (e) {
      print('Sign up error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // for user sign-in
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in with email: $email');
      print('API URL: ${ApiConfig.baseUrl}${ApiConfig.signInEndpoint}');
      
      // create a client to maintain cookies
      final client = http.Client();
      
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.signInEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );

      print('Sign in response status: ${response.statusCode}');
      print('Sign in response body: ${response.body}');
      print('Sign in response cookies: ${response.headers['set-cookie']}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Sign in successful: $responseData');
        
        // extract and store session cookies from the response
        final cookies = <String, String>{};
        final setCookieHeaders = response.headers['set-cookie'];
        if (setCookieHeaders != null) {
          // Find the connect.sid cookie specifically
          final cookieParts = setCookieHeaders.split(';');
          for (final part in cookieParts) {
            if (part.trim().startsWith('connect.sid=')) {
              final keyValue = part.trim().split('=');
              if (keyValue.length == 2) {
                cookies['connect.sid'] = keyValue[1];
              }
            }
          }
        }
        setSessionCookies(cookies);
        print('Session cookies stored: $cookies');
        
        client.close();
        return responseData;
      } else {
        final errorBody = response.body;
        print('Sign in failed with status ${response.statusCode}: $errorBody');
        client.close();
        throw Exception('Failed to sign in: $errorBody');
      }
    } catch (e) {
      print('Sign in error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // for forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('Attempting to send password reset for email: $email');
      print('API URL: ${ApiConfig.baseUrl}${ApiConfig.forgotPasswordEndpoint}');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.forgotPasswordEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Forgot password request successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Forgot password failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to send password reset: $errorBody');
      }
    } catch (e) {
      print('Forgot password error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // gets user profile
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      print('Attempting to get user profile');
      print('API URL: ${ApiConfig.baseUrl}${ApiConfig.userProfileEndpoint}');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfileEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );

      print('Get profile response status: ${response.statusCode}');
      print('Get profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Get profile successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Get profile failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to get profile: $errorBody');
      }
    } catch (e) {
      print('Get profile error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // tests backend connection
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: ${ApiConfig.baseUrl}');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'), // assuming your web app has a health endpoint
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: 5000), // shorter timeout for connection test
      );

      print('Connection test response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // verifies OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.verifyOtpEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // resets password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.resetPasswordEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // checks if a device is available
  static Future<Map<String, dynamic>> checkDeviceAvailable(String serialNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/devices/check'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'serial_number': serialNumber}),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // updates user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
    String? phone,
  }) async {
    try {
      print('Attempting to update profile');
      print('API URL:  [32m${ApiConfig.userBaseUrl}${ApiConfig.userProfileEndpoint} [0m');
      
      // create a client that maintains cookies for session
      final client = http.Client();
      
      // prepare headers with session cookies for authentication
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final cookieHeader = getCookieHeader();
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
        print('Including session cookies: $cookieHeader');
      }
      
      final response = await client.put(
        Uri.parse('${ApiConfig.userBaseUrl}${ApiConfig.userProfileEndpoint}'),
        headers: headers,
        body: jsonEncode({
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: ${response.body}');
      
      client.close();
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Update profile successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Update profile failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to update profile: $errorBody');
      }
    } catch (e) {
      print('Update profile error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Failed to update profile: $e');
    }
  }

  // fetches user profile
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // verifies current password
  static Future<Map<String, dynamic>> verifyCurrentPassword({
    required String token,
    required String currentPassword,
  }) async {
    try {
      print('Attempting to verify current password');
      print('API URL: ${ApiConfig.baseUrl}/auth/verify-password');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verify-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );

      print('Verify password response status: ${response.statusCode}');
      print('Verify password response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Verify password successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Verify password failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to verify password: $errorBody');
      }
    } catch (e) {
      print('Verify password error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // changes password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('Attempting to change password');
      print('API URL: ${ApiConfig.userBaseUrl}${ApiConfig.changePasswordEndpoint}');
      
      // create a client that maintains cookies for session
      final client = http.Client();
      
      // prepare headers with session cookies for authentication
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final cookieHeader = getCookieHeader();
      if (cookieHeader.isNotEmpty) {
        headers['Cookie'] = cookieHeader;
        print('Including session cookies: $cookieHeader');
      }
      
      final response = await client.post(
        Uri.parse('${ApiConfig.userBaseUrl}${ApiConfig.changePasswordEndpoint}'),
        headers: headers,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(
        Duration(milliseconds: ApiConfig.connectionTimeout),
      );
      
      print('Change password response status: ${response.statusCode}');
      print('Change password response body: ${response.body}');
      
      client.close();
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Change password successful: $responseData');
        return responseData;
      } else {
        final errorBody = response.body;
        print('Change password failed with status ${response.statusCode}: $errorBody');
        throw Exception('Failed to change password: $errorBody');
      }
    } catch (e) {
      print('Change password error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Network connection failed. Please check your internet connection and make sure the web app is running.');
      }
      throw Exception('Failed to change password: $e');
    }
  }
} 


