import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import '../utils.dart';
import 'clothing_photo_box.dart';

Future<void> showOutfitPreview(BuildContext context, List<ClothingItem> combo) {
  final total = combo.fold(0.0, (s, i) => s + i.price);
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Podgląd stylizacji', style: displayFont(fontSize: 20)),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: combo.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (ctx, i) {
                    final item = combo[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: ClothingPhotoBox(item: item, height: 140)),
                        const SizedBox(height: 6),
                        Text(item.name,
                            style: displayFont(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '${item.category.icon} ${item.subcategory.isNotEmpty ? item.subcategory : item.category.label} · ${fmtPrice(item.price)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              Text('Łączna wartość: ${fmtPrice(total)}',
                  style: monoFont(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ),
  );
}
