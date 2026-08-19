import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/suggestion_engine.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/clothing_photo_box.dart';
import '../widgets/clothing_sticker.dart';
import '../widgets/glass_card.dart';

const _weekdayShort = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];

class FittingRoomScreen extends StatefulWidget {
  /// Edycja już zapisanej stylizacji - przywraca jej układ (jeśli był
  /// zapisany) i nazwę. Ma pierwszeństwo przed [initialItemIds].
  final Outfit? existingOutfit;

  /// Świeży start z konkretnymi ubraniami (np. jedno ubranie ze Szczegółów),
  /// bez zapisanego układu - rozkładane w rzędzie jak przy ręcznym dodawaniu.
  final List<String>? initialItemIds;

  /// Jeśli appka trafiła tu z konkretnego dnia w Kalendarzu, po zapisaniu
  /// od razu proponuje zaplanowanie stylizacji na ten dzień.
  final DateTime? plannedDate;

  /// Gdy true (wejście z Home), po zapisaniu ekran NIE zamyka się - zamiast
  /// tego czyści płótno i zostaje otwarty, gotowy na kolejną stylizację.
  /// We wszystkich pozostałych miejscach (Stylizacje, Kalendarz, Szczegóły
  /// ubrania) po zapisaniu appka wraca tam, skąd przyszła - to już domyślne
  /// zachowanie nawigacji, nie wymaga osobnej flagi.
  final bool keepOpenAfterSave;

  const FittingRoomScreen({
    super.key,
    this.existingOutfit,
    this.initialItemIds,
    this.plannedDate,
    this.keepOpenAfterSave = false,
  });

  @override
  State<FittingRoomScreen> createState() => _FittingRoomScreenState();
}

class _FittingRoomScreenState extends State<FittingRoomScreen> {
  final _uuid = const Uuid();
  final List<StickerData> _stickers = [];
  String? _selectedStickerId;
  bool _initialItemsPlaced = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  ClothingCategory? _filterCategory;

  // Ten sam przybliżony rozmiar płótna używany wszędzie tam, gdzie appka
  // dodaje ubranie bez znajomości faktycznych wymiarów w danym momencie
  // (np. z panelu bocznego, z sugestii) - odzwierciedla węższe płótno,
  // odkąd panel z ubraniami stoi z boku, nie na dole na pełną szerokość.
  static const _approxCanvasSize = Size(230, 420);

