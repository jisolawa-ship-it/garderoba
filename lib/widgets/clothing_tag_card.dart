import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import '../utils.dart';
import 'barcode_strip.dart';
import 'clothing_photo_box.dart';

class ClothingTagCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onWear;
  final VoidCallback onUnwear;
  final VoidCallback onDelete;

  const ClothingTagCard({
    super.key,
    required this.item,
    required this.onWear,
    required this.onUnwear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final badge = badgeForItem(item);
    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x142B2116), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClothingPhotoBox(item: item, height: 110, borderRadius: 12),
          const SizedBox(height: 10),
          Text(
            '${item.category.icon} ${item.category.label}${item.subcategory.isNotEmpty ? ' · ${item.subcategory}' : ''}',
            style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, letterSpacing: 0.3),
          ),
          const SizedBox(height: 3),
          Text(
            item.name,
            style: displayFont(fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            colorNameFor(item.colorHex),
            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 4),
          Text(
            fmtPrice(item.price),
            style: monoFont(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          BarcodeStrip(seed: item.id),
          const SizedBox(height: 8),
          Text(
            'Noszone: ${item.wears}×',
            style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badge.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge.label,
              style: TextStyle(fontSize: 10, color: badge.color, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _actionButton('+ Załóż', onWear),
              _actionButton('↩ Cofnij', item.wears == 0 ? null : onUnwear),
              _actionButton('Usuń', onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback? onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: AppColors.line),
        foregroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
