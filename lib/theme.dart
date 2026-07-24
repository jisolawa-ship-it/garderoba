import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ciepła, "butikowa" paleta motywu aplikacji.
class AppColors {
  static const bg = Color(0xFFF3E9DC);
  static const bgSoft = Color(0xFFEFE1CE);
  static const paper = Color(0xFFFBF6EE);
  static const ink = Color(0xFF2B2116);
  static const inkSoft = Color(0xFF8A7C6D);
  static const line = Color(0xFFE4D6C4);

  static const wine = Color(0xFFB15A38);
  static const wineSoft = Color(0xFFF4E0D2);
  static const sage = Color(0xFF7C8F5E);
  static const sageSoft = Color(0xFFE8EBDB);
  static const mustard = Color(0xFFC08A3E);
  static const mustardSoft = Color(0xFFF5E8CC);
}

/// Serif - do nagłówków, nazw ubrań, tytułów paneli (styl "metki").
TextStyle displayFont({
  double fontSize = 20,
  FontWeight fontWeight = FontWeight.w700,
  Color color = AppColors.ink,
  double? letterSpacing,
}) =>
    GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );

/// Mono - do cen, kodów kreskowych, danych liczbowych.
TextStyle monoFont({
  double fontSize = 13,
  FontWeight fontWeight = FontWeight.w500,
  Color color = AppColors.ink,
  double? letterSpacing,
}) =>
    GoogleFonts.ibmPlexMono(
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
