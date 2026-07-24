import 'package:flutter/material.dart';
import '../theme.dart';

class ColorPickerGrid extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onChanged;

  const ColorPickerGrid({
    super.key,
    required this.selectedHex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kClothingColors.map((c) {
        final isSelected = c.hex.toUpperCase() == selectedHex.toUpperCase();
        return GestureDetector(
          onTap: () => onChanged(c.hex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: c.hex == 'multi'
                  ? const LinearGradient(
                      colors: kMultiGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: c.hex == 'multi' ? null : hexToColor(c.hex),
              border: Border.all(
                color: isSelected ? AppColors.wine : Colors.black12,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.wine.withOpacity(0.4),
                        blurRadius: 4,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Mały kwadrat/koło z kolorem lub gradientem multikolor - do użycia
/// w miejscach gdzie brak zdjęcia (np. miniatury w listach).
class ClothingColorSwatch extends StatelessWidget {
  final String hex;
  final double size;
  final BorderRadiusGeometry borderRadius;

  const ClothingColorSwatch({
    super.key,
    required this.hex,
    this.size = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: hex == 'multi'
            ? const LinearGradient(
                colors: kMultiGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hex == 'multi' ? null : hexToColor(hex),
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}
