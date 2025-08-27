import '../services/api_service.dart';
import '../services/token_service.dart';
import '../models/leaderboard.dart';
import 'app_logger.dart';

class APITestHelper {
  
  /// Test the General Quiz API endpoint
  static Future<void> testGeneralQuizAPI() async {
    AppLogger.info('🧪 Testing General Quiz API (/api/questions/list/by-category/1)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      AppLogger.info('🔑 Using token: ${token != null ? 'Available' : 'No token found'}');
      
      // Call the API for General Quiz (category 1)
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1,
        token: token,
      );
      AppLogger.info('✅ General Quiz API Success!');
      AppLogger.info('📊 Questions loaded: ${questions.length}');
      
      if (questions.isNotEmpty) {
        final firstQuestion = questions.first;
        AppLogger.info('📝 Sample question: ${firstQuestion['question']?.toString().substring(0, 50)}...');
        AppLogger.info('🔤 Options count: ${firstQuestion['options']?.length ?? 0}');
        AppLogger.info('✔️ Answer: ${firstQuestion['answer']}');
      }
      
    } catch (e) {
      AppLogger.error('❌ General Quiz API Error: $e');
    }
  }
  
  /// Test the Top Users/Leaderboard API endpoint
  static Future<void> testLeaderboardAPI() async {
    AppLogger.info('🧪 Testing Leaderboard API (/api/report/top10/player)...');

    try {
      // Get authentication token
      final token = await TokenService.getToken();
      AppLogger.info('🔑 Using token: ${token != null ? 'Available' : 'No token found'}');

      // Call the leaderboard API
      final leaderboardData = await ApiService.getLeaderboard(token: token);

      AppLogger.info('✅ Leaderboard API Success!');
      AppLogger.info('📊 Users loaded: ${leaderboardData.length}');
      
      if (leaderboardData.isNotEmpty) {
        // Parse the first user
        final firstUserData = leaderboardData.first;
        final firstUser = LeaderboardUser.fromJson(firstUserData);
        AppLogger.info('🏆 Top User:');
        AppLogger.info('   - User ID: ${firstUser.userId}');
        AppLogger.info('   - Name: ${firstUser.displayName}');
        AppLogger.info('   - Score: ${firstUser.totalScore}');
        AppLogger.info('   - Raw data: $firstUserData');
      }
      
    } catch (e) {
      AppLogger.error('❌ Leaderboard API Error: $e');
    }
  }
  
  /// Test both APIs
  static Future<void> testBothAPIs() async {
    AppLogger.info('🚀 Starting API Tests...\n');

    await testGeneralQuizAPI();
    AppLogger.info(''); // Empty line for separation
    await testLeaderboardAPI();

    AppLogger.info('\n🏁 API Testing completed!');
  }
}
