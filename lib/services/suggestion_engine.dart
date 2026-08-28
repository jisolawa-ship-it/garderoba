import 'dart:math';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../theme.dart';

class SuggestionCombo {
  final List<ClothingItem> items;
  final String? basedOnOutfitName;

  SuggestionCombo(this.items, {this.basedOnOutfitName});

  double get total => items.fold(0.0, (s, i) => s + (i.price ?? 0));

  String get sortedKey {
    final ids = items.map((i) => i.id).toList()..sort();
    return ids.join('|');
  }
}

class _History {
  final Map<String, int> itemPairs;
  final Map<String, int> subcatPairs;
  _History(this.itemPairs, this.subcatPairs);
}

class SuggestionEngine {
  static final Random _rand = Random();

  /// Szuka najlepiej pasującego ubrania z danej kategorii do tego, co już
  /// jest wybrane (np. na manekinie w Przymierzalni) - ta sama logika
  /// dopasowania kolorystycznego + historii noszenia co przy zwykłych
  /// sugestiach stylizacji, tylko wywoływana wprost, na żądanie (nigdy
  /// automatycznie), dla jednej wskazanej kategorii.
  static ClothingItem? bestMatchForCategory({
    required List<ClothingItem> currentItems,
    required List<ClothingItem> allItems,
    required List<Outfit> outfits,
    required ClothingCategory category,
  }) {
    final currentIds = currentItems.map((i) => i.id).toSet();
    final pool = allItems
        .where((i) => i.category == category && !currentIds.contains(i.id))
        .toList();
    if (pool.isEmpty) return null;
    if (currentItems.isEmpty) return _shuffled(pool).first;

    final history = _buildHistory(allItems, outfits);
    ClothingItem? best;
    double bestScore = -1;
    for (final candidate in _shuffled(pool)) {
      var score = 0.0;
      for (final anchor in currentItems) {
        score += _pairScore(anchor, candidate, history);
      }
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best;
  }

  static String _subcatKey(ClothingItem item) =>
      '${item.category.name}:${item.subcategory}';

  static List<T> _shuffled<T>(List<T> list) {
    final copy = List<T>.from(list);
    copy.shuffle(_rand);
    return copy;
  }

  /// Jak _shuffled, ale z lekkim naciskiem na rzadko/nigdy nienoszone
  /// ubrania - wciąż losowe (nie zawsze te same rzeczy na górze), ale
  /// statystycznie częściej wypychające zapomniane ubrania w stronę sugestii.
  static List<ClothingItem> _weightedOrder(List<ClothingItem> list) {
    final copy = _shuffled(list);
    copy.sort((a, b) => _wearBonus(b).compareTo(_wearBonus(a)));
    return copy;
  }

  static _History _buildHistory(List<ClothingItem> items, List<Outfit> outfits) {
    final itemPairs = <String, int>{};
    final subcatPairs = <String, int>{};
    for (final outfit in outfits) {
      final its = outfit.itemIds
          .map((id) => _findById(items, id))
          .whereType<ClothingItem>()
          .toList();
      for (var i = 0; i < its.length; i++) {
        for (var j = i + 1; j < its.length; j++) {
          final pKey = ([its[i].id, its[j].id]..sort()).join('|');
          itemPairs[pKey] = (itemPairs[pKey] ?? 0) + 1;
          final sKey = ([_subcatKey(its[i]), _subcatKey(its[j])]..sort()).join('|');
          subcatPairs[sKey] = (subcatPairs[sKey] ?? 0) + 1;
        }
      }
    }
    return _History(itemPairs, subcatPairs);
  }

  static double _pairScore(ClothingItem a, ClothingItem b, _History history) {
    double score = 0;
    final aNeutral = isNeutralColor(a.colorHex) || a.colorHex == 'multi';
    final bNeutral = isNeutralColor(b.colorHex) || b.colorHex == 'multi';
    if (aNeutral && bNeutral) {
      score += 3;
    } else if (aNeutral || bNeutral) {
      score += 2;
    } else if (a.colorHex == b.colorHex) {
      score += 2;
    } else {
      score += 1;
    }
    final pKey = ([a.id, b.id]..sort()).join('|');
    final sKey = ([_subcatKey(a), _subcatKey(b)]..sort()).join('|');
    score += (history.itemPairs[pKey] ?? 0) * 5;
    score += (history.subcatPairs[sKey] ?? 0) * 2;
    // Premiujemy ubrania rzadko/nigdy nienoszone - appka ma aktywnie pomagać
    // "odkurzać" zapomniane rzeczy w szafie, nie tylko dobierać kolorystycznie.
    score += _wearBonus(a) + _wearBonus(b);
    return score;
  }

  /// Im rzadziej noszone ubranie, tym większy bonus w sugestiach - zero
  /// noszeń to największa premia (prawdziwe "martwe" ubranie, najbardziej
  /// warte przypomnienia), powyżej kilku noszeń bonus znika całkowicie.
  static double _wearBonus(ClothingItem item) {
    if (item.wears == 0) return 3;
    if (item.wears <= 3) return 1.5;
    return 0;
  }

  static ClothingItem? _bestMatch(
    List<ClothingItem> pool,
    ClothingItem anchor,
    List<String> excludeIds,
    _History history,
  ) {
    final candidates = pool.where((i) => !excludeIds.contains(i.id)).toList();
    if (candidates.isEmpty) return null;
    final shuffled = _shuffled(candidates);
    shuffled.sort((x, y) =>
        _pairScore(anchor, y, history).compareTo(_pairScore(anchor, x, history)));
    return shuffled.first;
  }

  /// Generuje do [count] propozycji stylizacji.
  static List<SuggestionCombo> generate(
    List<ClothingItem> items,
    List<Outfit> outfits, {
    int count = 4,
  }) {
    final tops = items.where((i) => i.category == ClothingCategory.top).toList();
    final bottoms = items.where((i) => i.category == ClothingCategory.bottom).toList();
    final dresses = items.where((i) => i.category == ClothingCategory.dress).toList();
    final shoes = items.where((i) => i.category == ClothingCategory.shoes).toList();
    final outerwear = items.where((i) => i.category == ClothingCategory.outerwear).toList();
    final accessories = items.where((i) => i.category == ClothingCategory.accessory).toList();

    final savedSetKeys = outfits
        .map((o) => (List<String>.from(o.itemIds)..sort()).join('|'))
        .toSet();
    final history = _buildHistory(items, outfits);

    final results = <SuggestionCombo>[];
    final seen = <String>{};

    void tryAdd(List<ClothingItem> combo, {String? basedOn}) {
      if (combo.length < 2) return;
      final key = (combo.map((i) => i.id).toList()..sort()).join('|');
      if (seen.contains(key) || savedSetKeys.contains(key)) return;
      seen.add(key);
      results.add(SuggestionCombo(combo, basedOnOutfitName: basedOn));
    }

    // Zawsze świeże kombinacje z całej szafy - appka nigdy nie "podmienia"
    // pojedynczej rzeczy w już zapisanej, przemyślanej stylizacji. Kolejność
    // przetasowana z lekkim naciskiem na rzadko/nigdy nienoszone ubrania jako
    // punkt startowy (nie tylko przy dobieraniu reszty), żeby faktycznie
    // pomagać "odkurzać" zapomniane rzeczy, a nie tylko dobierać kolory.

    // 1. Świeże kombinacje z sukienkami
    if (results.length < count) {
      for (final dress in _weightedOrder(dresses).take(2)) {
        final combo = <ClothingItem>[dress];
        final sh = _bestMatch(shoes, dress, combo.map((i) => i.id).toList(), history);
        if (sh != null) combo.add(sh);
        if (_rand.nextDouble() > 0.4) {
          final out = _bestMatch(outerwear, dress, combo.map((i) => i.id).toList(), history);
          if (out != null) combo.add(out);
        }
        if (_rand.nextDouble() > 0.5) {
          final acc = _bestMatch(accessories, dress, combo.map((i) => i.id).toList(), history);
          if (acc != null) combo.add(acc);
        }
        tryAdd(combo);
      }
    }

    // 2. Świeże kombinacje góra + dół
    if (results.length < count) {
      for (final top in _weightedOrder(tops).take(min(tops.length, 5))) {
        if (results.length >= count + 2) break;
        final combo = <ClothingItem>[top];
        final bottom = _bestMatch(bottoms, top, combo.map((i) => i.id).toList(), history);
        if (bottom == null) continue;
        combo.add(bottom);
        final sh = _bestMatch(shoes, top, combo.map((i) => i.id).toList(), history);
        if (sh != null) combo.add(sh);
        if (_rand.nextDouble() > 0.5) {
          final out = _bestMatch(outerwear, top, combo.map((i) => i.id).toList(), history);
          if (out != null) combo.add(out);
        }
        if (_rand.nextDouble() > 0.6) {
          final acc = _bestMatch(accessories, top, combo.map((i) => i.id).toList(), history);
          if (acc != null) combo.add(acc);
        }
        tryAdd(combo);
      }
    }

    return results.take(count).toList();
  }
}

ClothingItem? _findById(List<ClothingItem> items, String id) {
  for (final i in items) {
    if (i.id == id) return i;
  }
  return null;
}
