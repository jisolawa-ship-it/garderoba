import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final items = wardrobe.items;

    final totalValue = items.fold(0.0, (s, i) => s + i.price);
    final worn = items.where((i) => i.wears > 0).toList();
    final avgCpw = worn.isEmpty
        ? 0.0
        : worn.fold(0.0, (s, i) => s + i.price / i.wears) / worn.length;
    final neverWorn = items.length - worn.length;

    ClothingItem? mostExpensive;
    if (items.isNotEmpty) {
      mostExpensive = items.reduce((a, b) => a.price >= b.price ? a : b);
    }
    ClothingItem? bestValueItem;
    if (worn.isNotEmpty) {
      bestValueItem = worn.reduce(
          (a, b) => (a.price / a.wears) <= (b.price / b.wears) ? a : b);
    }

    final byCat = <ClothingCategory, double>{
      for (final c in ClothingCategory.values) c: 0,
    };
    for (final i in items) {
      byCat[i.category] = (byCat[i.category] ?? 0.0) + i.price;
    }
    final maxCat = byCat.values.isEmpty ? 1.0 : (byCat.values.reduce((a, b) => a > b ? a : b)).clamp(1.0, double.infinity).toDouble();

    final withCpw = worn.map((i) => MapEntry(i, i.price / i.wears)).toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final best = withCpw.take(5).toList();

    final worstWorn = withCpw.where((e) => e.value >= 20).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final neverWornItems = items.where((i) => i.wears == 0 && i.price > 0).toList()
      ..sort((a, b) => b.price.compareTo(a.price));

    final firstName = wardrobe.user?.displayName?.trim().split(' ').first;
    final greeting = (firstName != null && firstName.isNotEmpty)
        ? 'Dzień dobry, $firstName! ✨'
        : 'Dzień dobry! ✨';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Podsumowanie', style: displayFont(fontSize: 22)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(width: 36, height: 1, color: AppColors.line),
                              const SizedBox(width: 6),
                              const Icon(Icons.auto_awesome, size: 11, color: AppColors.mustard),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(greeting,
                              style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                          const SizedBox(height: 2),
                          const Text('Świetnie wygląda Twoja szafa!',
                              style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/summary_box.jpg',
                        width: 90,
                        height: 145,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                    children: [
                      _statCard(
                        Icons.image_outlined,
                        'Wartość szafy',
                        fmtPrice(totalValue),
                        onTap: () => _showInfoSheet(
                          context,
                          'Wartość szafy wg kategorii',
                          _categoryBreakdownContent(byCat, maxCat),
                        ),
                      ),
                      _statCard(Icons.checkroom_outlined, 'Liczba ubrań', '${items.length}'),
                      _statCard(Icons.payments_outlined, 'Śr. koszt noszenia', worn.isEmpty ? '—' : fmtPrice(avgCpw)),
                      _statCard(Icons.favorite_border, 'Nienoszone', '$neverWorn'),
                      _statCard(
                        Icons.diamond_outlined,
                        'Najdroższy zakup',
                        mostExpensive == null ? '—' : fmtPrice(mostExpensive.price),
                        subtitle: mostExpensive?.name ?? 'Brak ubrań',
                        onTap: () => _showInfoSheet(
                          context,
                          'Warto przemyśleć (drogie / rzadko noszone)',
                          _worthConsideringContent(worstWorn, neverWornItems),
                        ),
                      ),
                      _statCard(
                        Icons.emoji_events_outlined,
                        'Najlepszy zakup',
                        bestValueItem == null
                            ? '—'
                            : '${fmtPrice(bestValueItem.price / bestValueItem.wears)}/nosz.',
                        subtitle: bestValueItem?.name ?? 'Zacznij nosić ubrania',
                        onTap: () => _showInfoSheet(
                          context,
                          'Najlepsze zakupy (najniższy koszt noszenia)',
                          _bestPurchasesContent(best),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx2, scrollController) => Padding(
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
                  Expanded(child: Text(title, style: displayFont(fontSize: 19))),
                  IconButton(
                    onPressed: () => Navigator.of(ctx2).pop(),
                    icon: const Icon(Icons.close, color: AppColors.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryBreakdownContent(Map<ClothingCategory, double> byCat, double maxCat) {
    return Column(
      children: ClothingCategory.values.map((c) {
        final value = byCat[c] ?? 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text('${c.icon} ${c.label}',
                    style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value / maxCat,
                    minHeight: 10,
                    backgroundColor: AppColors.bgSoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.ink),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: Text(fmtPrice(value),
                    textAlign: TextAlign.right, style: monoFont(fontSize: 12)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _bestPurchasesContent(List<MapEntry<ClothingItem, double>> best) {
    return best.isEmpty
        ? const Text('Zacznij nosić swoje ubrania, żeby zobaczyć statystyki.',
            style: TextStyle(color: AppColors.inkSoft))
        : Column(
            children: best
                .map((e) => _pickRow(e.key.name, '${fmtPrice(e.value)} / noszenie · ${e.key.wears}×'))
                .toList(),
          );
  }

  Widget _worthConsideringContent(
    List<MapEntry<ClothingItem, double>> worstWorn,
    List<ClothingItem> neverWornItems,
  ) {
    return (worstWorn.isEmpty && neverWornItems.isEmpty)
        ? const Text('Brak ubrań wymagających uwagi — dobra robota!',
            style: TextStyle(color: AppColors.inkSoft))
        : Column(
            children: [
              ...worstWorn.take(6).map((e) => _pickRow(e.key.name, '${fmtPrice(e.value)} / noszenie')),
              ...neverWornItems
                  .take(6)
                  .map((i) => _pickRow(i.name, '${fmtPrice(i.price)} · nigdy nie noszone')),
            ],
          );
  }

  Widget _statCard(IconData icon, String label, String value, {String? subtitle, VoidCallback? onTap}) {
    final fontSize = value.length > 10 ? 13.0 : 17.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: AppColors.bgSoft, shape: BoxShape.circle),
                  child: Icon(icon, size: 12, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(label.toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: AppColors.inkSoft, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, maxLines: 1, style: displayFont(fontSize: fontSize)),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.inkSoft)),
                  ),
              ],
            ),
            if (onTap != null)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.chevron_right, size: 16, color: AppColors.inkSoft.withOpacity(0.6)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pickRow(String name, String meta) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Text(meta, style: monoFont(fontSize: 11, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: displayFont(fontSize: 17)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
