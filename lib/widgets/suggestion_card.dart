import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import '../utils.dart';
import 'clothing_photo_box.dart';
import 'outfit_preview_dialog.dart';

class SuggestionCard extends StatefulWidget {
  final List<ClothingItem> initialCombo;
  final String? basedOnOutfitName;
  final List<ClothingItem> allItems;
  final void Function(List<ClothingItem> combo, String suggestedName) onUse;

  const SuggestionCard({
    super.key,
    required this.initialCombo,
    required this.basedOnOutfitName,
    required this.allItems,
    required this.onUse,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  late List<ClothingItem> combo;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    combo = List<ClothingItem>.from(widget.initialCombo);
  }

  String get suggestedName {
    final dressMatch = combo.where((i) => i.category == ClothingCategory.dress);
    final topMatch = combo.where((i) => i.category == ClothingCategory.top);
    final main = dressMatch.isNotEmpty
        ? dressMatch.first
        : (topMatch.isNotEmpty ? topMatch.first : combo.first);
    return main.subcategory.isNotEmpty ? main.subcategory : main.name;
  }

  double get total => combo.fold(0.0, (s, i) => s + i.price);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: editing ? _buildEditMode() : _buildViewMode(),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: combo.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) => SizedBox(
              width: 56,
              child: ClothingPhotoBox(item: combo[i], height: 56, borderRadius: 5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Propozycja: ${combo.map((i) => i.name).join(' + ')}',
          style: displayFont(fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          '${combo.length} elementy · ${fmtPrice(total)}'
          '${widget.basedOnOutfitName != null ? ' · wariant „${widget.basedOnOutfitName}”' : ''}',
          style: TextStyle(
            fontSize: 11,
            color: widget.basedOnOutfitName != null ? AppColors.sage : AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => widget.onUse(combo, suggestedName),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.paper,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Użyj', style: TextStyle(fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: () => showOutfitPreview(context, combo),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
              child: const Text('🔍 Podgląd', style: TextStyle(fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: () => setState(() => editing = true),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
              child: const Text('✏️ Edytuj', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    final usedIds = combo.map((i) => i.id).toSet();
    final leftovers = widget.allItems.where((i) => !usedIds.contains(i.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Edytuj propozycję', style: displayFont(fontSize: 15)),
        const SizedBox(height: 10),
        ...combo.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final sameCategory = widget.allItems.where((i) => i.category == item.category).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 40, height: 40, child: ClothingPhotoBox(item: item, height: 40, borderRadius: 4)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: item.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: sameCategory
                        .map((o) => DropdownMenuItem(
                              value: o.id,
                              child: Text('${o.category.icon} ${o.name}',
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (newId) {
                      final newItem = widget.allItems.firstWhere((i) => i.id == newId);
                      setState(() => combo[idx] = newItem);
                    },
                  ),
                ),
                IconButton(
                  onPressed: combo.length <= 1
                      ? null
                      : () => setState(() => combo.removeAt(idx)),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          );
        }),
        if (leftovers.isNotEmpty)
          DropdownButtonFormField<String>(
            value: null,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              hintText: '+ Dodaj element…',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(),
            ),
            items: leftovers
                .map((o) => DropdownMenuItem(
                      value: o.id,
                      child: Text('${o.category.icon} ${o.name}', overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (newId) {
              if (newId == null) return;
              final newItem = widget.allItems.firstWhere((i) => i.id == newId);
              setState(() => combo.add(newItem));
            },
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () => widget.onUse(combo, suggestedName),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.paper,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text('Użyj', style: TextStyle(fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: () => showOutfitPreview(context, combo),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
              child: const Text('🔍 Podgląd', style: TextStyle(fontSize: 12)),
            ),
            OutlinedButton(
              onPressed: () => setState(() => editing = false),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
              child: const Text('Gotowe', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}
