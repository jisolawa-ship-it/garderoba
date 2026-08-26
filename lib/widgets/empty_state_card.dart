import 'package:flutter/material.dart';
import '../theme.dart';
import 'glass_card.dart';

/// Spójny "pusty stan" używany na kilku ekranach naraz - grafika w
/// zaokrąglonym boxie, krótki tekst, i opcjonalnie jeden przycisk (jedyna
/// możliwa akcja w danej sytuacji - np. "Dodaj ubranie", kiedy bez ubrań
/// nic więcej się nie da zrobić).
///
/// Wariant [compact] (bez dużego zdjęcia, z małą ikoną) jest do osadzania
/// w miejscach o ograniczonej wysokości, np. wewnątrz arkuszy (bottom sheet) -
/// pełna wersja z 160px grafiką mogłaby tam nie zmieścić się elegancko.
class EmptyStateCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final bool compact;
  final IconData compactIcon;
  /// Wariant "hero" - zdjęcie wychodzi na pełną szerokość ekranu (poza
  /// margines, który otacza resztę karty), tekst i przycisk zostają wcięte
  /// tak jak w wariancie domyślnym. Do użycia, gdy ekran NIE owija już
  /// [EmptyStateCard] w żaden własny Padding poziomy - margines dla
  /// tekstu/przycisku jest wtedy liczony przez [heroSideMargin].
  final bool heroImage;
  final double heroSideMargin;

  const EmptyStateCard({
    super.key,
    this.imageAsset = '',
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonTap,
    this.compact = false,
    this.compactIcon = Icons.checkroom_outlined,
    this.heroImage = false,
    this.heroSideMargin = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    if (heroImage) return _buildHero();
    // padding: zero - zdjęcie ma być "pełną krawędzią" na górze karty, bez
    // marginesu GlassCard; tekst pod spodem ma własny odstęp. Zdjęcie samo
    // w sobie jest nieprzezroczyste, więc rozmycie "pod spodem" go nie
    // dotyczy - efekt mlecznego szkła widać tylko przy tekście poniżej.
    return GlassCard(
      radius: AppRadius.hero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Image.asset(imageAsset, width: double.infinity, fit: BoxFit.fitWidth),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: _textSection(),
          ),
        ],
      ),
    );
  }

  /// Zdjęcie na pełną szerokość (bez marginesu), zaokrąglone tylko u góry -
  /// karta z tekstem/przyciskiem pod spodem zostaje wcięta o [heroSideMargin]
  /// z każdej strony, jak dotychczas.
  Widget _buildHero() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.hero),
            topRight: Radius.circular(AppRadius.hero),
          ),
          child: Image.asset(imageAsset, width: double.infinity, fit: BoxFit.fitWidth),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: heroSideMargin),
          child: GlassCard(
            radius: AppRadius.hero,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: _textSection(),
          ),
        ),
      ],
    );
  }

  Widget _textSection() {
    return Column(
      children: [
        Text(title, style: displayFont(fontSize: 17), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
          textAlign: TextAlign.center,
        ),
        if (buttonLabel != null && onButtonTap != null) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onButtonTap,
              icon: const Icon(Icons.add, size: 18),
              label: Text(buttonLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Icon(compactIcon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(title, style: displayFont(fontSize: 15), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.4),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onButtonTap,
                icon: const Icon(Icons.add, size: 16),
                label: Text(buttonLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