  @override
  void initState() {
    super.initState();
    final hasInitialContent = widget.existingOutfit != null ||
        (widget.initialItemIds != null && widget.initialItemIds!.isNotEmpty);
    if (hasInitialContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final wardrobe = context.read<WardrobeProvider>();
        setState(() => _placeInitialItems(wardrobe, _approxCanvasSize));
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _placeInitialItems(WardrobeProvider wardrobe, Size canvasSize) {
    if (_initialItemsPlaced) return;
    _initialItemsPlaced = true;

    final existing = widget.existingOutfit;
    if (existing != null) {
      // Przywróć dokładny zapisany układ - a jeśli jakiegoś elementu
      // zabrakło w zapisie (starsza stylizacja bez layoutu), rozłóż go
      // w rzędzie razem z resztą, żeby nic nie zniknęło.
      final missing = <ClothingItem>[];
      for (final itemId in existing.itemIds) {
        final item = wardrobe.findItem(itemId);
        if (item == null) continue;
        final saved = existing.layout?[itemId];
        if (saved != null) {
          _stickers.add(StickerData(
            id: _uuid.v4(),
            item: item,
            position: Offset(saved.x, saved.y),
            scale: saved.scale,
            rotation: saved.rotation,
          ));
        } else {
          missing.add(item);
        }
      }
      if (missing.isNotEmpty) _placeInRow(missing, canvasSize);
      return;
    }

    final ids = widget.initialItemIds;
    if (ids == null || ids.isEmpty) return;
    final items = ids.map(wardrobe.findItem).whereType<ClothingItem>().toList();
    _placeInRow(items, canvasSize);
  }

  void _placeInRow(List<ClothingItem> items, Size canvasSize) {
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;
    final offsetStep = 26.0;
    final startOffset = -offsetStep * (items.length - 1) / 2;
    for (var i = 0; i < items.length; i++) {
      _stickers.add(StickerData(
        id: _uuid.v4(),
        item: items[i],
        position: Offset(centerX + startOffset + offsetStep * i, centerY),
      ));
    }
  }

  void _addItem(ClothingItem item, Size canvasSize) {
    setState(() {
      final id = _uuid.v4();
      _stickers.add(StickerData(
        id: id,
        item: item,
        position: Offset(canvasSize.width / 2, canvasSize.height / 2),
      ));
      _selectedStickerId = id;
    });
  }

  void _removeSticker(String id) {
    setState(() {
      _stickers.removeWhere((s) => s.id == id);
      if (_selectedStickerId == id) _selectedStickerId = null;
    });
  }

  void _bringToFront(String id) {
    setState(() {
      final idx = _stickers.indexWhere((s) => s.id == id);
      if (idx == -1) return;
      final s = _stickers.removeAt(idx);
      _stickers.add(s);
      _selectedStickerId = id;
    });
  }

  void _clearAll() {
    setState(() {
      _stickers.clear();
      _selectedStickerId = null;
    });
  }

  void _openSaveSheet(BuildContext context) {
    if (_stickers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj przynajmniej jedno ubranie, zanim zapiszesz.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SaveOutfitSheet(
        initialName: widget.existingOutfit?.name ?? '',
        initialPlannedDate: widget.plannedDate,
        onSave: (name, plannedDate) => _save(context, name, plannedDate),
      ),
    );
  }

  void _openSuggestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zasugeruj', style: displayFont(fontSize: 18)),
            const SizedBox(height: 4),
            const Text(
              'Wybierz, do czego chcesz podpowiedź - appka dobierze najlepiej pasujący element z Twojej szafy.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ClothingCategory.values
                  .map((c) => GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _suggestForCategory(context, c);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(c.iconData, size: 15, color: AppColors.inkSoft),
                              const SizedBox(width: 6),
                              Text(c.label, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _suggestForCategory(BuildContext context, ClothingCategory category) {
    final wardrobe = context.read<WardrobeProvider>();
    final currentItems = _stickers.map((s) => s.item).toList();
    final match = SuggestionEngine.bestMatchForCategory(
      currentItems: currentItems,
      allItems: wardrobe.items,
      outfits: wardrobe.outfits,
      category: category,
    );

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Brak dostępnych ubrań w kategorii "${category.label}".')),
      );
      return;
    }

    _addItem(match, _approxCanvasSize);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dodano "${match.name.isEmpty ? category.label : match.name}" - możesz to zmienić.')),
    );
  }

  Future<void> _save(BuildContext context, String name, DateTime? plannedDate) async {
    final wardrobe = context.read<WardrobeProvider>();
    final itemIds = _stickers.map((s) => s.item.id).toList();
    final layout = <String, OutfitItemLayout>{
      for (final s in _stickers)
        s.item.id: OutfitItemLayout(x: s.position.dx, y: s.position.dy, scale: s.scale, rotation: s.rotation),
    };

    String outfitId;
    if (widget.existingOutfit != null) {
      outfitId = widget.existingOutfit!.id;
      await wardrobe.updateOutfit(outfitId, name: name, itemIds: itemIds, layout: layout);
    } else {
      outfitId = await wardrobe.addOutfit(name, itemIds, layout: layout);
    }

    if (plannedDate != null) {
      final existingEntry = wardrobe.entryForDate(plannedDate);
      final needsConfirm = existingEntry != null && existingEntry.outfitId != outfitId;
      if (needsConfirm) {
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.paper,
            title: const Text('Nadpisać zaplanowaną stylizację?'),
            content: const Text('Na ten dzień masz już zaplanowaną inną stylizację.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Anuluj')),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('Zastąp'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await wardrobe.planOutfit(plannedDate, outfitId);
        }
      } else {
        await wardrobe.planOutfit(plannedDate, outfitId);
      }
    }

    if (!context.mounted) return;

    if (widget.keepOpenAfterSave) {
      // Wejście z Home - zostajemy otwarci, czyścimy płótno, gotowe na
      // kolejną stylizację zamiast wracać do Home.
      setState(() {
        _stickers.clear();
        _selectedStickerId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            plannedDate != null
                ? 'Zapisano i zaplanowano. Możesz stworzyć kolejną stylizację.'
                : 'Stylizacja zapisana. Możesz stworzyć kolejną.',
          ),
        ),
      );
    } else {
      // Wszystkie pozostałe wejścia - wracamy tam, skąd appka tu trafiła.
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(plannedDate != null ? 'Zapisano i zaplanowano.' : 'Stylizacja zapisana.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final items = wardrobe.items;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Przymierzalnia', style: displayFont(fontSize: 22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: () => _openSuggestSheet(context),
              icon: const Icon(Icons.auto_awesome, size: 15, color: AppColors.primary),
              label: const Text('Zasugeruj', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primarySoft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
            ),
          ),
          if (_stickers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: const Text('Wyczyść', style: TextStyle(color: AppColors.inkSoft, fontSize: 13)),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStickerId = null),
                          child: Container(
                            width: canvasSize.width,
                            height: canvasSize.height,
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppColors.softCardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  // Manekin na tle różowej wnęki - jedno gotowe
                                  // zdjęcie (światło, cień i głębia są już w
                                  // fotografii), więc bez dodatkowej poświaty.
                                  child: Image.asset(
                                    'assets/images/mannequin_fitting_room.jpg',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                  ),
                                ),
                                if (_stickers.isEmpty)
                                  Positioned(
                                    right: 12,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.paper.withOpacity(0.92),
                                          borderRadius: BorderRadius.circular(AppRadius.pill),
                                          boxShadow: AppColors.cardShadow,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.keyboard_double_arrow_right,
                                                size: 15, color: AppColors.primary),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              width: 60,
                                              child: Text(
                                                'Wybierz ubranie z boku',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.ink,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                for (final sticker in _stickers)
                                  ClothingSticker(
                                    key: ValueKey(sticker.id),
                                    data: sticker,
                                    selected: sticker.id == _selectedStickerId,
                                    onTap: () => _bringToFront(sticker.id),
                                    onRemove: () => _removeSticker(sticker.id),
                                    onChanged: () {},
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_stickers.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openSaveSheet(context),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(widget.existingOutfit != null ? 'Zapisz zmiany' : 'Zapisz stylizację'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _itemSidePanel(items),
        ],
      ),
    );
  }

  Widget _itemSidePanel(List<ClothingItem> items) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = items.where((i) {
      if (_filterCategory != null && i.category != _filterCategory) return false;
      if (query.isNotEmpty && !i.name.toLowerCase().contains(query)) return false;
      return true;
    }).toList();

    return Container(
      width: 122,
      margin: const EdgeInsets.fromLTRB(0, 8, 12, 12),
      child: GlassCard(
        radius: AppRadius.card,
        padding: const EdgeInsets.all(8),
        child: items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Dodaj najpierw ubrania w zakładce Szafa.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 11), textAlign: TextAlign.center),
                ),
              )
            : Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Szukaj…',
                      hintStyle: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                      prefixIcon: const Icon(Icons.search, size: 15, color: AppColors.inkSoft),
                      prefixIconConstraints: const BoxConstraints(minWidth: 28),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _miniCategoryChip(null, Icons.apps),
                        for (final c in ClothingCategory.values) _miniCategoryChip(c, c.iconData),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('Brak wyników', style: TextStyle(fontSize: 10, color: AppColors.inkSoft)),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return GestureDetector(
                                onTap: () => _addItem(item, _approxCanvasSize),
                                child: Column(
                                  children: [
                                    ClothingPhotoBox(item: item, height: 64, borderRadius: 10),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.name.isEmpty ? 'Bez nazwy' : item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _miniCategoryChip(ClothingCategory? category, IconData icon) {
    final selected = _filterCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() => _filterCategory = category),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : AppColors.bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: selected ? Colors.white : AppColors.inkSoft),
        ),
      ),
    );
  }
}

