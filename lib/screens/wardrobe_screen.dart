import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/clothing_tag_card.dart';
import 'add_item_sheet.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final items = wardrobe.items;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Garderoba', style: displayFont(fontSize: 26)),
        foregroundColor: AppColors.ink,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        onPressed: () => showAddItemSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wardrobe_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withOpacity(0.94),
                    AppColors.bg.withOpacity(0.86),
                    AppColors.bg.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),
          items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Twoja szafa jest pusta.\nDotknij +, żeby dodać pierwsze ubranie.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.inkSoft),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    _allItemsTile(context, wardrobe, items),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: ClothingCategory.values
                          .where((c) => items.any((i) => i.category == c))
                          .map((c) => _categoryTile(context, wardrobe, items, c))
                          .toList(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _allItemsTile(BuildContext context, WardrobeProvider wardrobe, List<ClothingItem> items) {
    final total = items.fold(0.0, (s, i) => s + i.price);
    return GestureDetector(
      onTap: () => _showItemsSheet(context, wardrobe, category: null, title: 'Wszystkie ubrania'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.checkroom, color: AppColors.paper, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wszystkie ubrania', style: displayFont(fontSize: 16, color: AppColors.paper)),
                  const SizedBox(height: 2),
                  Text('${items.length} rzeczy · ${fmtPrice(total)}',
                      style: TextStyle(fontSize: 12, color: AppColors.paper.withOpacity(0.75))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.paper.withOpacity(0.85)),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(
    BuildContext context,
    WardrobeProvider wardrobe,
    List<ClothingItem> items,
    ClothingCategory category,
  ) {
    final inCat = items.where((i) => i.category == category).toList();
    final total = inCat.fold(0.0, (s, i) => s + i.price);
    return GestureDetector(
      onTap: () => _showItemsSheet(context, wardrobe, category: category, title: category.label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.bgSoft, shape: BoxShape.circle),
              child: Center(child: Text(category.icon, style: const TextStyle(fontSize: 17))),
            ),
            const SizedBox(height: 10),
            Text(category.label, style: displayFont(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              inCat.isEmpty ? 'Brak ubrań' : '${inCat.length} rzeczy · ${fmtPrice(total)}',
              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemsSheet(
    BuildContext context,
    WardrobeProvider wardrobe, {
    required ClothingCategory? category,
    required String title,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _CategoryItemsSheet(
        wardrobe: wardrobe,
        category: category,
        title: title,
      ),
    );
  }
}

class _CategoryItemsSheet extends StatefulWidget {
  final WardrobeProvider wardrobe;
  final ClothingCategory? category;
  final String title;

  const _CategoryItemsSheet({
    required this.wardrobe,
    required this.category,
    required this.title,
  });

  @override
  State<_CategoryItemsSheet> createState() => _CategoryItemsSheetState();
}

class _CategoryItemsSheetState extends State<_CategoryItemsSheet> {
  String? _filterSub;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.wardrobe,
      builder: (context, _) {
        final items = widget.wardrobe.items;
        List<ClothingItem> inCat = widget.category == null
            ? items
            : items.where((i) => i.category == widget.category).toList();

        final subs = widget.category == null
            ? <String>[]
            : inCat.map((i) => i.subcategory).where((s) => s.isNotEmpty).toSet().toList();

        List<ClothingItem> visible = _filterSub == null
            ? inCat
            : inCat.where((i) => i.subcategory == _filterSub).toList();
        visible = List<ClothingItem>.from(visible)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
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
                      Text(widget.title, style: displayFont(fontSize: 22)),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  if (subs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip('Wszystkie', _filterSub == null, () {
                            setState(() => _filterSub = null);
                          }),
                          ...subs.map((s) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _chip(s, _filterSub == s, () {
                                  setState(() => _filterSub = s);
                                }),
                              )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(
                            child: Text('Brak ubrań w tej kategorii.',
                                style: TextStyle(color: AppColors.inkSoft)),
                          )
                        : SingleChildScrollView(
                            controller: scrollController,
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 18,
                              children: visible
                                  .map((item) => ClothingTagCard(
                                        item: item,
                                        onWear: () => widget.wardrobe.wearItem(item.id),
                                        onUnwear: () => widget.wardrobe.unwearItem(item.id),
                                        onDelete: () => _confirmDelete(context, widget.wardrobe, item),
                                      ))
                                  .toList(),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WardrobeProvider wardrobe, ClothingItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usunąć ubranie?'),
        content: Text('Na pewno usunąć "${item.name}" z szafy?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
          TextButton(
            onPressed: () {
              wardrobe.deleteItem(item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Usuń', style: TextStyle(color: AppColors.wine)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.ink : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.paper : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
