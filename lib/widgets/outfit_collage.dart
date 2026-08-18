import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import 'clothing_photo_box.dart';

/// Podgląd stylizacji jako uporządkowanego układu wg kategorii - góra
/// (i sukienki/okrycia) u góry, dół i buty na dole, dodatki z boku.
/// Współdzielony przez ekran Stylizacji i arkusz dnia w Kalendarzu, żeby
/// nie duplikować tej samej logiki w dwóch miejscach.
class OutfitCollage extends StatelessWidget {
  final List<ClothingItem> items;
  const OutfitCollage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const canvasRef = Size(300, 420);

    final topGroup = items
        .where((i) =>
            i.category == ClothingCategory.top ||
            i.category == ClothingCategory.dress ||
            i.category == ClothingCategory.outerwear)
        .toList();
    final bottomGroup = items
        .where((i) => i.category == ClothingCategory.bottom || i.category == ClothingCategory.shoes)
        .toList();
    final accessoryGroup = items.where((i) => i.category == ClothingCategory.accessory).toList();

    return AspectRatio(
      aspectRatio: canvasRef.width / canvasRef.height,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSoft,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: items.isEmpty
            ? const SizedBox.shrink()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        Expanded(child: _zone(topGroup)),
                        if (bottomGroup.isNotEmpty) const SizedBox(height: 10),
                        Expanded(child: _zone(bottomGroup)),
                      ],
                    ),
                  ),
                  if (accessoryGroup.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: _zone(accessoryGroup)),
                  ],
                ],
              ),
      ),
    );
  }

  /// Jedna "strefa" kolażu (góra / dół / dodatki) - równe kwadraciki,
  /// maks. 2 w rzędzie, żeby nie robiły się zbyt małe przy większej liczbie
  /// ubrań w tej samej kategorii.
  Widget _zone(List<ClothingItem> its) {
    if (its.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = its.length <= 1 ? 1 : 2;
        final itemSize = ((constraints.maxWidth - (columns - 1) * 8) / columns)
            .clamp(0.0, constraints.maxHeight);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: its
              .map((item) => Container(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.paper, width: 2),
                      boxShadow: AppColors.cardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClothingPhotoBox(item: item, height: itemSize, borderRadius: 10),
                  ))
              .toList(),
        );
      },
    );
  }
}
