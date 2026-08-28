import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../theme.dart';
import '../utils.dart';
import 'clothing_photo_box.dart';
import 'outfit_preview_dialog.dart';

String _suggestedNameFor(List<ClothingItem> combo) {
  final dressMatch = combo.where((i) => i.category == ClothingCategory.dress);
  final topMatch = combo.where((i) => i.category == ClothingCategory.top);
  final main = dressMatch.isNotEmpty
      ? dressMatch.first
      : (topMatch.isNotEmpty ? topMatch.first : combo.first);
  return main.subcategory.isNotEmpty ? main.subcategory : main.name;
}

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

  @override
  void initState() {
    super.initState();
    combo = List<ClothingItem>.from(widget.initialCombo);
  }

  double get total => combo.fold(0.0, (s, i) => s + (i.price ?? 0));

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
      child: Column(
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
                onPressed: () => widget.onUse(combo, _suggestedNameFor(combo)),
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
                onPressed: _openEditSheet,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
                child: const Text('✏️ Edytuj', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Edycja propozycji (podmiana/dodanie/usunięcie ubrania) otwiera się jako
  // wyskakujący arkusz na dole ekranu, a NIE rozwija w miejscu - wcześniejsze
  // rozwinięcie inline dokładało do karty kilka rozwijanych list naraz i
  // realnie przesuwało cały ekran w dół, co przy kilku propozycjach naraz na
  // liście było niewygodne (trzeba było szukać karty, którą się właśnie
  // edytowało).
  Future<void> _openEditSheet() async {
    final result = await showModalBottomSheet<List<ClothingItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: _SuggestionEditSheet(
          initialCombo: combo,
          allItems: widget.allItems,
          onUse: (finalCombo) {
            Navigator.pop(ctx);
            widget.onUse(finalCombo, _suggestedNameFor(finalCombo));
          },
        ),
      ),
    );
    if (result != null) {
      setState(() => combo = result);
    }
  }
}

/// Arkusz do edycji propozycji stylizacji (podmiana ubrań, dodanie/usunięcie
/// elementu) - osobny widget ze swoim stanem, żeby dało się go zamknąć bez
/// zapisywania zmian (przycisk „Gotowe” zwraca finalną listę przez
/// Navigator.pop, „Użyj” od razu przechodzi do Przymierzalni z aktualnym
/// składem).
class _SuggestionEditSheet extends StatefulWidget {
  final List<ClothingItem> initialCombo;
  final List<ClothingItem> allItems;
  final ValueChanged<List<ClothingItem>> onUse;

  const _SuggestionEditSheet({
    required this.initialCombo,
    required this.allItems,
    required this.onUse,
  });

  @override
  State<_SuggestionEditSheet> createState() => _SuggestionEditSheetState();
}

class _SuggestionEditSheetState extends State<_SuggestionEditSheet> {
  late List<ClothingItem> combo;

  @override
  void initState() {
    super.initState();
    combo = List<ClothingItem>.from(widget.initialCombo);
  }

  @override
  Widget build(BuildContext context) {
    final usedIds = combo.map((i) => i.id).toSet();
    final leftovers = widget.allItems.where((i) => !usedIds.contains(i.id)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edytuj propozycję', style: displayFont(fontSize: 17)),
            const SizedBox(height: 14),
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
                        initialValue: item.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: sameCategory
                            .map((o) => DropdownMenuItem(
                                  value: o.id,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(o.category.iconData, size: 14, color: AppColors.inkSoft),
                                      const SizedBox(width: 6),
                                      Flexible(child: Text(o.name, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
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
                initialValue: null,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(o.category.iconData, size: 14, color: AppColors.inkSoft),
                              const SizedBox(width: 6),
                              Flexible(child: Text(o.name, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (newId) {
                  if (newId == null) return;
                  final newItem = widget.allItems.firstWhere((i) => i.id == newId);
                  setState(() => combo.add(newItem));
                },
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onUse(combo),
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
                  onPressed: () => Navigator.pop(context, combo),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.line)),
                  child: const Text('Gotowe', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