/// Okno zapisu - nazwa stylizacji + opcjonalne zaplanowanie na jeden z
/// najbliższych 7 dni (ten sam zakres co Kalendarz, żeby appka nie
/// obiecywała planowania dalej niż faktycznie pozwala darmowa wersja).
class _SaveOutfitSheet extends StatefulWidget {
  final String initialName;
  final DateTime? initialPlannedDate;
  final void Function(String name, DateTime? plannedDate) onSave;

  const _SaveOutfitSheet({
    required this.initialName,
    required this.initialPlannedDate,
    required this.onSave,
  });

  @override
  State<_SaveOutfitSheet> createState() => _SaveOutfitSheetState();
}

class _SaveOutfitSheetState extends State<_SaveOutfitSheet> {
  late final TextEditingController _nameCtrl;
  late bool _planDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _planDay = widget.initialPlannedDate != null;
    _selectedDay = widget.initialPlannedDate ?? dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zapisz stylizację', style: displayFont(fontSize: 18)),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              autofocus: widget.initialName.isEmpty,
              decoration: InputDecoration(
                hintText: 'np. Na spotkanie',
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => setState(() => _planDay = !_planDay),
              child: Row(
                children: [
                  Checkbox(
                    value: _planDay,
                    onChanged: (v) => setState(() => _planDay = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const Text('Zaplanuj też w kalendarzu', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            if (_planDay) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final selected = _selectedDay != null && isSameDate(_selectedDay!, day);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        width: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              i == 0 ? 'Dziś' : _weekdayShort[day.weekday - 1],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.ink,
                              ),
                            ),
                            Text(
                              '${day.day}.${day.month.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: selected ? Colors.white70 : AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Podaj nazwę stylizacji.')),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  widget.onSave(name, _planDay ? _selectedDay : null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  elevation: 0,
                ),
                child: const Text('Zapisz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
