import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import '../utils.dart';
import 'clothing_photo_box.dart';
import 'glass_card.dart';

/// Uproszczona karta ubrania w siatce Garderoby - tylko podgląd (zdjęcie,
/// nazwa, kolor). Wszystkie szczegóły (cena, historia noszenia, ocena
/// wartości) i akcje (Załóż/Cofnij/Edytuj/Usuń) mieszkają na ekranie
/// Szczegółów ubrania, do którego prowadzi dotknięcie całej karty - przy
/// dużej szafie (100+ ubrań) siatka pełna cen, plakietek i przycisków była
/// nieczytelna.
class ClothingTagCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onOpenDetail;

  const ClothingTagCard({
    super.key,
    required this.item,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenDetail,
      // cheap: true - w siatce Garderoby może być naraz dziesiątki takich
      // kart, prawdziwe rozmycie tła dla każdej z osobna obciążałoby
      // słabsze telefony przy przewijaniu.
      child: GlassCard(
        radius: AppRadius.card,
        padding: const EdgeInsets.all(10),
        cheap: true,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClothingPhotoBox(item: item, height: 130, borderRadius: 12),
                  if (item.needsCompletion)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_note, size: 13, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.name.isEmpty ? 'Bez nazwy' : item.name,
                style: displayFont(
                  fontSize: 15,
                  color: item.name.isEmpty ? AppColors.inkSoft : AppColors.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: item.colorHex == 'multi' ? AppColors.mustard : hexToColor(item.colorHex),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      colorNameFor(item.colorHex),
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
