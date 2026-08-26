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
      // pustym stanem stylizacji. Dzięki temu karta pustego stanu może być
      // naturalnie pełnej szerokości ekranu (heroImage), bez sztuczek typu
      // ujemny padding czy OverflowBox (który w tym miejscu - wewnątrz
      // slivera o nieograniczonej wysokości - powodował, że cały ekran
      // renderował się jako pusty).
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
            _emptyOutfitsHero(wardrobe)
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

  /// Pusty stan Stylizacji - w odróżnieniu od reszty ekranów appki, to NIE
  /// jest zdjęcie nad kartą, tylko odwrócona kolejność: tło (wnęka z łukiem,
  /// bez żadnej postaci) wypełnia całą szerokość ekranu, a tekst/przycisk są
  /// nałożone bezpośrednio na obraz, wyśrodkowane w świetle łuku - stąd
  /// [Stack] zamiast [EmptyStateCard]. Ułamek 0.54 w [Alignment] to
  /// wymierzony piksel po pikselu środek wnęki łuku w
  /// outfits_empty_bg.png (łuk zaczyna się ~18% wysokości, podłoga ~89%).
  Widget _emptyOutfitsHero(WardrobeProvider wardrobe) {
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
                wardrobe.items.isEmpty
                    ? 'Zacznij od dodania pierwszych ubrań do szafy.'
                    : 'Stwórz swoją pierwszą stylizację w Przymierzalni (zakładka Home).',
                style: const TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                textAlign: TextAlign.center,
              ),
              if (wardrobe.items.isEmpty) ...[
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
            ],
          ),
        ),
      ],
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
