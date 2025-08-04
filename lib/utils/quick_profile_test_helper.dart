import '../services/api_service.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';

class QuickProfileTestHelper {
  
  /// Quick test to see exactly what's being sent
  static Future<void> testProfileUpdate() async {
    print('🧪 Quick Profile Update Test');
    print('=' * 40);
    
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No token found');
        return;
      }
      
      print('🔗 Testing URL: ${ApiConstants.baseUrl}${ApiConstants.userUpdateProfileEndpoint}');
      print('📝 Request method: POST (changed from PUT)');
      print('🔑 Token: ${token.substring(0, 20)}...');
      
      // Simple test data
      await ApiService.updateUserProfile(
        token: token,
        firstName: 'Test',
        lastName: 'User',
      );
      
      print('✅ SUCCESS: Profile update worked!');
      
    } catch (e) {
      print('❌ FAILED: $e');
      print('\n💡 Common causes of 404:');
      print('1. Wrong HTTP method (we changed PUT → POST)');
      print('2. Wrong endpoint URL');
      print('3. Missing authentication');
      print('4. API not deployed/available');
    }
  }
}
