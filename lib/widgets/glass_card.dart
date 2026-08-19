import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Karta z efektem "mlecznego szkła" - rozmyte tło + półprzezroczysta biel +
/// cienka, jasna obwódka. Podstawowy budulec wszystkich kart w Szafniku
/// (Home, Garderoba, Szczegóły, Stylizacje, Przymierzalnia) - jeden wspólny
/// komponent, żeby efekt wyglądał identycznie wszędzie.
///
/// Uwaga wydajnościowa: `BackdropFilter` (rozmycie) jest kosztowne, jeśli na
/// ekranie widać naraz dużo takich kart (np. długa siatka produktów). Jeśli
/// na słabszym telefonie pojawi się zacinanie przy przewijaniu, da się to
/// miejscowo zamienić na tańszy wariant (`GlassCard(cheap: true)`) bez
/// utraty spójności wizualnej - stąd ten parametr od razu w komponencie.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blurSigma;
  final double fillOpacity;
  final List<BoxShadow>? shadow;

  /// Tańszy wariant bez [BackdropFilter] (sama półprzezroczysta karta, bez
  /// realnego rozmycia tła pod spodem) - do użycia w długich listach/siatkach,
  /// gdzie wydajność ma pierwszeństwo nad wiernością efektu.
  final bool cheap;

  const GlassCard({
    super.key,
    required this.child,
    this.radius = AppRadius.card,
    this.padding = const EdgeInsets.all(16),
    this.blurSigma = 18,
    this.fillOpacity = 0.55,
    this.shadow,
    this.cheap = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.paper.withOpacity(fillOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      boxShadow: shadow ?? AppColors.softCardShadow,
    );

    final content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (cheap) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}
