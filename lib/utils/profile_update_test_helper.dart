import '../services/api_service.dart';
import '../services/token_service.dart';
import '../models/user_profile.dart';

class ProfileUpdateTestHelper {
  
  /// Test the fixed Update User Profile API (without username)
  static Future<void> testFixedUpdateProfileAPI() async {
    print('🔧 Testing FIXED Update User Profile API...');
    print('📝 This test excludes username field to avoid 404 errors');
    print('=' * 60);
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      print('🔑 Authentication token: Available');
      
      // First get current profile
      print('\n📋 Fetching current profile...');
      final currentProfileData = await ApiService.getUserProfile(token);
      final currentProfile = UserProfile.fromJson(currentProfileData);
      
      print('✅ Current Profile Retrieved:');
      print('   - Name: ${currentProfile.displayName}');
      print('   - Username: ${currentProfile.username ?? 'Not set'} (READ-ONLY)');
      print('   - Phone: ${currentProfile.fullPhoneNumber}');
      
      // Test update with sample data (only firstName and lastName)
      final testFirstName = 'TestName_${DateTime.now().millisecondsSinceEpoch}';
      final testLastName = 'UpdatedLast';
      
      print('\n🔄 Testing profile update...');
      print('   - New firstName: $testFirstName');
      print('   - New lastName: $testLastName');
      print('   - Username: NOT INCLUDED (read-only)');
      
      final updateResponse = await ApiService.updateUserProfile(
        token: token,
        firstName: testFirstName,
        lastName: testLastName,
      );
      
      print('✅ Update API call successful!');
      print('📊 Update response: $updateResponse');
      
      // Verify the update by getting profile again
      print('\n🔍 Verifying update...');
      final updatedProfileData = await ApiService.getUserProfile(token);
      final updatedProfile = UserProfile.fromJson(updatedProfileData);
      
      bool firstNameUpdated = updatedProfile.firstName == testFirstName;
      bool lastNameUpdated = updatedProfile.lastName == testLastName;
      
      if (firstNameUpdated && lastNameUpdated) {
        print('✅ Profile update verified successfully!');
        print('   - ✓ firstName updated: ${updatedProfile.firstName}');
        print('   - ✓ lastName updated: ${updatedProfile.lastName}');
        print('   - ℹ️ username unchanged: ${updatedProfile.username ?? 'Not set'} (as expected)');
      } else {
        print('⚠️ Profile update verification issues:');
        if (!firstNameUpdated) {
          print('   - ❌ firstName: Expected "$testFirstName", Got "${updatedProfile.firstName}"');
        }
        if (!lastNameUpdated) {
          print('   - ❌ lastName: Expected "$testLastName", Got "${updatedProfile.lastName}"');
        }
      }
      
      print('\n' + '=' * 60);
      print('🎉 FIXED UPDATE PROFILE API TEST COMPLETED!');
      print('📝 The username field is now read-only and excluded from updates');
      print('=' * 60);
      
    } catch (e) {
      print('❌ Fixed Update Profile API Error: $e');
      print('📝 If you still see errors, please check:');
      print('   1. Authentication token validity');
      print('   2. Network connectivity');
      print('   3. API endpoint availability');
      print('   4. Server-side validation rules');
    }
  }
  
  /// Quick test to verify profile reading still works
  static Future<void> testProfileReading() async {
    print('📖 Quick Profile Read Test...');
    
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      
      final profileData = await ApiService.getUserProfile(token);
      final profile = UserProfile.fromJson(profileData);
      
      print('✅ Profile read successful!');
      print('   - User: ${profile.displayName}');
      print('   - Phone: ${profile.fullPhoneNumber}');
      print('   - Username: ${profile.username ?? 'Not set'}');
      
    } catch (e) {
      print('❌ Profile read failed: $e');
    }
  }
}
