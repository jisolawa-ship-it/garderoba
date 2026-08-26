import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/clothing_photo_box.dart';
import '../widgets/glass_card.dart';
import 'add_item_sheet.dart';
import 'fitting_room_screen.dart';

/// Pełny ekran szczegółów jednego ubrania - dotąd dostępny był tylko skrócony
/// widok karty w arkuszu Garderoby. To osobny, klikalny cel nawigacji.
class ItemDetailScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final item = wardrobe.findItem(itemId);

    if (item == null) {
      // Ubranie mogło zostać usunięte w międzyczasie (np. z innego ekranu).
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(backgroundColor: AppColors.bg, elevation: 0),
        body: const Center(
          child: Text('To ubranie już nie istnieje.', style: TextStyle(color: AppColors.inkSoft)),
        ),
      );
    }

    final badge = badgeForItem(item);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text(item.name.isEmpty ? 'Bez nazwy' : item.name, style: displayFont(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'Edytuj',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showAddItemSheet(context, existingItem: item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FullscreenPhotoView(item: item),
                    fullscreenDialog: true,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: SizedBox(
                        width: 128,
                        height: 128,
                        child: ClothingPhotoBox(item: item, height: 128, borderRadius: AppRadius.card),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.zoom_in, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty ? 'Bez nazwy' : item.name,
                      style: displayFont(fontSize: 19),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(item.category.iconData, size: 13, color: AppColors.inkSoft),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${item.category.label}${item.subcategory.isNotEmpty ? ' · ${item.subcategory}' : ''}',
                            style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(colorNameFor(item.colorHex),
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                    const SizedBox(height: 10),
                    Text(
                      item.price != null ? fmtPrice(item.price!) : '— brak ceny',
                      style: monoFont(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: item.price != null ? AppColors.ink : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.needsCompletion)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: GlassCard(
                radius: AppRadius.card,
                child: Row(
                  children: [
                    Icon(Icons.edit_note, size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('To ubranie wymaga uzupełnienia nazwy i/lub ceny.',
                          style: TextStyle(fontSize: 12, color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badge.bgColor, borderRadius: BorderRadius.circular(20)),
            child: Text(badge.label,
                style: TextStyle(fontSize: 12, color: badge.color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          GlassCard(
            radius: AppRadius.card,
            child: Row(
              children: [
                _statColumn('Noszone', '${item.wears}×'),
                _divider(),
                _statColumn(
                  'Koszt/noszenie',
                  item.costPerWear != null ? fmtPrice(item.costPerWear!) : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FittingRoomScreen(initialItemIds: [item.id]),
                ),
              ),
              icon: const Icon(Icons.accessibility_new_outlined, size: 18),
              label: const Text('Przymierz w Przymierzalni'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: item.wears == 0 ? null : () => wardrobe.unwearItem(item.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.line),
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  ),
                  child: const Text('↩ Cofnij'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => wardrobe.wearItem(item.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    elevation: 0,
                  ),
                  child: const Text('+ Załóż'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _confirmDelete(context, wardrobe, item),
              style: TextButton.styleFrom(foregroundColor: AppColors.wine),
              child: const Text('Usuń ubranie'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: displayFont(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 34, color: AppColors.line);

  void _confirmDelete(BuildContext context, WardrobeProvider wardrobe, ClothingItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper,
        title: const Text('Usunąć ubranie?'),
        content: Text('"${item.name.isEmpty ? "To ubranie" : item.name}" zostanie usunięte z szafy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
          TextButton(
            onPressed: () {
              wardrobe.deleteItem(item.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.wine),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }
}

/// Pełnoekranowy podgląd zdjęcia - otwierany dotknięciem miniaturki na
/// Szczegółach ubrania. Zamyka się dotknięciem gdziekolwiek albo strzałką
/// wstecz.
class _FullscreenPhotoView extends StatelessWidget {
  final ClothingItem item;
  const _FullscreenPhotoView({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: ClothingPhotoBox(item: item, height: 500, borderRadius: 0),
          ),
        ),
      ),
    );
  }
}
