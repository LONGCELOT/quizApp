import '../services/api_service.dart';
import '../services/token_service.dart';
import '../models/user_profile.dart';

class ProfileAPITestHelper {
  
  /// Test the Get User Profile API endpoint
  static Future<void> testGetUserProfileAPI() async {
    print('🧪 Testing Get User Profile API (/api/profile/info)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      print('🔑 Using token: Available');
      
      // Call the API to get user profile
      final profileData = await ApiService.getUserProfile(token);
      final profile = UserProfile.fromJson(profileData);
      
      print('✅ Get User Profile API Success!');
      print('👤 User Details:');
      print('   - ID: ${profile.id}');
      print('   - Name: ${profile.displayName}');
      print('   - Phone: ${profile.fullPhoneNumber}');
      print('   - Username: ${profile.username ?? 'Not set'}');
      print('   - Created: ${profile.createdAt}');
      print('   - Updated: ${profile.updatedAt}');
      print('📋 Raw response: $profileData');
      
    } catch (e) {
      print('❌ Get User Profile API Error: $e');
    }
  }
  
  /// Test the Update User Profile API endpoint
  static Future<void> testUpdateUserProfileAPI() async {
    print('🧪 Testing Update User Profile API (/api/profile/info/update)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      print('🔑 Using token: Available');
      
      // First get current profile
      final currentProfileData = await ApiService.getUserProfile(token);
      final currentProfile = UserProfile.fromJson(currentProfileData);
      print('📋 Current profile: ${currentProfile.displayName}');
      
      // Test update with sample data (modify only firstName)
      final testFirstName = 'UpdatedName_${DateTime.now().millisecondsSinceEpoch}';
      
      final updateResponse = await ApiService.updateUserProfile(
        token: token,
        firstName: testFirstName,
        // Keep other fields as they are
        lastName: currentProfile.lastName,
      );
      
      print('✅ Update User Profile API Success!');
      print('📊 Update response: $updateResponse');
      
      // Verify the update by getting profile again
      final updatedProfileData = await ApiService.getUserProfile(token);
      final updatedProfile = UserProfile.fromJson(updatedProfileData);
      
      if (updatedProfile.firstName == testFirstName) {
        print('✅ Profile update verified successfully!');
        print('   - Updated firstName: ${updatedProfile.firstName}');
      } else {
        print('⚠️ Profile update verification failed');
        print('   - Expected: $testFirstName');
        print('   - Actual: ${updatedProfile.firstName}');
      }
      
    } catch (e) {
      print('❌ Update User Profile API Error: $e');
    }
  }
  
  /// Test the Change Password API endpoint
  static Future<void> testChangePasswordAPI() async {
    print('🧪 Testing Change Password API (/api/profile/password/change)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      print('🔑 Using token: Available');
      
      // Test with a sample new password
      // NOTE: In a real test, you might want to change it back afterward
      final testPassword = 'TestPassword123!';
      
      final response = await ApiService.changePassword(
        token: token,
        newPassword: testPassword,
      );
      
      print('✅ Change Password API Success!');
      print('📊 Response: $response');
      print('⚠️ WARNING: Password has been changed to: $testPassword');
      print('📝 You may need to update your login credentials');
      
    } catch (e) {
      print('❌ Change Password API Error: $e');
    }
  }
  
  /// Test all Profile APIs
  static Future<void> testAllProfileAPIs() async {
    print('🚀 Starting Profile API Tests...\n');
    
    await testGetUserProfileAPI();
    print(''); // Empty line for separation
    
    await testUpdateUserProfileAPI();
    print(''); // Empty line for separation
    
    // WARNING: Uncomment this only if you want to test password change
    // await testChangePasswordAPI();
    print('⚠️ Change Password API test skipped for safety');
    print('   Uncomment in testAllProfileAPIs() to test password change');
    
    print('\n🏁 Profile API Testing completed!');
  }
  
  /// Safe test that only reads data (no modifications)
  static Future<void> testReadOnlyAPIs() async {
    print('🔍 Starting Read-Only Profile API Tests...\n');
    
    await testGetUserProfileAPI();
    
    print('\n✅ Read-Only Profile API Testing completed!');
  }
}
