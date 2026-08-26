import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/suggestion_engine.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/empty_state_card.dart';
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
            EmptyStateCard(
              imageAsset: 'assets/images/outfits_empty.png',
              heroImage: true,
              heroSideMargin: 16,
              // outfits_empty.png ma sporo pustej ściany nad głowicą manekina
              // (żeby przy pełnej wysokości nic z sylwetki się nie ucinało) -
              // 853/990 przycina tylko ten nadmiar u góry (BoxFit.cover +
              // Alignment.bottomCenter w EmptyStateCard), dolna krawędź
              // (stopy stojaka na podłodze) zawsze zostaje w całości, więc
              // kafelek mieści się na ekranie bez utraty żadnego fragmentu
              // manekina.
              heroAspectRatio: 853 / 990,
              title: 'Brak zapisanych stylizacji',
              subtitle: wardrobe.items.isEmpty
                  ? 'Zacznij od dodania pierwszych ubrań do szafy.'
                  : 'Stwórz swoją pierwszą stylizację w Przymierzalni (zakładka Home).',
              buttonLabel: wardrobe.items.isEmpty ? 'Dodaj ubranie' : null,
              onButtonTap: wardrobe.items.isEmpty ? () => showAddOptionsSheet(context) : null,
            )
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
