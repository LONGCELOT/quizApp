import 'token_service.dart';

/// Simple authentication manager for checking login status
class AuthManager {
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      // Check if token exists
      if (!await TokenService.hasValidToken()) {
        return false;
      }

      // Optionally verify token with server
      // You can add an API call here to validate the token if your API supports it
      // For example:
      // try {
      //   await ApiService.authenticatedRequest('/verify-token', 'GET');
      //   return true;
      // } catch (e) {
      //   await TokenService.clearStorage();
      //   return false;
      // }
      
      return true;
    } catch (e) {
      // If verification fails, clear storage
      await TokenService.clearStorage();
      return false;
    }
  }

  /// Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    if (await isAuthenticated()) {
      return await TokenService.getUserData();
    }
    return null;
  }

  /// Get current auth token
  static Future<String?> getCurrentToken() async {
    if (await isAuthenticated()) {
      return await TokenService.getToken();
    }
    return null;
  }

  /// Logout user
  static Future<void> logout() async {
    await TokenService.clearStorage();
  }

  /// Check if user needs to login
  static Future<bool> needsLogin() async {
    return !(await isAuthenticated());
  }
}
