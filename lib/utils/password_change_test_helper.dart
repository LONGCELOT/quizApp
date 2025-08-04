import '../services/api_service.dart';
import '../services/token_service.dart';

/// Quick test helper for password change API
class PasswordChangeTestHelper {
  static Future<void> testPasswordChange() async {
    print('🔑 Testing Password Change API');
    print('Endpoint: /api/profile/password/change');
    print('Method: POST');
    print('----------------------------------------');

    try {
      // Get token
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      print('✅ Token retrieved');

      // Test password change
      print('📤 Making password change request...');
      final result = await ApiService.changePassword(
        token: token,
        newPassword: 'newPassword123', // Test password
      );

      print('✅ Password change successful!');
      print('📥 Response: $result');

    } catch (e) {
      print('❌ Password change failed: $e');
      
      // Parse error details
      String errorStr = e.toString();
      if (errorStr.contains('404')) {
        print('💡 404 Error - Check if endpoint exists');
      } else if (errorStr.contains('401')) {
        print('💡 401 Error - Authentication issue');
      } else if (errorStr.contains('400')) {
        print('💡 400 Error - Bad request format');
      } else if (errorStr.contains('500')) {
        print('💡 500 Error - Server error');
      }
    }

    print('----------------------------------------');
  }

  /// Test with different password formats
  static Future<void> testDifferentPasswords() async {
    final passwords = [
      'password123',
      'newPass456',
      'TestPassword789',
    ];

    print('🔑 Testing different password formats');
    print('----------------------------------------');

    for (String password in passwords) {
      print('Testing password: $password');
      
      try {
        final token = await TokenService.getToken();
        if (token == null) {
          print('❌ No token');
          continue;
        }

        final result = await ApiService.changePassword(
          token: token,
          newPassword: password,
        );

        print('✅ Success with password: $password');
        print('Response: $result');
        break; // Stop after first success
        
      } catch (e) {
        print('❌ Failed with password: $password - $e');
      }
    }
    print('----------------------------------------');
  }
}
