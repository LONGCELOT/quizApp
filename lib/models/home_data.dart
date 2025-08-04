class HomeData {
  final List<Category> categories;
  final List<BannerItem> banners;
  final List<Promotion> promotions;

  HomeData({
    required this.categories,
    required this.banners,
    required this.promotions,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      categories: (json['categories'] as List? ?? [])
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList(),
      banners: (json['banners'] as List? ?? [])
          .map((bannerJson) => BannerItem.fromJson(bannerJson))
          .toList(),
      promotions: (json['promotions'] as List? ?? [])
          .map((promotionJson) => Promotion.fromJson(promotionJson))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String iconUrl;
  final String nameEn;
  final String nameZh;
  final String nameKh;

  Category({
    required this.id,
    required this.iconUrl,
    required this.nameEn,
    required this.nameZh,
    required this.nameKh,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      iconUrl: json['iconUrl'] ?? '',
      nameEn: json['nameEn'] ?? 'Unknown',
      nameZh: json['nameZh'] ?? 'Unknown',
      nameKh: json['nameKh'] ?? 'Unknown',
    );
  }

  String getName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEn;
      case 'zh':
        return nameZh;
      case 'kh':
        return nameKh;
      default:
        return nameEn;
    }
  }
}

class BannerItem {
  final int id;
  final String? name;

  BannerItem({required this.id, this.name});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Promotion {
  final int id;
  final String? name;

  Promotion({required this.id, this.name});

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      name: json['name'],
    );
  }
}
