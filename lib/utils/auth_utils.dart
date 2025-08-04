import '../services/auth_manager.dart';

/// Utility functions for authentication flow
class AuthUtils {
  /// Check if app should show login screen or main app
  static Future<bool> shouldShowLogin() async {
    return await AuthManager.needsLogin();
  }

  /// Get user display name if available
  static Future<String> getUserDisplayName() async {
    final userData = await AuthManager.getCurrentUser();
    if (userData != null && userData['name'] != null) {
      return userData['name'];
    }
    return 'User';
  }

  /// Check if user has valid session
  static Future<bool> hasValidSession() async {
    return await AuthManager.isAuthenticated();
  }
}
