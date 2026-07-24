enum ClothingCategory { top, bottom, dress, outerwear, shoes, accessory }

extension ClothingCategoryX on ClothingCategory {
  String get label {
    switch (this) {
      case ClothingCategory.top:
        return 'Góra';
      case ClothingCategory.bottom:
        return 'Dół';
      case ClothingCategory.dress:
        return 'Sukienka';
      case ClothingCategory.outerwear:
        return 'Okrycie';
      case ClothingCategory.shoes:
        return 'Buty';
      case ClothingCategory.accessory:
        return 'Dodatek';
    }
  }

  String get icon {
    switch (this) {
      case ClothingCategory.top:
        return '👕';
      case ClothingCategory.bottom:
        return '👖';
      case ClothingCategory.dress:
        return '👗';
      case ClothingCategory.outerwear:
        return '🧥';
      case ClothingCategory.shoes:
        return '👞';
      case ClothingCategory.accessory:
        return '👜';
    }
  }

  List<String> get defaultSubcategories {
    switch (this) {
      case ClothingCategory.top:
        return ['T-shirt', 'Koszula', 'Bluzka', 'Sweter', 'Bluza', 'Top na ramiączkach'];
      case ClothingCategory.bottom:
        return ['Jeansy', 'Spodnie materiałowe', 'Spódnica', 'Legginsy', 'Szorty'];
      case ClothingCategory.dress:
        return ['Sukienka codzienna', 'Sukienka wieczorowa', 'Kombinezon'];
      case ClothingCategory.outerwear:
        return ['Płaszcz', 'Kurtka', 'Marynarka', 'Kurtka puchowa', 'Kardigan'];
      case ClothingCategory.shoes:
        return ['Sneakersy', 'Botki', 'Szpilki/Czółenka', 'Sandały', 'Buty sportowe'];
      case ClothingCategory.accessory:
        return ['Torebka', 'Pasek', 'Szalik', 'Biżuteria', 'Czapka/Kapelusz'];
    }
  }
}

class ClothingItem {
  final String id;
  String name;
  ClothingCategory category;
  String subcategory;
  String colorHex; // '#RRGGBB' or 'multi' for multikolor
  double price;
  int wears;
  String? photoPath; // local file path on device (cache offline)
  String? photoUrl; // adres zdjęcia w Firebase Storage (gdy zalogowana)
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.colorHex,
    required this.price,
    this.wears = 0,
    this.photoPath,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double? get costPerWear => wears == 0 ? null : price / wears;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'subcategory': subcategory,
        'colorHex': colorHex,
        'price': price,
        'wears': wears,
        'photoPath': photoPath,
        'photoUrl': photoUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: ClothingCategory.values.byName(json['category'] as String),
        subcategory: (json['subcategory'] ?? '') as String,
        colorHex: (json['colorHex'] ?? '#8c8c88') as String,
        price: (json['price'] as num).toDouble(),
        wears: (json['wears'] ?? 0) as int,
        photoPath: json['photoPath'] as String?,
        photoUrl: json['photoUrl'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}
