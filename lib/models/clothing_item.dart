import 'package:flutter/material.dart';

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

  IconData get iconData {
    switch (this) {
      case ClothingCategory.top:
        return Icons.checkroom_outlined;
      case ClothingCategory.bottom:
        return Icons.dry_cleaning_outlined;
      case ClothingCategory.dress:
        return Icons.woman_outlined;
      case ClothingCategory.outerwear:
        return Icons.ac_unit_outlined;
      case ClothingCategory.shoes:
        return Icons.hiking_outlined;
      case ClothingCategory.accessory:
        return Icons.shopping_bag_outlined;
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

/// Cztery pory roku - checkboxy, ubranie może pasować do kilku naraz.
const kSeasons = ['Wiosna', 'Lato', 'Jesień', 'Zima'];

/// Jak dawno posiadane - kubełki zamiast dokładnej daty zakupu, której
/// appka nie zna (zna tylko datę DODANIA do appki, nie prawdziwego zakupu).
const kOwnershipAgeOptions = ['Nowe', 'Do roku', 'Do 2 lat', 'Powyżej 2 lat'];

class ClothingItem {
  final String id;
  String name; // pusty string = brak nazwy, ubranie wymaga uzupełnienia
  ClothingCategory category;
  String subcategory;
  String colorHex; // '#RRGGBB' or 'multi' for multikolor
  double? price; // null = brak ceny, ubranie wymaga uzupełnienia
  int wears;
  String? photoPath; // local file path on device (cache offline)
  String? photoUrl; // adres zdjęcia w Firebase Storage (gdy zalogowana)
  List<String> seasons; // pasujące pory roku - pusta lista = nie określono
  String? ownershipAge; // jedna z kOwnershipAgeOptions - null = nie określono
  final DateTime createdAt;
  DateTime updatedAt; // moment ostatniej zmiany - podstawa bezpiecznej synchronizacji

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.colorHex,
    this.price,
    this.wears = 0,
    this.photoPath,
    this.photoUrl,
    this.seasons = const [],
    this.ownershipAge,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? (createdAt ?? DateTime.now());

  /// Ubranie dodane grupowo, dla którego appka nie zdołała uzupełnić
  /// wszystkiego automatycznie (nazwa i cena nigdy nie są zgadywane -
  /// zawsze wymagają Twojego potwierdzenia).
  bool get needsCompletion => name.trim().isEmpty || price == null;

  double? get costPerWear => (price == null || wears == 0) ? null : price! / wears;

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
        'seasons': seasons,
        'ownershipAge': ownershipAge,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
        id: json['id'] as String,
        name: (json['name'] ?? '') as String,
        category: ClothingCategory.values.byName(json['category'] as String),
        subcategory: (json['subcategory'] ?? '') as String,
        colorHex: (json['colorHex'] ?? '#8c8c88') as String,
        price: json['price'] == null ? null : (json['price'] as num).toDouble(),
        wears: (json['wears'] ?? 0) as int,
        photoPath: json['photoPath'] as String?,
        photoUrl: json['photoUrl'] as String?,
        seasons: json['seasons'] == null
            ? const []
            : (json['seasons'] as List).map((e) => e as String).toList(),
        ownershipAge: json['ownershipAge'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}
