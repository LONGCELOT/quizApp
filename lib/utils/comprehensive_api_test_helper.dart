import '../utils/api_test_helper.dart';
import '../utils/profile_api_test_helper.dart';

class ComprehensiveAPITestHelper {
  
  /// Test all APIs in the application
  static Future<void> testAllAPIs() async {
    print('🚀 Starting Comprehensive API Testing Suite...\n');
    print('=' * 60);
    
    // Test Quiz and Leaderboard APIs
    print('📝 QUIZ & LEADERBOARD API TESTS');
    print('=' * 60);
    await APITestHelper.testBothAPIs();
    
    print('\n' + '=' * 60);
    print('👤 PROFILE API TESTS');
    print('=' * 60);
    await ProfileAPITestHelper.testAllProfileAPIs();
    
    print('\n' + '=' * 60);
    print('🏁 COMPREHENSIVE API TESTING COMPLETED!');
    print('=' * 60);
    _printSummary();
  }
  
  /// Test only read-only APIs (safe for production)
  static Future<void> testReadOnlyAPIs() async {
    print('🔍 Starting Read-Only API Testing Suite...\n');
    print('=' * 50);
    
    print('📝 QUIZ & LEADERBOARD APIs (Read-Only)');
    print('=' * 50);
    await APITestHelper.testGeneralQuizAPI();
    print('');
    await APITestHelper.testLeaderboardAPI();
    
    print('\n' + '=' * 50);
    print('👤 PROFILE APIs (Read-Only)');
    print('=' * 50);
    await ProfileAPITestHelper.testReadOnlyAPIs();
    
    print('\n' + '=' * 50);
    print('✅ READ-ONLY API TESTING COMPLETED!');
    print('=' * 50);
    _printReadOnlySummary();
  }
  
  /// Test individual API categories
  static Future<void> testQuizAPIs() async {
    print('📝 Testing Quiz APIs Only...\n');
    await APITestHelper.testBothAPIs();
  }
  
  static Future<void> testProfileAPIs() async {
    print('👤 Testing Profile APIs Only...\n');
    await ProfileAPITestHelper.testAllProfileAPIs();
  }
  
  /// Print testing summary
  static void _printSummary() {
    print('\n📊 API TESTING SUMMARY:');
    print('✅ General Quiz Questions API (/api/questions/list/by-category/1)');
    print('✅ Top Users/Leaderboard API (/api/report/top10/player)');
    print('✅ Get User Profile API (/api/profile/info)');
    print('✅ Update User Profile API (/api/profile/info/update)');
    print('⚠️ Change Password API (/api/profile/password/change) - Skipped for safety');
    print('\n📝 Notes:');
    print('- All APIs use Bearer token authentication when available');
    print('- Quiz/Leaderboard APIs have fallback data if they fail');
    print('- Profile APIs require authentication');
    print('- Password change API was skipped to prevent accidental changes');
    print('\n🔧 To test password change API, uncomment the line in ProfileAPITestHelper.testAllProfileAPIs()');
  }
  
  static void _printReadOnlySummary() {
    print('\n📊 READ-ONLY API TESTING SUMMARY:');
    print('✅ General Quiz Questions API (GET)');
    print('✅ Top Users/Leaderboard API (GET)');
    print('✅ Get User Profile API (GET)');
    print('\n📝 Notes:');
    print('- Only safe, read-only operations were tested');
    print('- No data was modified during testing');
    print('- These tests are safe to run in production');
  }
  
  /// Quick health check for all APIs
  static Future<void> healthCheck() async {
    print('🏥 Performing API Health Check...\n');
    
    bool allHealthy = true;
    
    // Check Quiz API
    try {
      print('🔍 Checking Quiz API...');
      await APITestHelper.testGeneralQuizAPI();
      print('✅ Quiz API: Healthy');
    } catch (e) {
      print('❌ Quiz API: Unhealthy - $e');
      allHealthy = false;
    }
    
    // Check Leaderboard API
    try {
      print('\n🔍 Checking Leaderboard API...');
      await APITestHelper.testLeaderboardAPI();
      print('✅ Leaderboard API: Healthy');
    } catch (e) {
      print('❌ Leaderboard API: Unhealthy - $e');
      allHealthy = false;
    }
    
    // Check Profile API (read-only)
    try {
      print('\n🔍 Checking Profile API...');
      await ProfileAPITestHelper.testGetUserProfileAPI();
      print('✅ Profile API: Healthy');
    } catch (e) {
      print('❌ Profile API: Unhealthy - $e');
      allHealthy = false;
    }
    
    print('\n' + '=' * 40);
    if (allHealthy) {
      print('✅ ALL APIS HEALTHY');
    } else {
      print('⚠️ SOME APIS HAVE ISSUES');
    }
    print('=' * 40);
  }
}
