import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/suggestion_engine.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/outfit_collage.dart';
import 'add_item_sheet.dart';
import 'fitting_room_screen.dart';

/// Nazwa proponowana dla świeżej (jeszcze niezapisanej) sugestii - główny
/// element kombinacji (sukienka/góra, w tej kolejności pierwszeństwa) i jego
/// podkategoria, jeśli jest ustawiona.
String _suggestedNameFor(List<ClothingItem> combo) {
  final dressMatch = combo.where((i) => i.category == ClothingCategory.dress);
  final topMatch = combo.where((i) => i.category == ClothingCategory.top);
  final main = dressMatch.isNotEmpty
      ? dressMatch.first
      : (topMatch.isNotEmpty ? topMatch.first : combo.first);
  return main.subcategory.isNotEmpty ? main.subcategory : main.name;
}

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Stylizacje', style: displayFont(fontSize: 26)),
        foregroundColor: AppColors.ink,
      ),
      // Poziomy margines (16px) NIE jest już własnością ListView (jak
      // wcześniej) - jest teraz doklejany osobno do każdego dziecka, poza
      // pustym stanem stylizacji. Dzięki temu tło pustego stanu może być
      // naturalnie pełnej szerokości ekranu, bez sztuczek typu ujemny
      // padding czy OverflowBox (który w tym miejscu - wewnątrz slivera o
      // nieograniczonej wysokości - powodował, że cały ekran renderował się
      // jako pusty).
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 40),
        children: [
          if (wardrobe.outfits.isEmpty)
            // Grafika z łukiem + przycisk na środku - jedyny stan, w którym
            // pokazujemy to duże tło. Sugestie NIE generują się same przy
            // wejściu na ekran (świadoma decyzja) - dopiero na wyraźne
            // dotknięcie przycisku appka losuje propozycję i pokazuje ją w
            // wyskakującym oknie do przejrzenia.
            _emptyOutfitsHero(wardrobe)
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _suggestStylization(wardrobe),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Zasugeruj stylizację'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(builder: (context) {
                final reversedOutfits = wardrobe.outfits.reversed.toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reversedOutfits.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.48,
                  ),
                  itemBuilder: (context, i) => _savedOutfitCard(wardrobe, reversedOutfits[i]),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _savedOutfitCard(WardrobeProvider wardrobe, Outfit outfit) {
    final its = outfit.itemIds
        .map((id) => wardrobe.findItem(id))
        .whereType<ClothingItem>()
        .toList();
    final total = its.fold(0.0, (s, i) => s + (i.price ?? 0));
    // cheap: true - może być zapisanych wiele stylizacji naraz w siatce.
    return GlassCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(10),
      cheap: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            outfit.name,
            style: displayFont(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          OutfitCollage(items: its),
          const SizedBox(height: 8),
          Text(fmtPrice(total),
              style: monoFont(fontSize: 11, color: AppColors.inkSoft)),
          const SizedBox(height: 8),
          Row(
            children: [
              // Jedyne miejsce, z którego appka otwiera Przymierzalnię dla
              // stylizacji - zawsze z JUŻ zapisanej stylizacji, do edycji.
              // Świeże sugestie (patrz _suggestStylization) są tylko do
              // przejrzenia i zapisania, nigdy nie prowadzą wprost tutaj.
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FittingRoomScreen(existingOutfit: outfit),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  ),
                  child: const Icon(Icons.accessibility_new_outlined, size: 16),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () => _proposeAlternative(wardrobe, outfit),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                  foregroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  // OutlinedButton domyślnie wymusza min. 64dp szerokości
                  // (Material), niezależnie od paddingu - z trzema
                  // przyciskami w rzędzie w wąskiej kolumnie siatki to
                  // przepełniało wiersz. Zerujemy minimalny rozmiar, żeby
                  // przycisk mógł być tak mały, jak faktycznie potrzebuje.
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Icon(Icons.shuffle, size: 16),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: () => wardrobe.deleteOutfit(outfit.id),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.wine.withValues(alpha: 0.4)),
                  foregroundColor: AppColors.wine,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Icon(Icons.delete_outline, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Świeża propozycja stylizacji "od zera" (na wyraźne dotknięcie przycisku
  /// "Zasugeruj stylizację" - nigdy automatycznie). Tylko do przejrzenia -
  /// bez przycisku "Użyj"/przejścia do Przymierzalni. Jedyna akcja poza
  /// zamknięciem to zapisanie jako nowa, samodzielna stylizacja (do niej
  /// można potem wejść do Przymierzalni przez "Edytuj" na jej karcie).
  void _suggestStylization(WardrobeProvider wardrobe) {
    if (wardrobe.items.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj więcej ubrań do szafy, żeby zobaczyć sugestie.')),
      );
      return;
    }
    final combos = SuggestionEngine.generate(wardrobe.items, wardrobe.outfits, count: 1);
    if (combos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak nowych propozycji - dodaj więcej ubrań albo zapisz istniejące stylizacje.'),
        ),
      );
      return;
    }
    final combo = combos.first;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.hero)),
        title: Text('Propozycja stylizacji', style: displayFont(fontSize: 16)),
        content: SizedBox(
          width: 220,
          child: OutfitCollage(items: combo.items),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Zamknij', style: TextStyle(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _suggestStylization(wardrobe);
            },
            child: const Text('Losuj inną', style: TextStyle(color: AppColors.gold)),
          ),
          ElevatedButton(
            onPressed: () async {
              await wardrobe.addOutfit(
                _suggestedNameFor(combo.items),
                combo.items.map((i) => i.id).toList(),
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zapisano jako nową stylizację.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
            child: const Text('Zapisz jako nową'),
          ),
        ],
      ),
    );
  }

  /// Proponuje alternatywę dla konkretnej, już zapisanej stylizacji -
  /// zamienia jeden element na lepiej dopasowany zamiennik i pokazuje to od
  /// razu jako wyskakujące okno z podglądem, bez otwierania Przymierzalni.
  /// Zapisanie tworzy NOWĄ, osobną stylizację - oryginał zostaje nietknięty.
  void _proposeAlternative(WardrobeProvider wardrobe, Outfit outfit) {
    final result = SuggestionEngine.proposeAlternative(
      outfit: outfit,
      allItems: wardrobe.items,
      outfits: wardrobe.outfits,
    );
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak dostępnej alternatywy - potrzeba więcej ubrań w tej kategorii.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.hero)),
        title: Text('Alternatywa dla „${outfit.name}”', style: displayFont(fontSize: 16)),
        content: SizedBox(
          width: 220,
          child: OutfitCollage(items: result.items),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj', style: TextStyle(color: AppColors.inkSoft)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _proposeAlternative(wardrobe, outfit);
            },
            child: const Text('Losuj inną', style: TextStyle(color: AppColors.gold)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Elementy bez zmian zachowują dokładną pozycję z oryginału;
              // nowy element przejmuje miejsce tego, który zastąpił.
              final newLayout = <String, OutfitItemLayout>{};
              final oldLayout = outfit.layout;
              for (final item in result.items) {
                if (item.id == result.addedItemId) {
                  final removedLayout = oldLayout?[result.removedItemId];
                  if (removedLayout != null) newLayout[item.id] = removedLayout;
                } else {
                  final same = oldLayout?[item.id];
                  if (same != null) newLayout[item.id] = same;
                }
              }
              await wardrobe.addOutfit(
                '${outfit.name} (alternatywa)',
                result.items.map((i) => i.id).toList(),
                layout: newLayout.isEmpty ? null : newLayout,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zapisano jako nową stylizację.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            ),
            child: const Text('Zapisz jako nową'),
          ),
        ],
      ),
    );
  }

  /// Pusty stan Stylizacji - tło (wnęka z łukiem, bez żadnej postaci)
  /// wypełnia całą szerokość ekranu, a tekst/przycisk są nałożone
  /// bezpośrednio na obraz, wyśrodkowane w świetle łuku - stąd [Stack]
  /// zamiast [EmptyStateCard]. Ułamek 0.08 w [Alignment] to wymierzony
  /// piksel po pikselu środek wnęki łuku w outfits_empty_bg.png (łuk
  /// zaczyna się ~18% wysokości, podłoga ~89%).
  ///
  /// Przycisk zależy od stanu szafy: bez ubrań - "Dodaj ubranie" (nie ma
  /// z czego proponować), z ubraniami - "Zasugeruj stylizację" (od razu
  /// otwiera wyskakujące okno z propozycją).
  Widget _emptyOutfitsHero(WardrobeProvider wardrobe) {
    final hasItems = wardrobe.items.isNotEmpty;
    return Stack(
      alignment: const Alignment(0, 0.08),
      children: [
        Image.asset(
          'assets/images/outfits_empty_bg.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        // 0.58 szerokości ekranu - tyle, ile ma światło łuku w tym miejscu,
        // żeby tekst i przycisk nie wychodziły na złoty obrys. Bez karty pod
        // spodem - sam tekst leży bezpośrednio na zdjęciu (tło jest na tyle
        // jasne, że ciemny tytuł zachowuje dobry kontrast).
        FractionallySizedBox(
          widthFactor: 0.58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Brak zapisanych stylizacji',
                  style: displayFont(fontSize: 17), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                hasItems
                    ? 'Zobacz propozycję dopasowaną do Twojej szafy.'
                    : 'Zacznij od dodania pierwszych ubrań do szafy.',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: hasItems
                      ? () => _suggestStylization(wardrobe)
                      : () => showAddOptionsSheet(context),
                  icon: Icon(hasItems ? Icons.auto_awesome : Icons.add, size: 16),
                  label: Text(hasItems ? 'Zasugeruj stylizację' : 'Dodaj ubranie',
                      style: const TextStyle(fontSize: 13)),
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
    );
  }
}
