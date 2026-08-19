import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/clothing_photo_box.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/outfit_collage.dart';
import 'add_item_sheet.dart';
import 'fitting_room_screen.dart';

const _weekdayNames = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Niedz'];

/// Kalendarz stylizacji - tydzień "od dzisiaj" (dziś + kolejne 6 dni), po
/// jednej stylizacji na dzień. Świadomie bez widoku miesięcznego i bez AI -
/// to planowanie zawsze darmowe, dalszy wgląd (historia, miesiąc) to
/// przyszła funkcja premium.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final today = dateOnly(DateTime.now());
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Kalendarz', style: displayFont(fontSize: 22)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _dayCard(context, wardrobe, days[i], isToday: i == 0),
      ),
    );
  }

  Widget _dayCard(BuildContext context, WardrobeProvider wardrobe, DateTime day, {required bool isToday}) {
    final entry = wardrobe.entryForDate(day);
    final outfit = entry != null ? wardrobe.findOutfit(entry.outfitId) : null;
    final label = '${_weekdayNames[day.weekday - 1]} · ${day.day}.${day.month.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _openDaySheet(context, wardrobe, day, existingOutfit: outfit),
      child: GlassCard(
        radius: AppRadius.card,
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'DZISIAJ' : label.split(' · ').first.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${day.day}.${day.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.line),
            const SizedBox(width: 12),
            if (outfit == null)
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 18, color: AppColors.inkSoft),
                    const SizedBox(width: 8),
                    const Text('Zaplanuj stylizację',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                  ],
                ),
              )
            else
              Expanded(
                child: Row(
                  children: [
                    _outfitThumbnails(wardrobe, outfit),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        outfit.name,
                        style: displayFont(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }

  Widget _outfitThumbnails(WardrobeProvider wardrobe, Outfit outfit) {
    final its = outfit.itemIds
        .map((id) => wardrobe.findItem(id))
        .where((i) => i != null)
        .take(3)
        .toList();
    return SizedBox(
      width: 34 + (its.length - 1) * 16,
      height: 34,
      child: Stack(
        children: [
          for (var i = 0; i < its.length; i++)
            Positioned(
              left: i * 16.0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.paper, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClothingPhotoBox(item: its[i]!, height: 34, borderRadius: 8),
              ),
            ),
        ],
      ),
    );
  }

  void _openDaySheet(
    BuildContext context,
    WardrobeProvider wardrobe,
    DateTime day, {
    Outfit? existingOutfit,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _DaySheet(day: day, existingOutfit: existingOutfit),
    );
  }
}

class _DaySheet extends StatelessWidget {
  final DateTime day;
  final Outfit? existingOutfit;
  const _DaySheet({required this.day, this.existingOutfit});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final label = '${_weekdayNames[day.weekday - 1]}, ${day.day}.${day.month.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: displayFont(fontSize: 18)),
          const SizedBox(height: 10),
          if (existingOutfit != null) ...[
            SizedBox(
              width: 160,
              child: OutfitCollage(
                items: existingOutfit!.itemIds
                    .map((id) => wardrobe.findItem(id))
                    .whereType<ClothingItem>()
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Text(existingOutfit!.name, style: displayFont(fontSize: 15)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FittingRoomScreen(
                        existingOutfit: existingOutfit,
                        plannedDate: day,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.accessibility_new_outlined, size: 16),
                label: const Text('Edytuj w Przymierzalni'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  wardrobe.removePlannedOutfit(day);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.wine),
                  foregroundColor: AppColors.wine,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                child: const Text('Usuń z kalendarza'),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.line),
            const SizedBox(height: 10),
            const Text('Zmień na inną stylizację:', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
            const SizedBox(height: 10),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FittingRoomScreen(plannedDate: day),
                    ),
                  );
                },
                icon: const Icon(Icons.accessibility_new_outlined, size: 16),
                label: const Text('Stwórz w Przymierzalni'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Albo wybierz z zapisanych stylizacji:',
                style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
            const SizedBox(height: 10),
          ],
          if (wardrobe.outfits.isEmpty)
            EmptyStateCard(
              compact: true,
              compactIcon: Icons.style_outlined,
              title: 'Brak zapisanych stylizacji',
              subtitle: wardrobe.items.isEmpty
                  ? 'Zacznij od dodania pierwszych ubrań do szafy.'
                  : 'Stwórz pierwszą w Przymierzalni albo w zakładce Stylizacje.',
              // Przycisk tylko wtedy, gdy brak ubrań to jedyna prawdziwa
              // przyczyna - jeśli ubrania są, właściwe CTA (Przymierzalnia)
              // jest już widoczne wyżej w tym samym arkuszu.
              buttonLabel: wardrobe.items.isEmpty ? 'Dodaj ubranie' : null,
              onButtonTap: wardrobe.items.isEmpty
                  ? () {
                      Navigator.pop(context);
                      showAddOptionsSheet(context);
                    }
                  : null,
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: wardrobe.outfits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final outfit = wardrobe.outfits[i];
                  final isCurrent = existingOutfit?.id == outfit.id;
                  return GestureDetector(
                    onTap: isCurrent
                        ? null
                        : () => _pickOutfit(context, wardrobe, day, outfit, hasExisting: existingOutfit != null),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primarySoft : AppColors.bg,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(outfit.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          if (isCurrent)
                            const Text('obecna', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                        ],
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

  void _pickOutfit(
    BuildContext context,
    WardrobeProvider wardrobe,
    DateTime day,
    Outfit outfit, {
    required bool hasExisting,
  }) {
    if (!hasExisting) {
      Navigator.pop(context);
      wardrobe.planOutfit(day, outfit.id);
      return;
    }

    // Zasada Human in Control: nadpisanie już zaplanowanego dnia wymaga
    // jawnego potwierdzenia, nigdy nie dzieje się "po cichu".
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.paper,
        title: const Text('Nadpisać zaplanowaną stylizację?'),
        content: Text('Na ten dzień masz już zaplanowaną inną stylizację. Zastąpić ją "${outfit.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Anuluj')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              wardrobe.planOutfit(day, outfit.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Zastąp'),
          ),
        ],
      ),
    );
  }
}
