import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta "cichego luksusu" Szafnika - kremowy beż + pudrowy róż.
class AppColors {
  static const bg = Color(0xFFFAF3ED);
  static const bgSoft = Color(0xFFF3D6D8);
  static const paper = Color(0xFFFFFBF8);
  static const ink = Color(0xFF2E2A28);
  static const inkSoft = Color(0xFF8C8078);
  static const line = Color(0xFFF0E4DD);

  // Główny akcent marki (przyciski, aktywne stany, FAB).
  static const primary = Color(0xFFD8878A);
  static const primarySoft = Color(0xFFF3D6D8);

  // Zachowane nazwy z poprzedniej palety - wskazują teraz na primary/primarySoft,
  // żeby nie trzeba było na raz przepisywać każdego ekranu (dochodzimy do nich
  // kolejno, etapami).
  static const gold = Color(0xFFC6A15B);
  static const champagneGold = gold;
  static const goldSoft = Color(0xFFE6D3AC);

  static const wine = Color(0xFFC08A6B);
  static const wineSoft = Color(0xFFF6E7DC);
  static const sage = Color(0xFFA3A67E);
  static const sageSoft = Color(0xFFEDEEDF);
  static const mustard = Color(0xFFBB9A4E);
  static const mustardSoft = Color(0xFFF1E4BE);

  // Spójny, delikatny cień używany pod wszystkimi kartami w aplikacji.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x142E2A28), blurRadius: 14, offset: Offset(0, 6)),
  ];

  // Bardzo miękki cień premium - do dużych kart/hero.
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(color: Color(0x0F2E2A28), blurRadius: 28, offset: Offset(0, 12)),
  ];
}

/// Skala zaokrągleń - jedno miejsce, z którego korzystają wszystkie ekrany.
class AppRadius {
  static const double pill = 999; // wyszukiwarka, chipy filtrów
  static const double card = 16; // karty produktów, standardowe panele
  static const double hero = 26; // duże karty/banery (Home, szczegóły)
}

/// Serif - do nagłówków, nazw ubrań, tytułów paneli (styl "metki").
TextStyle displayFont({
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.w700,
  Color color = AppColors.ink,
  double? letterSpacing,
}) =>
    GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

/// Sans-serif - do cen, kodów kreskowych, danych liczbowych. Wcześniej był to
/// krój mono (IBM Plex Mono) - zrezygnowałyśmy z niego, bo żadna z referencji
/// wizualnych Szafnika nie ma technicznego/monospace wyglądu przy cenach.
/// Nazwa funkcji została, żeby nie trzeba było zmieniać każdego miejsca
/// wywołania w całej aplikacji na raz.
TextStyle monoFont({
  double fontSize = 13,
  FontWeight fontWeight = FontWeight.w500,
  Color color = AppColors.ink,
  double? letterSpacing,
}) =>
    GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

class ClothingColor {
  final String name;
  final String hex; // '#RRGGBB' or 'multi'
  const ClothingColor(this.name, this.hex);
}

const List<ClothingColor> kClothingColors = [
  ClothingColor('Czarny', '#1A1A1A'),
  ClothingColor('Biały', '#F5F5F4'),
  ClothingColor('Kremowy', '#ECE3D0'),
  ClothingColor('Szary', '#8C8C88'),
  ClothingColor('Grafitowy', '#3A3A3A'),
  ClothingColor('Beżowy', '#D8C9AB'),
  ClothingColor('Brązowy', '#6B4423'),
  ClothingColor('Granatowy', '#1F2A44'),
  ClothingColor('Niebieski', '#3B6EA5'),
  ClothingColor('Błękitny', '#A7C7E7'),
  ClothingColor('Czerwony', '#A13D3D'),
  ClothingColor('Bordowy', '#6D2130'),
  ClothingColor('Różowy', '#D98BA0'),
  ClothingColor('Zielony', '#4F6B4A'),
  ClothingColor('Oliwkowy', '#6E7440'),
  ClothingColor('Żółty', '#D9B44A'),
  ClothingColor('Pomarańczowy', '#C1712F'),
  ClothingColor('Fioletowy', '#6C4F77'),
  ClothingColor('Multikolor', 'multi'),
];

const List<String> kNeutralHex = [
  '#1A1A1A', '#F5F5F4', '#ECE3D0', '#8C8C88', '#3A3A3A', '#D8C9AB', '#6B4423', '#1F2A44',
];

bool isNeutralColor(String hex) => kNeutralHex.contains(hex.toUpperCase());

String colorNameFor(String hex) {
  final match = kClothingColors.where((c) => c.hex.toUpperCase() == hex.toUpperCase());
  if (match.isEmpty) return 'Niestandardowy';
  return match.first.name;
}

Color hexToColor(String hex) {
  if (hex == 'multi') return AppColors.wine;
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

const List<Color> kMultiGradientColors = [
  Color(0xFFA13D3D),
  Color(0xFFD9B44A),
  Color(0xFF4F6B4A),
  Color(0xFF3B6EA5),
  Color(0xFF6C4F77),
];
