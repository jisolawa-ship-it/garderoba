import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/clothing_tag_card.dart';
import 'add_item_sheet.dart';
import 'item_detail_screen.dart';

/// Garderoba - poziome chipy kategorii na stałe widoczne u góry + siatka
/// 2 kolumn bezpośrednio na ekranie, filtrowana na żywo wybranym chipem.
/// Świadomie bez osobnego arkusza do przeglądania kategorii (jak było
/// wcześniej) - to jedno, spójne miejsce zamiast dodatkowego kroku.
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  ClothingCategory? _selectedCategory; // null = "Wszystkie"
  String? _selectedSubcategory; // ma znaczenie tylko gdy _selectedCategory != null

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final items = wardrobe.items;
    final total = items.fold(0.0, (s, i) => s + (i.price ?? 0));

    final categoriesPresent =
        ClothingCategory.values.where((c) => items.any((i) => i.category == c)).toList();

    final visibleUnsorted = _selectedCategory == null
        ? items
        : items.where((i) {
            if (i.category != _selectedCategory) return false;
            if (_selectedSubcategory != null && i.subcategory != _selectedSubcategory) return false;
            return true;
          }).toList();
    final visible = [...visibleUnsorted]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Garderoba', style: displayFont(fontSize: 22)),
      ),
      body: items.isEmpty
          ? _emptyWardrobeHero(context)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  child: Row(
                    children: [
                      const Icon(Icons.checkroom_outlined, size: 15, color: AppColors.inkSoft),
                      const SizedBox(width: 6),
                      Text(
                        '${items.length} ${items.length == 1 ? "ubranie" : "ubrań"} · ${fmtPrice(total)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _filterChip('Wszystkie', _selectedCategory == null, () => setState(() {
                            _selectedCategory = null;
                            _selectedSubcategory = null;
                          })),
                      for (final c in categoriesPresent) ...[
                        const SizedBox(width: 8),
                        _categoryChip(c, items),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: visible.isEmpty
                      ? const Center(
                          child: Text('Brak ubrań w tej kategorii.',
                              style: TextStyle(color: AppColors.inkSoft)),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 212,
                          ),
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final item = visible[i];
                            return ClothingTagCard(
                              item: item,
                              onOpenDetail: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(itemId: item.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: _chipVisual(label, selected),
    );
  }

  Widget _chipVisual(String label, bool selected, {bool showCaret = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: selected ? AppColors.ink : AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppColors.paper : AppColors.inkSoft,
            ),
          ),
          if (showCaret) ...[
            const SizedBox(width: 3),
            Icon(Icons.expand_more,
                size: 14, color: selected ? AppColors.paper : AppColors.inkSoft),
          ],
        ],
      ),
    );
  }

  /// Chip kategorii - jeśli w tej kategorii są jakieś podkategorie wśród
  /// Twoich ubrań, dotknięcie otwiera rozwijaną listę do dalszego
  /// doprecyzowania (np. "Góra" → "Bluzka"/"Koszula"). Jeśli podkategorii
  /// brak, zachowuje się jak zwykły, pojedynczy filtr.
  Widget _categoryChip(ClothingCategory category, List<ClothingItem> items) {
    final subcats = items
        .where((i) => i.category == category)
        .map((i) => i.subcategory)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final isActive = _selectedCategory == category;
    final label = isActive && _selectedSubcategory != null
        ? '${category.label}: ${_selectedSubcategory!}'
        : category.label;

    if (subcats.isEmpty) {
      return _filterChip(label, isActive, () => setState(() {
            _selectedCategory = category;
            _selectedSubcategory = null;
          }));
    }

    return PopupMenuButton<String?>(
      // "null" oznacza "cała kategoria, bez zawężania do podkategorii".
      onSelected: (sub) => setState(() {
        _selectedCategory = category;
        _selectedSubcategory = sub;
      }),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text('Wszystkie · ${category.label}')),
        const PopupMenuDivider(),
        ...subcats.map((s) => PopupMenuItem(value: s, child: Text(s))),
      ],
      child: _chipVisual(label, isActive, showCaret: true),
    );
  }

  /// Pusty stan Garderoby - ten sam wzorzec co na pustym ekranie Stylizacji:
  /// tło (otwarta szafa) wypełnia całą szerokość ekranu, tekst i przycisk
  /// leżą bezpośrednio na zdjęciu, bez karty pod spodem. Umieszczone na
  /// pustej ścianie między drążkiem a podłogą - Alignment(0, 0.08) to
  /// wymierzony piksel po pikselu środek tej wolnej przestrzeni.
  ///
  /// SingleChildScrollView (a nie Stack wprost jako body) - inaczej niż w
  /// ListView na ekranie Stylizacji, tu Scaffold.body dostaje ograniczoną
  /// wysokość, co obcięłoby zdjęcie zamiast pozwolić mu przeskalować się do
  /// naturalnej wysokości (BoxFit.fitWidth potrzebuje nieograniczonej
  /// wysokości rodzica, żeby zadziałać poprawnie).
  Widget _emptyWardrobeHero(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        alignment: const Alignment(0, 0.08),
        children: [
          Image.asset(
            'assets/images/wardrobe_empty_bg.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          // 0.62 szerokości ekranu - mieści się w świetle otwartej szafy,
          // nie wychodzi na drzwiczki ani uchwyty.
          FractionallySizedBox(
            widthFactor: 0.62,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Twoja szafa jest pusta',
                    style: displayFont(fontSize: 17), textAlign: TextAlign.center),
                const SizedBox(height: 6),
                const Text(
                  'Dodaj pierwsze ubranie i zacznij budować swoją cyfrową garderobę.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showAddOptionsSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Dodaj ubranie', style: TextStyle(fontSize: 13)),
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
            ),
          ),
        ],
      ),
    );
  }
}
