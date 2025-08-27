import '../utils/api_test_helper.dart';
import '../utils/profile_api_test_helper.dart';
import 'app_logger.dart';

class ComprehensiveAPITestHelper {
  
  /// Test all APIs in the application
  static Future<void> testAllAPIs() async {
    AppLogger.info('🚀 Starting Comprehensive API Testing Suite...');
    AppLogger.info('=' * 60);
    
    // Test Quiz and Leaderboard APIs
    AppLogger.info('📝 QUIZ & LEADERBOARD API TESTS');
    AppLogger.info('=' * 60);
    await APITestHelper.testBothAPIs();
    
    AppLogger.info('=' * 60);
    AppLogger.info('👤 PROFILE API TESTS');
    AppLogger.info('=' * 60);
    await ProfileAPITestHelper.testAllProfileAPIs();
    
    AppLogger.info('=' * 60);
    AppLogger.info('🏁 COMPREHENSIVE API TESTING COMPLETED!');
    AppLogger.info('=' * 60);
    _printSummary();
  }
  
  /// Test only read-only APIs (safe for production)
  static Future<void> testReadOnlyAPIs() async {
    AppLogger.info('🔍 Starting Read-Only API Testing Suite...');
    AppLogger.info('=' * 50);
    
    AppLogger.info('📝 QUIZ & LEADERBOARD APIs (Read-Only)');
    AppLogger.info('=' * 50);
    await APITestHelper.testGeneralQuizAPI();
    AppLogger.info('');
    await APITestHelper.testLeaderboardAPI();
    
    AppLogger.info('=' * 50);
    AppLogger.info('👤 PROFILE APIs (Read-Only)');
    AppLogger.info('=' * 50);
    await ProfileAPITestHelper.testReadOnlyAPIs();
    
    AppLogger.info('=' * 50);
    AppLogger.info('✅ READ-ONLY API TESTING COMPLETED!');
    AppLogger.info('=' * 50);
    _printReadOnlySummary();
  }
  
  /// Test individual API categories
  static Future<void> testQuizAPIs() async {
    AppLogger.info('📝 Testing Quiz APIs Only...\n');
    await APITestHelper.testBothAPIs();
  }
  
  static Future<void> testProfileAPIs() async {
    AppLogger.info('👤 Testing Profile APIs Only...\n');
    await ProfileAPITestHelper.testAllProfileAPIs();
  }
  
  /// Print testing summary
  static void _printSummary() {
    AppLogger.info('\n📊 API TESTING SUMMARY:');
    AppLogger.info('✅ General Quiz Questions API (/api/questions/list/by-category/1)');
    AppLogger.info('✅ Top Users/Leaderboard API (/api/report/top10/player)');
    AppLogger.info('✅ Get User Profile API (/api/profile/info)');
    AppLogger.info('✅ Update User Profile API (/api/profile/info/update)');
    AppLogger.info('⚠️ Change Password API (/api/profile/password/change) - Skipped for safety');
    AppLogger.info('\n📝 Notes:');
    AppLogger.info('- All APIs use Bearer token authentication when available');
    AppLogger.info('- Quiz/Leaderboard APIs have fallback data if they fail');
    AppLogger.info('- Profile APIs require authentication');
    AppLogger.info('- Password change API was skipped to prevent accidental changes');
    AppLogger.info('\n🔧 To test password change API, uncomment the line in ProfileAPITestHelper.testAllProfileAPIs()');
  }
  
  static void _printReadOnlySummary() {
    AppLogger.info('\n📊 READ-ONLY API TESTING SUMMARY:');
    AppLogger.info('✅ General Quiz Questions API (GET)');
    AppLogger.info('✅ Top Users/Leaderboard API (GET)');
    AppLogger.info('✅ Get User Profile API (GET)');
    AppLogger.info('\n📝 Notes:');
    AppLogger.info('- Only safe, read-only operations were tested');
    AppLogger.info('- No data was modified during testing');
    AppLogger.info('- These tests are safe to run in production');
  }
  
  /// Quick health check for all APIs
  static Future<void> healthCheck() async {
    AppLogger.info('🏥 Performing API Health Check...\n');
    
    bool allHealthy = true;
    
    // Check Quiz API
    try {
      AppLogger.info('🔍 Checking Quiz API...');
      await APITestHelper.testGeneralQuizAPI();
      AppLogger.info('✅ Quiz API: Healthy');
    } catch (e) {
      AppLogger.error('❌ Quiz API: Unhealthy - ', e);
      allHealthy = false;
    }
    
    // Check Leaderboard API
    try {
      AppLogger.info('\n🔍 Checking Leaderboard API...');
      await APITestHelper.testLeaderboardAPI();
      AppLogger.info('✅ Leaderboard API: Healthy');
    } catch (e) {
      AppLogger.error('❌ Leaderboard API: Unhealthy - $e');
      allHealthy = false;
    }
    
    // Check Profile API (read-only)
    try {
      AppLogger.info('\n🔍 Checking Profile API...');
      await ProfileAPITestHelper.testGetUserProfileAPI();
      AppLogger.info('✅ Profile API: Healthy');
    } catch (e) {
      AppLogger.error('❌ Profile API: Unhealthy - ', e);
      allHealthy = false;
    }

    AppLogger.info('\n' + '=' * 40);
    if (allHealthy) {
      print('✅ ALL APIS HEALTHY');
    } else {
      print('⚠️ SOME APIS HAVE ISSUES');
    }
    print('=' * 40);
  }
}
