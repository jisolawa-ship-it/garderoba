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
import '../widgets/suggestion_card.dart';
import 'add_item_sheet.dart';
import 'fitting_room_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  List<SuggestionCombo> _suggestions = [];
  bool _generated = false;

  void _regenerateSuggestions(WardrobeProvider wardrobe) {
    setState(() {
      _suggestions = SuggestionEngine.generate(wardrobe.items, wardrobe.outfits);
    });
  }

  // Tworzenie stylizacji zawsze odbywa się w Przymierzalni (wejście z Home
  // albo stąd, po dotknięciu sugestii) - to jedyne miejsce w appce, gdzie
  // faktycznie układa się i zapisuje nową stylizację.
  void _useSuggestion(List<ClothingItem> combo, String suggestedName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FittingRoomScreen(initialItemIds: combo.map((i) => i.id).toList()),
      ),
    );
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
          // Sugestie stylizacji wymagają czegoś w szafie, żeby cokolwiek
          // zaproponować - przy pustej Garderobie panel tylko zajmowałby
          // miejsce nad pustym stanem poniżej, więc pokazujemy go dopiero,
          // gdy jest z czego sugerować.
          if (wardrobe.items.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _panel(
                title: 'Sugestie stylizacji',
                trailing: ElevatedButton.icon(
                  onPressed: () => _regenerateSuggestions(wardrobe),
                  icon: const Icon(Icons.shuffle, size: 15),
                  label: const Text('Losuj inne', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  ),
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
            ),
            const SizedBox(height: 16),
          ],
          if (wardrobe.outfits.isEmpty)
            // Pełne tło z łukiem tylko wtedy, gdy szafa jest naprawdę pusta -
            // to jedyny sensowny "od czego zacząć" komunikat w tym stanie.
            // Gdy ubrania już są, "Sugestie stylizacji" nad tym blokiem
            // pokazują konkretne propozycje - duże zdjęcie pod nimi
            // wyglądało wtedy na zbędny, urwany dodatek (bez przycisku,
            // z samym tekstem "stwórz w Przymierzalni"), więc dostaje
            // zamiast tego jeden, konkretny przycisk.
            wardrobe.items.isEmpty ? _emptyOutfitsHero() : _suggestOutfitButton()
          else
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
                ),
                child: const Icon(Icons.delete_outline, size: 16),
              ),
            ],
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

  /// Pusty stan Stylizacji, TYLKO gdy szafa też jest pusta (patrz miejsce
  /// wywołania) - w odróżnieniu od reszty ekranów appki, to NIE jest
  /// zdjęcie nad kartą, tylko odwrócona kolejność: tło (wnęka z łukiem, bez
  /// żadnej postaci) wypełnia całą szerokość ekranu, a tekst/przycisk są
  /// nałożone bezpośrednio na obraz, wyśrodkowane w świetle łuku - stąd
  /// [Stack] zamiast [EmptyStateCard]. Ułamek 0.08 w [Alignment] to
  /// wymierzony piksel po pikselu środek wnęki łuku w
  /// outfits_empty_bg.png (łuk zaczyna się ~18% wysokości, podłoga ~89%).
  Widget _emptyOutfitsHero() {
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
              const Text(
                'Zacznij od dodania pierwszych ubrań do szafy.',
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
    );
  }

  /// Gdy szafa NIE jest pusta, ale nie ma jeszcze zapisanej stylizacji -
  /// "Sugestie stylizacji" nad tym miejscem już pokazują konkretne
  /// propozycje, więc zamiast dużego zdjęcia z łukiem wystarczy jeden,
  /// wyraźny przycisk, który od razu otwiera Przymierzalnię z pierwszą
  /// sugestią (albo pustym płótnem, jeśli sugestii jeszcze nie ma - np.
  /// przy tylko jednym ubraniu w szafie).
  Widget _suggestOutfitButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: ElevatedButton.icon(
          onPressed: () {
            if (_suggestions.isNotEmpty) {
              final s = _suggestions.first;
              _useSuggestion(s.items, s.basedOnOutfitName ?? '');
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FittingRoomScreen()),
              );
            }
          },
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Zasugeruj stylizację'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _panel({required String title, Widget? trailing, required Widget child}) {
    return GlassCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(14),
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
