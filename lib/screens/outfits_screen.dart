import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/suggestion_engine.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/clothing_photo_box.dart';
import '../widgets/suggestion_card.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  List<SuggestionCombo> _suggestions = [];
  bool _generated = false;
  final Set<String> _selected = {};
  final _outfitNameCtrl = TextEditingController();

  @override
  void dispose() {
    _outfitNameCtrl.dispose();
    super.dispose();
  }

  void _regenerateSuggestions(WardrobeProvider wardrobe) {
    setState(() {
      _suggestions = SuggestionEngine.generate(wardrobe.items, wardrobe.outfits);
    });
  }

  void _useSuggestion(List<ClothingItem> combo, String suggestedName) {
    setState(() {
      _selected
        ..clear()
        ..addAll(combo.map((i) => i.id));
      _outfitNameCtrl.text = 'Propozycja: $suggestedName';
    });
  }

  Future<void> _saveOutfit(WardrobeProvider wardrobe) async {
    final name = _outfitNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Podaj nazwę stylizacji.')));
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wybierz co najmniej jedno ubranie.')));
      return;
    }
    await wardrobe.addOutfit(name, _selected.toList());
    setState(() {
      _selected.clear();
      _outfitNameCtrl.clear();
    });
    _regenerateSuggestions(wardrobe);
  }

  Future<void> _openItemPicker(BuildContext context, WardrobeProvider wardrobe) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _ItemPickerSheet(
        items: wardrobe.items,
        initialSelected: _selected,
      ),
    );
    if (result != null) {
      setState(() {
        _selected
          ..clear()
          ..addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();

    if (!wardrobe.isLoading && !_generated) {
      _generated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _regenerateSuggestions(wardrobe);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Stylizacje', style: displayFont(fontSize: 26)),
        foregroundColor: AppColors.ink,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _panel(
            title: 'Sugestie stylizacji',
            trailing: ElevatedButton(
              onPressed: () => _regenerateSuggestions(wardrobe),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: AppColors.paper,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('🔀 Losuj inne', style: TextStyle(fontSize: 12)),
            ),
            child: wardrobe.items.length < 2
                ? const Text('Dodaj więcej ubrań do szafy, żeby zobaczyć sugestie.',
                    style: TextStyle(color: AppColors.inkSoft))
                : _suggestions.isEmpty
                    ? const Text(
                        'Brak nowych propozycji — dodaj więcej ubrań albo zapisz istniejące stylizacje.',
                        style: TextStyle(color: AppColors.inkSoft))
                    : Column(
                        children: _suggestions
                            .map((s) => SuggestionCard(
                                  key: ValueKey(s.sortedKey),
                                  initialCombo: s.items,
                                  basedOnOutfitName: s.basedOnOutfitName,
                                  allItems: wardrobe.items,
                                  onUse: _useSuggestion,
                                ))
                            .toList(),
                      ),
          ),
          const SizedBox(height: 16),
          _panel(
            title: 'Zaplanuj stylizację',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _outfitNameCtrl,
                  decoration: InputDecoration(
                    hintText: 'np. Na spotkanie',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_selected.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selected.map((id) {
                      final item = wardrobe.findItem(id);
                      if (item == null) return const SizedBox.shrink();
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: AppColors.bgSoft,
                          child: Text(item.category.icon, style: const TextStyle(fontSize: 12)),
                        ),
                        label: Text(item.name, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.line),
                        onDeleted: () => setState(() => _selected.remove(id)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: wardrobe.items.isEmpty ? null : () => _openItemPicker(context, wardrobe),
                    icon: const Icon(Icons.checkroom_outlined, size: 18),
                    label: Text(_selected.isEmpty ? 'Stwórz stylizację' : 'Zmień ubrania (${_selected.length})'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.ink),
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveOutfit(wardrobe),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: AppColors.paper,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text('Zapisz stylizację'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (wardrobe.outfits.isEmpty)
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Image.asset(
                      'assets/images/outfits_empty.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/outfits_empty.jpg',
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.bg.withOpacity(0.55),
                                AppColors.bg.withOpacity(0.92),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Brak zapisanych stylizacji.',
                                      style: displayFont(fontSize: 16), textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  const Text('Co dzisiaj założysz?',
                                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            ...wardrobe.outfits.reversed.map((outfit) => _savedOutfitCard(wardrobe, outfit)),
        ],
      ),
    );
  }

  Widget _savedOutfitCard(WardrobeProvider wardrobe, Outfit outfit) {
    final its = outfit.itemIds
        .map((id) => wardrobe.findItem(id))
        .whereType<ClothingItem>()
        .toList();
    final total = its.fold(0.0, (s, i) => s + i.price);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(outfit.name, style: displayFont(fontSize: 16)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: its.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) => SizedBox(
                width: 50,
                child: ClothingPhotoBox(item: its[i], height: 50, borderRadius: 4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Łączna wartość: ${fmtPrice(total)}',
              style: monoFont(fontSize: 12, color: AppColors.inkSoft)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => wardrobe.deleteOutfit(outfit.id),
              style: TextButton.styleFrom(foregroundColor: AppColors.wine, padding: EdgeInsets.zero),
              child: const Text('Usuń stylizację', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required String title, Widget? trailing, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: displayFont(fontSize: 18)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  final List<ClothingItem> items;
  final Set<String> initialSelected;

  const _ItemPickerSheet({required this.items, required this.initialSelected});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  late Set<String> _localSelected;
  ClothingCategory? _filterCat;

  @override
  void initState() {
    super.initState();
    _localSelected = Set<String>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final usedCats = ClothingCategory.values
        .where((c) => widget.items.any((i) => i.category == c))
        .toList();
    final visible = _filterCat == null
        ? widget.items
        : widget.items.where((i) => i.category == _filterCat).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wybierz ubrania', style: displayFont(fontSize: 20)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _catChip('Wszystkie', null),
                    ...usedCats.map((c) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _catChip('${c.icon} ${c.label}', c),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: visible.map((item) {
                      final isSelected = _localSelected.contains(item.id);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _localSelected.remove(item.id);
                          } else {
                            _localSelected.add(item.id);
                          }
                        }),
                        child: Container(
                          width: 96,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.wineSoft : Colors.white,
                            border: Border.all(
                                color: isSelected ? AppColors.wine : AppColors.line,
                                width: isSelected ? 2 : 1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              ClothingPhotoBox(item: item, height: 68, borderRadius: 4),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? AppColors.wine : AppColors.ink,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_localSelected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.paper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text('Gotowe (${_localSelected.length})'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _catChip(String label, ClothingCategory? cat) {
    final selected = _filterCat == cat;
    return GestureDetector(
      onTap: () => setState(() => _filterCat = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.ink : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: selected ? AppColors.paper : AppColors.inkSoft),
        ),
      ),
    );
  }
}
