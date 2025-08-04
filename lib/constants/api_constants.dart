class ApiConstants {

  static const String baseUrl = 'https://quiz-api.camtech-dev.online';
  
  // API Endpoints
  // Home Screen API
  static const String homeEndpoint = '/api/home';

  // Authentication Endpoints
  static const String authEndpoint = '/api/auth';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String sendOtpEndpoint = '/api/auth/otp/send';
  static const String resetPasswordEndpoint = '/api/auth/password/reset';

  // Quiz Endpoints questions and categories and Top 10
  static const String quizCategoriesListEndpoint = '/api/quiz/list';
  static const String generalQuizEndpoint = '/api/questions/list/by-category/1'; // Called when user clicks "General Quiz" in quiz screen
  static const String questionsByCategoryEndpoint = '/api/questions/list/by-category'; // Base endpoint for dynamic category IDs
  
  // Specific category endpoints
  static const String iqTestEndpoint = '/api/questions/list/by-category/2';
  static const String eqTestEndpoint = '/api/questions/list/by-category/3';
  static const String worldHistoryEndpoint = '/api/questions/list/by-category/4';
  static const String khmerHistoryEndpoint = '/api/questions/list/by-category/5';
  static const String englishGrammarEndpoint = '/api/questions/list/by-category/6';
  static const String mathTestEndpoint = '/api/questions/list/by-category/7';
  static const String physicTestEndpoint = '/api/questions/list/by-category/8';

  static const String quizSubmitEndpoint = '/api/report/submit';
  static const String leaderboardEndpoint = '/api/report/top10/player'; // Called in Top Users screen to get leaderboard data

  // user profile
  static const String userProfileEndpoint = '/api/profile/info';
  static const String userUpdateProfileEndpoint = '/api/profile/info/update';
  static const String userUpdatePasswordEndpoint = '/api/profile/password/change';
  
  
  // Helper method to construct full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  // Helper method to build URL with query parameters
  static String buildUrlWithParams(String endpoint, Map<String, String>? params) {
    String url = '$baseUrl$endpoint';
    if (params != null && params.isNotEmpty) {
      String queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$queryString';
    }
    return url;
  }
  
  // Helper method to get questions endpoint by category ID
  static String getQuestionsByCategoryEndpoint(int categoryId) {
    switch (categoryId) {
      case 1:
        return generalQuizEndpoint;
      case 2:
        return iqTestEndpoint;
      case 3:
        return eqTestEndpoint;
      case 4:
        return worldHistoryEndpoint;
      case 5:
        return khmerHistoryEndpoint;
      case 6:
        return englishGrammarEndpoint;
      case 7:
        return mathTestEndpoint;
      case 8:
        return physicTestEndpoint;
      default:
        return '$questionsByCategoryEndpoint/$categoryId';
    }
  }
}
