import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../state/nav_controller.dart';
import '../state/wardrobe_provider.dart';
import '../theme.dart';
import '../widgets/clothing_photo_box.dart';
import '../widgets/glass_card.dart';
import 'add_item_sheet.dart';
import 'bulk_add_screen.dart';
import 'fitting_room_screen.dart';
import 'item_detail_screen.dart';
import 'summary_screen.dart';

/// Mała etykieta z ikoną NAD kartą (nie wewnątrz niej) - "DZISIAJ" nad
/// kartą planu dnia, "WSKAZÓWKI" nad karuzelą wskazówek. Top-level (nie
/// metoda na [DashboardScreen]), żeby korzystał z niej też stan karuzeli
/// ([_TipCarouselState]) w tym samym pliku.
Widget _sectionEyebrow({required IconData icon, required String label}) {
  return Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            )),
      ],
    ),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final firstName = _firstName(wardrobe.user?.displayName);

    if (wardrobe.items.isEmpty) {
      return _OnboardingView(firstName: firstName);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        // Zamiast sztywnej liczby, licz realną wysokość paska nawigacji
        // (patrz home_screen.dart: SizedBox 80 + padding 16 + bezpieczny
        // margines urządzenia) + własny oddech - żeby "Stwórz stylizację"
        // nigdy nie chowało się częściowo pod paskiem na telefonach
        // z wyższym marginesem systemowym na dole.
        padding: EdgeInsets.only(
          bottom: 96 + MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          _hero(context, wardrobe, firstName),
          _greeting(firstName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _incompleteBanner(context, wardrobe),
                _todayCard(context),
                const SizedBox(height: 14),
                _TipCarousel(tips: _localTips(wardrobe)),
                const SizedBox(height: 22),
                _createOutfitButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _firstName(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) return '';
    return displayName.trim().split(' ').first;
  }

  Widget _hero(BuildContext context, WardrobeProvider wardrobe, String firstName) {
    final hasIncomplete = wardrobe.items.any((i) => i.needsCompletion);
    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Zdjęcie samo w sobie ma naturalne wygaszenie do kremu na samym
          // dole (przycięte tuż za nim w źródłowym pliku - bez zbędnego,
          // płaskiego, pustego pasa, który wcześniej robił tu ogromną,
          // martwą lukę przed powitaniem). Positioned niżej domyka ostatnie
          // kilkanaście jednostek różnicy koloru między końcem zdjęcia a
          // tłem appki, na wypadek gdyby BoxFit.cover przy szerszych
          // ekranach ściął odrobinę więcej niż to naturalne wygaszenie.
          Image.asset(
            'assets/images/home_hero.jpg',
            fit: BoxFit.cover,
            // Lekki bias w górę - na szerszych ekranach (gdzie BoxFit.cover
            // musi przyciąć górę/dół, nie tylko boki) wolimy ściąć odrobinę
            // z już wygaszonego dołu niż z sufitu/żyrandola u góry.
            alignment: const Alignment(0, -0.2),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            // Kolor docelowy MUSI być tłem Scaffolda (AppColors.bg), nie
            // AppColors.paper - to dwa różne odcienie kremu. Gradient
            // wygaszający do złego koloru robił dokładnie ten sam efekt
            // "widocznej linii", który miał usuwać.
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withValues(alpha: 0.0),
                    AppColors.bg,
                  ],
                ),
              ),
            ),
          ),
          // Delikatna "podkładka" pod logo i napis - Positioned (nie goły
          // Container w Stack.expand), żeby naprawdę zajmowała tylko górne
          // 170px, a nie rozciągała się na całą wysokość zdjęcia.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.paper.withValues(alpha: 0.85),
                    AppColors.paper.withValues(alpha: 0.5),
                    AppColors.paper.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Image.asset('assets/images/logo_hanger.png', height: 40),
                  const SizedBox(height: 6),
                  Text('SZAFNIK',
                      style: displayFont(fontSize: 22, letterSpacing: 4, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  const Text('Twoja garderoba. Twój styl.',
                      style: TextStyle(fontSize: 11, color: AppColors.gold, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _heartDivider(),
                ],
              ),
            ),
          ),
          // Positioned (nie goły dziecko Stacka) - żeby nie był rozciągany
          // przez StackFit.expand na całą wysokość zdjęcia, co wcześniej
          // przez domyślne wyśrodkowanie Row w pionie sprawiało, że ikonki
          // lądowały na środku zamiast w rogu.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skrót do Kalendarza/Podsumowania - dawniej pod "...", ale
                    // to menu skrótów, nie "więcej opcji przy tym elemencie",
                    // więc hamburger po lewej pasuje do niego lepiej.
                    _heroIconButton(
                      icon: Icons.menu,
                      onTap: () => _showQuickMenu(context),
                    ),
                    // Czerwona kropka pojawia się tylko wtedy, gdy jest coś
                    // realnie do zrobienia (te same, niedokończone ubrania co
                    // w banerze niżej) - nigdy jako czysto dekoracyjna plakietka
                    // bez pokrycia w faktycznym stanie appki.
                    _heroIconButton(
                      icon: Icons.notifications_none_rounded,
                      badge: hasIncomplete,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Powiadomienia pojawią się tutaj w przyszłości.')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Powitanie - świadomie POZA fotografią w tle (nie jako Positioned na
  /// zdjęciu), tak żeby zawsze siedziało na jednolitym kremowym tle appki.
  /// Dzięki temu jego czytelność i pozycja nie zależą od tego, gdzie
  /// dokładnie kończy się rozmycie zdjęcia w danym kadrowaniu.
  Widget _greeting(String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  firstName.isEmpty ? 'Dzień dobry' : 'Dzień dobry, $firstName',
                  style: displayFont(fontSize: 24),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite_border, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Gotowa stworzyć kolejną stylizację?',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heartDivider() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 28, height: 1, color: AppColors.gold.withValues(alpha: 0.6)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.favorite, size: 10, color: AppColors.gold),
        ),
        Container(width: 28, height: 1, color: AppColors.gold.withValues(alpha: 0.6)),
      ],
    );
  }

  Widget _heroIconButton({required IconData icon, required VoidCallback onTap, bool badge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.ink),
          ),
          if (badge)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.wine,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paper, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(sheetContext).padding.bottom),
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
              title: const Text('Kalendarz'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<NavTabController>().goTo(NavTabs.calendar);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined, color: AppColors.primary),
              title: const Text('Podsumowanie'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SummaryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Zamiast prawdziwego powiadomienia systemowego (co wymagałoby nowych
  /// uprawnień i całej infrastruktury) - widoczny w appce baner. Rozpoznawanie
  /// zdjęć jest na tyle szybkie (kilkanaście sekund lokalnie), że appka i tak
  /// zwykle jest wciąż otwarta, kiedy się kończy - baner na Home w zupełności
  /// wystarcza, żeby nie zgubić informacji o niedokończonych ubraniach.
  Widget _incompleteBanner(BuildContext context, WardrobeProvider wardrobe) {
    final count = wardrobe.items.where((i) => i.needsCompletion).length;
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => context.read<NavTabController>().goTo(NavTabs.wardrobe),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_note, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  count == 1
                      ? '1 ubranie czeka na uzupełnienie (nazwa/cena).'
                      : '$count ubrań czeka na uzupełnienie (nazwa/cena).',
                  style: const TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _todayCard(BuildContext context) {
    final wardrobe = context.watch<WardrobeProvider>();
    final today = dateOnly(DateTime.now());
    final entry = wardrobe.entryForDate(today);
    final outfit = entry != null ? wardrobe.findOutfit(entry.outfitId) : null;
    final outfitItems = outfit != null
        ? outfit.itemIds.map((id) => wardrobe.findItem(id)).whereType<ClothingItem>().toList()
        : const <ClothingItem>[];

    return GestureDetector(
      onTap: () => context.read<NavTabController>().goTo(NavTabs.calendar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionEyebrow(icon: Icons.calendar_today_outlined, label: 'DZISIAJ'),
          const SizedBox(height: 8),
          GlassCard(
            radius: AppRadius.hero,
            child: Row(
              children: [
                _miniOutfitThumb(outfitItems),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (outfit != null) ...[
                        Text(outfit.name, style: displayFont(fontSize: 15)),
                        const SizedBox(height: 2),
                        const Text('Zaplanowana stylizacja - dotknij, żeby zobaczyć',
                            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      ] else ...[
                        Text('Nie masz jeszcze zaplanowanej stylizacji',
                            style: displayFont(fontSize: 15)),
                        const SizedBox(height: 2),
                        const Text('Dotknij, żeby ją stworzyć',
                            style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.inkSoft),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Miniaturka planu dnia - realne zdjęcia ubrań z zaplanowanej stylizacji
  /// (do 4, w siatce 2x2), albo neutralna ikonka kalendarza, gdy nic jeszcze
  /// nie jest zaplanowane. Nigdy przykładowe/nierzeczywiste zdjęcie.
  Widget _miniOutfitThumb(List<ClothingItem> items) {
    const size = 56.0;
    if (items.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary),
      );
    }
    if (items.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: ClothingPhotoBox(item: items.first, height: size, borderRadius: 12),
        ),
      );
    }
    final shown = items.take(4).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: shown
              .map((i) => ClothingPhotoBox(item: i, height: size / 2, borderRadius: 4))
              .toList(),
        ),
      ),
    );
  }

  /// Pula wskazówek wygenerowanych lokalnie z danych o szafie - BEZ żadnego
  /// zapytania do AI (zgodnie z zasadą: AI tylko na kliknięcie, nigdy
  /// automatycznie w tle). To zwykłe reguły, nie sztuczna inteligencja.
  ///
  /// Każda reguła ma własny warunek odblokowania - appka pokazuje na start
  /// tylko proste wskazówki, a bardziej rozbudowane pojawiają się dopiero,
  /// gdy w szafie jest wystarczająco dużo danych, żeby miały sens. Dzięki
  /// temu appka sprawia wrażenie, że "rośnie" razem z Twoją szafą, zamiast
  /// pokazywać od razu wszystko naraz.
  static List<_TipEntry> _localTips(WardrobeProvider wardrobe) {
    final items = wardrobe.items;
    if (items.isEmpty) return [];

    final worn = items.where((i) => i.wears > 0).toList();
    final totalWears = items.fold(0, (s, i) => s + i.wears);
    final tips = <_TipEntry>[];

    // --- Poziom 1: dostępne od pierwszego ubrania ---

    final neverWorn = items.where((i) => i.wears == 0).length;
    if (neverWorn > 0) {
      tips.add(_TipEntry(
        'Masz $neverWorn ${neverWorn == 1 ? "ubranie, które" : "ubrań, które"} czeka na pierwsze założenie.',
        // Dedykowany panel "Martwy kapitał" jest teraz precyzyjniejszym celem
        // niż ogólne "Warto przemyśleć" (które łączy to z drogimi ubraniami).
        (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => const SummaryScreen(autoOpen: SummarySheetTarget.deadCapital),
        )),
      ));
    }

    if (worn.isNotEmpty) {
      final mostWorn = [...worn]..sort((a, b) => b.wears.compareTo(a.wears));
      final mostWornItem = mostWorn.first;
      tips.add(_TipEntry(
        '${mostWornItem.name} to Twój najczęściej noszony element (${mostWornItem.wears}×).',
        // Wskazówka dotyczy jednego, konkretnego ubrania - prowadzi wprost
        // do jego Szczegółów, nie do ogólnego Podsumowania, i pokazuje jego
        // realne zdjęcie zamiast ogólnej ikonki.
        (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => ItemDetailScreen(itemId: mostWornItem.id),
        )),
        item: mostWornItem,
      ));

      final withCost = worn.where((i) => i.costPerWear != null).toList();
      if (withCost.isNotEmpty) {
        final byCostPerWear = [...withCost]
          ..sort((a, b) => a.costPerWear!.compareTo(b.costPerWear!));
        final bestItem = byCostPerWear.first;
        tips.add(_TipEntry(
          '${bestItem.name} kosztuje Cię już tylko ${bestItem.costPerWear!.toStringAsFixed(2)} zł za każde noszenie.',
          (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => ItemDetailScreen(itemId: bestItem.id),
          )),
          item: bestItem,
        ));
      }
    }

    // --- Poziom 2: odblokowuje się przy 8+ ubraniach - wzorce w szafie ---

    if (items.length >= 8) {
      final byCategory = <ClothingCategory, int>{};
      for (final i in items) {
        byCategory[i.category] = (byCategory[i.category] ?? 0) + 1;
      }
      final topCategory = byCategory.entries.reduce((a, b) => a.value >= b.value ? a : b);
      tips.add(_TipEntry(
        'Najwięcej masz w kategorii "${topCategory.key.label}" - ${topCategory.value} ubrań.',
        (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => const SummaryScreen(autoOpen: SummarySheetTarget.categoryBreakdown),
        )),
      ));

      final byColor = <String, int>{};
      for (final i in items) {
        if (i.colorHex == 'multi') continue;
        byColor[i.colorHex] = (byColor[i.colorHex] ?? 0) + 1;
      }
      if (byColor.isNotEmpty) {
        final topColor = byColor.entries.reduce((a, b) => a.value >= b.value ? a : b);
        tips.add(_TipEntry(
          '${colorNameFor(topColor.key)} to kolor, który wybierasz najczęściej.',
          (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
            builder: (_) => const SummaryScreen(autoOpen: SummarySheetTarget.colorBreakdown),
          )),
        ));
      }
    }

    // --- Poziom 3: odblokowuje się przy 15+ ubraniach - podróż z appką ---

    if (items.length >= 15) {
      final earliest = items.map((i) => i.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
      final totalValue = items.fold(0.0, (s, i) => s + (i.price ?? 0));
      final months = DateTime.now().difference(earliest).inDays ~/ 30;
      final period = months >= 1 ? '$months ${months == 1 ? "miesiąc" : "miesiące"}' : 'ostatni czas';
      tips.add(_TipEntry(
        'Przez $period zbudowałaś szafę wartą ${totalValue.toStringAsFixed(0)} zł.',
        (ctx) => Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => const SummaryScreen(autoOpen: SummarySheetTarget.categoryBreakdown),
        )),
      ));
    }

    // --- Poziom 4: odblokowuje się przy 20+ założeniach łącznie - zaangażowanie ---

    if (totalWears >= 20) {
      // Uczciwie: appka nigdzie nie pokazuje sumy wszystkich założeń -
      // brak konkretnego miejsca docelowego, prowadzi ogólnie do Podsumowania.
      tips.add(_TipEntry(
        'Założyłaś ubrania ze swojej szafy już $totalWears razy w sumie. 🌿',
        (ctx) => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SummaryScreen())),
      ));
    }

    // --- Zawsze dostępna "siatka bezpieczeństwa", żeby appka nigdy nie
    // pokazała pustki, nawet z bardzo małą szafą. ---
    final totalValue = items.fold(0.0, (s, i) => s + (i.price ?? 0));
    tips.add(_TipEntry(
      'Twoja szafa liczy ${items.length} ${items.length == 1 ? "ubranie" : "ubrań"} o wartości ${totalValue.toStringAsFixed(0)} zł.',
      (ctx) => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SummaryScreen())),
    ));

    return tips;
  }

  Widget _createOutfitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FittingRoomScreen(keepOpenAfterSave: true)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 18),
            SizedBox(width: 8),
            Text('Stwórz stylizację', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Jedna wskazówka - treść + gdzie ma prowadzić po dotknięciu. [item],
/// jeśli podany, to konkretne ubranie, którego wskazówka dotyczy (np.
/// "najczęściej noszone") - karta pokazuje wtedy jego realne zdjęcie
/// zamiast ogólnej ikonki. Nie każda wskazówka ma taki naturalny punkt
/// odniesienia (np. "wartość całej szafy") - wtedy zostaje ikonka.
class _TipEntry {
  final String text;
  final void Function(BuildContext context) onTap;
  final ClothingItem? item;
  _TipEntry(this.text, this.onTap, {this.item});
}

/// Karuzela wskazówek - przełącza się automatycznie co kilka sekund, da się
/// też przesunąć palcem. Kropki na dole pokazują, gdzie jesteśmy.
class _TipCarousel extends StatefulWidget {
  final List<_TipEntry> tips;
  const _TipCarousel({required this.tips});

  @override
  State<_TipCarousel> createState() => _TipCarouselState();
}

class _TipCarouselState extends State<_TipCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.tips.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final next = (_page + 1) % widget.tips.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionEyebrow(icon: Icons.auto_awesome, label: 'WSKAZÓWKI'),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.tips.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: _tipCardContent(widget.tips[i]),
            ),
          ),
        ),
        if (widget.tips.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.tips.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tipCardContent(_TipEntry entry) {
    return GestureDetector(
      onTap: () => entry.onTap(context),
      child: GlassCard(
        radius: AppRadius.hero,
        child: Row(
          children: [
            if (entry.item != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: ClothingPhotoBox(item: entry.item!, height: 44, borderRadius: 12),
                ),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco_outlined, size: 20, color: AppColors.primary),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(entry.text, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pierwszy ekran dla zupełnie nowej użytkowniczki (pusta szafa) - zamiast
/// normalnego pulpitu Home (który i tak nie miałby sensu bez żadnych danych:
/// puste wskazówki, "Dzisiaj" bez planu itd.) appka pokazuje TYLKO jedno,
/// skupione zadanie: dodanie pierwszych ubrań. Wraca do zwykłego Home
/// automatycznie, gdy tylko szafa przestanie być pusta.
class _OnboardingView extends StatelessWidget {
  final String firstName;
  const _OnboardingView({required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset('assets/images/logo_hanger.png', height: 52),
              const SizedBox(height: 10),
              Text('SZAFNIK',
                  style: displayFont(fontSize: 24, letterSpacing: 4, color: AppColors.ink)),
              const SizedBox(height: 24),
              Text(
                firstName.isEmpty ? 'Witaj w Szafniku!' : 'Witaj, $firstName!',
                style: displayFont(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Zacznijmy od dodania pierwszych ubrań do Twojej cyfrowej szafy.',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _onboardingOption(
                icon: Icons.edit_outlined,
                title: 'Dodaj ręcznie',
                description:
                    'Jedno ubranie na raz - zdjęcie, nazwa, kategoria, kolor, cena. '
                    'Najdokładniejszy sposób, dobry na spokojny start.',
                onTap: () => showAddItemSheet(context),
              ),
              const SizedBox(height: 14),
              _onboardingOption(
                icon: Icons.photo_library_outlined,
                title: 'Dodaj grupowo',
                description:
                    'Wybierasz od razu kilka zdjęć - appka sama spróbuje rozpoznać '
                    'kategorię i kolor każdego ubrania. Szybszy start, jeśli masz dużo do dodania.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BulkAddScreen()),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onboardingOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: GlassCard(
          radius: AppRadius.card,
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: Icon(icon, size: 21, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: displayFont(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
