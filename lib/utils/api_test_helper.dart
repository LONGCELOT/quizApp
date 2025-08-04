import '../services/api_service.dart';
import '../services/token_service.dart';
import '../models/leaderboard.dart';

class APITestHelper {
  
  /// Test the General Quiz API endpoint
  static Future<void> testGeneralQuizAPI() async {
    print('🧪 Testing General Quiz API (/api/questions/list/by-category/1)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      print('🔑 Using token: ${token != null ? 'Available' : 'No token found'}');
      
      // Call the API for General Quiz (category 1)
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1,
        token: token,
      );
      
      print('✅ General Quiz API Success!');
      print('📊 Questions loaded: ${questions.length}');
      
      if (questions.isNotEmpty) {
        final firstQuestion = questions.first;
        print('📝 Sample question: ${firstQuestion['question']?.toString().substring(0, 50)}...');
        print('🔤 Options count: ${firstQuestion['options']?.length ?? 0}');
        print('✔️ Answer: ${firstQuestion['answer']}');
      }
      
    } catch (e) {
      print('❌ General Quiz API Error: $e');
    }
  }
  
  /// Test the Top Users/Leaderboard API endpoint
  static Future<void> testLeaderboardAPI() async {
    print('🧪 Testing Leaderboard API (/api/report/top10/player)...');
    
    try {
      // Get authentication token
      final token = await TokenService.getToken();
      print('🔑 Using token: ${token != null ? 'Available' : 'No token found'}');
      
      // Call the leaderboard API
      final leaderboardData = await ApiService.getLeaderboard(token: token);
      
      print('✅ Leaderboard API Success!');
      print('📊 Users loaded: ${leaderboardData.length}');
      
      if (leaderboardData.isNotEmpty) {
        // Parse the first user
        final firstUserData = leaderboardData.first;
        final firstUser = LeaderboardUser.fromJson(firstUserData);
        
        print('🏆 Top User:');
        print('   - User ID: ${firstUser.userId}');
        print('   - Name: ${firstUser.displayName}');
        print('   - Score: ${firstUser.totalScore}');
        print('   - Raw data: $firstUserData');
      }
      
    } catch (e) {
      print('❌ Leaderboard API Error: $e');
    }
  }
  
  /// Test both APIs
  static Future<void> testBothAPIs() async {
    print('🚀 Starting API Tests...\n');
    
    await testGeneralQuizAPI();
    print(''); // Empty line for separation
    await testLeaderboardAPI();
    
    print('\n🏁 API Testing completed!');
  }
}
