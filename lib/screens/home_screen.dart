import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/home_data.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🌐 Language
  String _languageCode = 'en';
  final List<String> _languages = ['en', 'zh', 'kh'];
  int _currentLanguageIndex = 0;

  // 🔁 Banner page controller and current index
  final PageController _bannerPageController = PageController();
  int _currentBannerIndex = 0;

  // 📊 Data from API
  HomeData? _homeData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  void _switchLanguage() {
    setState(() {
      _currentLanguageIndex = (_currentLanguageIndex + 1) % _languages.length;
      _languageCode = _languages[_currentLanguageIndex];
    });
  }

  Future<void> _fetchHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final homeDataMap = await ApiService.fetchHomeData();
      
      setState(() {
        _homeData = HomeData(
          categories: homeDataMap['categories'] as List<Category>,
          banners: homeDataMap['banners'] as List<BannerItem>,
          promotions: homeDataMap['promotions'] as List<Promotion>,
        );
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data when API fails
      setState(() {
        _homeData = _createMockData();
        _isLoading = false;
        _errorMessage = null; // Don't show error, just use mock data
      });
      print('Failed to fetch home data, using mock data: $e');
    }
  }

  HomeData _createMockData() {
    return HomeData(
      categories: [
        Category(
          id: 1,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/general-test.png',
          nameEn: 'General Knowledge',
          nameZh: '常识',
          nameKh: 'ចំណេះដឹងទូទៅ',
        ),
        Category(
          id: 2,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/iq-test.png',
          nameEn: 'IQ Test',
          nameZh: '智商测试',
          nameKh: 'តេស្តវិឆ័យបញ្ញា',
        ),
        Category(
          id: 3,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/eq-test.png',
          nameEn: 'EQ Test',
          nameZh: '情商测试',
          nameKh: 'តេស្តអេគ្យូ (ភាពចេះដឹងអារម្មណ៍)',
        ),
        Category(
          id: 4,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/world-history-test.png',
          nameEn: 'World History Test',
          nameZh: '世界历史测试',
          nameKh: 'តេស្តប្រវត្តិសាស្ត្រពិភពលោក',
        ),
        Category(
          id: 5,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/khmer-history-test.png',
          nameEn: 'Khmer History Test',
          nameZh: '高棉历史测试',
          nameKh: 'តេស្តប្រវត្តិសាស្ត្រខ្មែរ',
        ),
        Category(
          id: 6,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/english-grammar-test.png',
          nameEn: 'English Grammar Test',
          nameZh: '英语语法测试',
          nameKh: 'តេស្តវេយ្យាករណ៍អង់គ្លេស',
        ),
        Category(
          id: 7,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/math-test.png',
          nameEn: 'Math Test',
          nameZh: '数学测试',
          nameKh: 'តេស្តគណិតវិទ្យា',
        ),
        Category(
          id: 8,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/physic-test.png',
          nameEn: 'Physic Test',
          nameZh: '物理测试',
          nameKh: 'តេស្តរូបវិទ្យា',
        ),
      ],
      banners: [
        BannerItem(id: 1, name: 'assets/images/banner.png'),
        BannerItem(id: 2, name: 'assets/images/banner.png'),
        BannerItem(id: 3, name: 'assets/images/banner.png'),
      ],
      promotions: [
        Promotion(id: 1, name: 'Featured Quiz'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Me Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: _switchLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchHomeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load data',
                        style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchHomeData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _homeData == null
                  ? const Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // 🔁 Banner Section
                          _buildBannerSection(),

                          const SizedBox(height: 24),

                          // 📦 Categories Grid
                          _buildCategoriesGrid(),

                          const SizedBox(height: 24),

                          // 📰 Promotion Section
                          _buildPromotionSection(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildBannerSection() {
    // Use default banners if API doesn't provide them
    final bannerImages = _homeData!.banners.isNotEmpty
        ? _homeData!.banners.map((b) => b.name ?? 'assets/images/banner.png').toList()
        : ['assets/images/banner.png', 'assets/images/banner.png', 'assets/images/banner.png'];

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(bannerImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          // Navigation buttons
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    if (_currentBannerIndex > 0) {
                      _bannerPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _bannerPageController.animateToPage(
                        bannerImages.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    if (_currentBannerIndex < bannerImages.length - 1) {
                      _bannerPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _bannerPageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          // Page indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    if (_homeData!.categories.isEmpty) {
      return const Center(
        child: Text('No categories available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedText('Categories', '分类', 'ប្រភេទ'),
            style: TextStyle(
              fontSize: _languageCode == 'kh' ? 22 : 20,
              fontWeight: _languageCode == 'kh' ? FontWeight.w900 : FontWeight.bold,
              color: Colors.black,
              shadows: _languageCode == 'kh' ? [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ] : null,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _homeData!.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final category = _homeData!.categories[index];
              return _buildCategoryCard(category, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      onPressed: () async {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Load quiz questions from API for the selected category
          print('Loading questions for category: ${category.id} (${category.getName(_languageCode)})');
          
          // Get authentication token
          final token = await TokenService.getToken();
          print('🔑 Using token: ${token != null ? 'Available' : 'No token found'}');
          
          final questions = await ApiService.getQuestionsByCategory(
            categoryId: category.id,
            token: token,
          );
          
          print('Loaded ${questions.length} questions');
          
          // Hide loading indicator
          Navigator.of(context).pop();
          
          if (questions.isNotEmpty) {
            // Navigate to quiz screen with API questions
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  questions: questions,
                  categoryName: category.getName(_languageCode),
                  categoryId: category.id,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No questions available for ${category.getName(_languageCode)}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          print('API Error for category ${category.id}: $e');
          // Hide loading indicator
          Navigator.of(context).pop();
          
          // If API fails and this is General Knowledge (category 1), try fallback to local JSON
          if (category.id == 1) {
            print('Trying fallback to local JSON for General Knowledge');
            try {
              final data = await rootBundle.loadString('assets/list.json');
              final questions = json.decode(data);
              print('Loaded ${questions.length} questions from local JSON');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    questions: questions,
                    categoryName: category.getName(_languageCode),
                    categoryId: category.id,
                  ),
                ),
              );
            } catch (localError) {
              print('Local JSON Error: $localError');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load quiz: $localError'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Failed to load ${category.getName(_languageCode)} quiz'),
                    Text('Error: $e', style: TextStyle(fontSize: 12)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category Icon
          category.iconUrl.isNotEmpty
              ? Image.network(
                  category.iconUrl,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.quiz, size: 32);
                  },
                )
              : const Icon(Icons.quiz, size: 32),
          const SizedBox(height: 8),
          // Category Name
          Text(
            category.getName(_languageCode),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _languageCode == 'kh' ? 13 : 11,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              shadows: _languageCode == 'kh' ? [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ] : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getLocalizedText('Featured', '精选', 'លេចធ្លោ'),
            style: TextStyle(
              fontSize: _languageCode == 'kh' ? 22 : 20,
              fontWeight: _languageCode == 'kh' ? FontWeight.w900 : FontWeight.bold,
              color: Colors.black,
              shadows: _languageCode == 'kh' ? [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withOpacity(0.3),
                ),
              ] : null,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange.shade600),
                    const SizedBox(width: 8),
                    Text(
                      _getLocalizedText('Challenge Yourself!', '挑战自己！', 'បង្កើនការប្រកួតប្រជែង!'),
                      style: TextStyle(
                        fontSize: _languageCode == 'kh' ? 20 : 18,
                        fontWeight: _languageCode == 'kh' ? FontWeight.w900 : FontWeight.bold,
                        color: Colors.orange.shade700,
                        shadows: _languageCode == 'kh' ? [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1.0,
                            color: Colors.orange.shade900.withOpacity(0.3),
                          ),
                        ] : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedText(
                    'Test your knowledge across multiple categories and compete with other users.',
                    '在多个类别中测试您的知识并与其他用户竞争。',
                    'ធ្វើតេស្តចំណេះដឹងរបស់អ្នកនៅកាត់ក្រុម ពហុនិងប្រកួតជាមួយអ្នកប្រើប្រាស់ផ្សេងទៀត។'
                  ),
                  style: TextStyle(
                    fontSize: _languageCode == 'kh' ? 16 : 14,
                    fontWeight: _languageCode == 'kh' ? FontWeight.w700 : FontWeight.normal,
                    color: Colors.orange.shade600,
                    shadows: _languageCode == 'kh' ? [
                      Shadow(
                        offset: const Offset(0.3, 0.3),
                        blurRadius: 0.5,
                        color: Colors.orange.shade800.withOpacity(0.2),
                      ),
                    ] : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedText(String en, String zh, String kh) {
    switch (_languageCode) {
      case 'en':
        return en;
      case 'zh':
        return zh;
      case 'kh':
        return kh;
      default:
        return en;
    }
  }
}
