import 'package:flutter/material.dart';

/// Skala odstępów (system 8px) - jedno miejsce, z którego korzystają
/// wszystkie ekrany zamiast wpisywać przypadkowe wartości "na oko".
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

/// Pomaga rozmiarom (czcionki, odstępy, ikony) skalować się proporcjonalnie
/// do szerokości ekranu - appka projektowana "na oko" pod jeden telefon
/// (referencyjna szerokość 390px, czyli mniej więcej iPhone 14/wąski Android)
/// wygląda spójnie zarówno na małych, jak i większych telefonach, zamiast
/// mieć sztywne piksele, które na innym ekranie wyglądają za duże/za małe.
///
/// Celowo ograniczone widełkami (0.85-1.25), żeby na naprawdę dużych
/// ekranach (tablety) elementy nie urosły absurdalnie - to nie jest pełny
/// układ pod tablet, tylko łagodne dopasowanie między telefonami.
extension ResponsiveSize on BuildContext {
  double scale(
    double value, {
    double baseWidth = 390,
    double min = 0.85,
    double max = 1.25,
  }) {
    final width = MediaQuery.of(this).size.width;
    final factor = (width / baseWidth).clamp(min, max);
    return value * factor;
  }

  /// Skrót do najczęstszego przypadku - skalowanej wielkości czcionki.
  double sp(double value) => scale(value);
}
