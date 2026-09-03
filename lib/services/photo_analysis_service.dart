import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/clothing_item.dart';
import '../theme.dart';

/// Wynik automatycznej analizy zdjęcia - to tylko PROPOZYCJA do wypełnienia
/// formularza. Nic z tego nie zapisuje się samo - użytkowniczka zawsze widzi
/// wynik w formularzu i musi go świadomie zatwierdzić (albo poprawić) zanim
/// cokolwiek trafi do szafy.
class PhotoAnalysisResult {
  final ClothingCategory? category;
  final String? colorHex;

  PhotoAnalysisResult({this.category, this.colorHex});
}

/// Jedna reguła: etykieta z ML Kit -> kategoria ubrania, z wagą mówiącą, jak
/// mocnym to jest dowodem. Wzorzec ze spacją to FRAZA (dopasowywana do całej
/// etykiety), bez spacji - pojedyncze słowo (dopasowywane jako całe słowo).
class _LabelRule {
  final String pattern;
  final ClothingCategory category;
  final double weight;

  const _LabelRule(this.pattern, this.category, this.weight);

  bool get isPhrase => pattern.contains(' ');
}

/// Rozpoznawanie ubrania ze zdjęcia w całości na urządzeniu:
/// - kategoria: Google ML Kit Image Labeling (model lokalny, offline, bez opłat
///   za zapytanie - w zamian za mniejszą dokładność niż płatne AI w chmurze),
/// - kolor: analiza dominującego koloru pikseli, dopasowana do palety aplikacji
///   (brak AI - czysta matematyka, więc zero kosztu i błędu "halucynacji").
class PhotoAnalysisService {
  // Próg celowo niższy niż wynikowa pewność, której wymagamy od siebie:
  // konkretne etykiety ("Skirt", "Blouse") wypadają w tym modelu SŁABIEJ niż
  // ogólne ("Clothing", "Outerwear"), więc przy wysokim progu do punktacji
  // docierały głównie te ogólne, bezużyteczne. Zbieramy więcej materiału,
  // a o tym, czy w ogóle podpowiadać, decyduje już nasza punktacja niżej.
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.45),
  );

  /// Etykieta konkretna - naprawdę mówi, co to za ubranie.
  static const double _strong = 1.0;

  /// Etykieta-parasol. ML Kit zwraca "Outerwear" czy "Fashion accessory"
  /// przy ogromnej części zdjęć ubrań - także przy zwykłej bluzce - więc
  /// sama z siebie nie może przesądzić kategorii, najwyżej rozstrzygnąć remis.
  static const double _weak = 0.15;

  /// Minimalny wynik zwycięskiej kategorii, żeby cokolwiek podpowiadać.
  static const double _minScore = 0.35;

  /// O ile zwycięzca musi wyprzedzać drugą kategorię (1.3 = o 30%).
  static const double _minLead = 1.3;

  static final RegExp _wordSplit = RegExp(r'[^a-z0-9]+');

  static const List<_LabelRule> _rules = [
    // --- FRAZY (sprawdzane pierwsze, mają pierwszeństwo) ---
    // "Dress shirt" to koszula, a nie sukienka - bez tego wyjątku słowo
    // "dress" przeciągało koszule do kategorii Sukienka.
    _LabelRule('dress shirt', ClothingCategory.top, _strong),
    _LabelRule('tank top', ClothingCategory.top, _strong),
    _LabelRule('crop top', ClothingCategory.top, _strong),
    _LabelRule('high heels', ClothingCategory.shoes, _strong),
    _LabelRule('bow tie', ClothingCategory.accessory, _strong),
    // Parasol, nie konkretny dodatek - stąd niska waga.
    _LabelRule('fashion accessory', ClothingCategory.accessory, _weak),

    // --- SUKIENKI ---
    _LabelRule('dress', ClothingCategory.dress, _strong),
    _LabelRule('gown', ClothingCategory.dress, _strong),
    _LabelRule('sundress', ClothingCategory.dress, _strong),

    // --- GÓRA ---
    _LabelRule('shirt', ClothingCategory.top, _strong),
    _LabelRule('tshirt', ClothingCategory.top, _strong),
    _LabelRule('blouse', ClothingCategory.top, _strong),
    _LabelRule('sweater', ClothingCategory.top, _strong),
    _LabelRule('hoodie', ClothingCategory.top, _strong),
    _LabelRule('sweatshirt', ClothingCategory.top, _strong),
    _LabelRule('jersey', ClothingCategory.top, _strong),
    _LabelRule('polo', ClothingCategory.top, _strong),
    _LabelRule('camisole', ClothingCategory.top, _strong),
    _LabelRule('undershirt', ClothingCategory.top, _strong),
    _LabelRule('turtleneck', ClothingCategory.top, _strong),
    _LabelRule('top', ClothingCategory.top, _strong),

    // --- DÓŁ ---
    _LabelRule('jeans', ClothingCategory.bottom, _strong),
    _LabelRule('trousers', ClothingCategory.bottom, _strong),
    _LabelRule('pants', ClothingCategory.bottom, _strong),
    _LabelRule('shorts', ClothingCategory.bottom, _strong),
    _LabelRule('skirt', ClothingCategory.bottom, _strong),
    _LabelRule('miniskirt', ClothingCategory.bottom, _strong),
    _LabelRule('leggings', ClothingCategory.bottom, _strong),
    _LabelRule('sweatpants', ClothingCategory.bottom, _strong),
    // Denim to tkanina, nie fason - równie dobrze kurtka jeansowa.
    _LabelRule('denim', ClothingCategory.bottom, _weak),

    // --- OKRYCIA ---
    _LabelRule('jacket', ClothingCategory.outerwear, _strong),
    _LabelRule('coat', ClothingCategory.outerwear, _strong),
    _LabelRule('overcoat', ClothingCategory.outerwear, _strong),
    _LabelRule('raincoat', ClothingCategory.outerwear, _strong),
    _LabelRule('blazer', ClothingCategory.outerwear, _strong),
    _LabelRule('parka', ClothingCategory.outerwear, _strong),
    _LabelRule('cardigan', ClothingCategory.outerwear, _strong),
    _LabelRule('windbreaker', ClothingCategory.outerwear, _strong),
    _LabelRule('waistcoat', ClothingCategory.outerwear, _strong),
    _LabelRule('poncho', ClothingCategory.outerwear, _strong),
    // Parasol ML Kit - pojawia się nawet przy zwykłych bluzkach.
    _LabelRule('outerwear', ClothingCategory.outerwear, _weak),

    // --- BUTY ---
    _LabelRule('shoe', ClothingCategory.shoes, _strong),
    _LabelRule('shoes', ClothingCategory.shoes, _strong),
    _LabelRule('footwear', ClothingCategory.shoes, _strong),
    _LabelRule('boot', ClothingCategory.shoes, _strong),
    _LabelRule('boots', ClothingCategory.shoes, _strong),
    _LabelRule('sneaker', ClothingCategory.shoes, _strong),
    _LabelRule('sneakers', ClothingCategory.shoes, _strong),
    _LabelRule('sandal', ClothingCategory.shoes, _strong),
    _LabelRule('sandals', ClothingCategory.shoes, _strong),
    _LabelRule('heel', ClothingCategory.shoes, _strong),
    _LabelRule('heels', ClothingCategory.shoes, _strong),
    _LabelRule('loafer', ClothingCategory.shoes, _strong),
    _LabelRule('loafers', ClothingCategory.shoes, _strong),
    _LabelRule('slipper', ClothingCategory.shoes, _strong),
    _LabelRule('slippers', ClothingCategory.shoes, _strong),

    // --- DODATKI ---
    _LabelRule('bag', ClothingCategory.accessory, _strong),
    _LabelRule('handbag', ClothingCategory.accessory, _strong),
    _LabelRule('purse', ClothingCategory.accessory, _strong),
    _LabelRule('backpack', ClothingCategory.accessory, _strong),
    _LabelRule('wallet', ClothingCategory.accessory, _strong),
    _LabelRule('hat', ClothingCategory.accessory, _strong),
    _LabelRule('cap', ClothingCategory.accessory, _strong),
    _LabelRule('beanie', ClothingCategory.accessory, _strong),
    _LabelRule('scarf', ClothingCategory.accessory, _strong),
    _LabelRule('belt', ClothingCategory.accessory, _strong),
    _LabelRule('jewelry', ClothingCategory.accessory, _strong),
    _LabelRule('jewellery', ClothingCategory.accessory, _strong),
    _LabelRule('necklace', ClothingCategory.accessory, _strong),
    _LabelRule('bracelet', ClothingCategory.accessory, _strong),
    _LabelRule('earring', ClothingCategory.accessory, _strong),
    _LabelRule('earrings', ClothingCategory.accessory, _strong),
    _LabelRule('watch', ClothingCategory.accessory, _strong),
    _LabelRule('sunglasses', ClothingCategory.accessory, _strong),
    _LabelRule('glasses', ClothingCategory.accessory, _strong),
    _LabelRule('glove', ClothingCategory.accessory, _strong),
    _LabelRule('gloves', ClothingCategory.accessory, _strong),
    _LabelRule('sock', ClothingCategory.accessory, _strong),
    _LabelRule('socks', ClothingCategory.accessory, _strong),
    _LabelRule('necktie', ClothingCategory.accessory, _strong),
    _LabelRule('tie', ClothingCategory.accessory, _strong),
    _LabelRule('umbrella', ClothingCategory.accessory, _strong),
    // Parasol ML Kit - pojawia się przy najróżniejszych ubraniach.
    _LabelRule('accessory', ClothingCategory.accessory, _weak),
  ];

  Future<PhotoAnalysisResult> analyze(File photo) async {
    ClothingCategory? category;
    try {
      category = await _detectCategory(photo);
    } catch (_) {
      // Rozpoznawanie nie powiodło się (np. brak modelu na urządzeniu) -
      // po prostu nie sugerujemy kategorii, formularz zostaje jak był.
    }

    String? colorHex;
    try {
      colorHex = await _detectColorHex(photo);
    } catch (_) {
      // jw. - w razie błędu po prostu nie sugerujemy koloru.
    }

    return PhotoAnalysisResult(category: category, colorHex: colorHex);
  }

  /// Ile punktów daje pojedyncza etykieta poszczególnym kategoriom.
  static Map<ClothingCategory, double> _labelWeights(String label) {
    final text = label.toLowerCase().trim();
    final result = <ClothingCategory, double>{};

    // 1. Najpierw frazy. Jeśli któraś pasuje, tylko ona liczy się dla tej
    //    etykiety - dzięki temu "dress shirt" to koszula, a nie remis
    //    między koszulą a sukienką.
    for (final rule in _rules.where((r) => r.isPhrase)) {
      if (text.contains(rule.pattern)) {
        result[rule.category] = (result[rule.category] ?? 0) + rule.weight;
      }
    }
    if (result.isNotEmpty) return result;

    // 2. Potem pojedyncze słowa - porównywane jako CAŁE słowa, nie fragmenty.
    //    Wcześniej wystarczyło, że etykieta zawierała ciąg znaków, więc
    //    "laptop" trafiał do kategorii Góra (bo zawiera "top"), a "wheel"
    //    do Butów (bo zawiera "heel").
    final words = text.split(_wordSplit).where((w) => w.isNotEmpty).toSet();
    for (final rule in _rules.where((r) => !r.isPhrase)) {
      if (words.contains(rule.pattern)) {
        result[rule.category] = (result[rule.category] ?? 0) + rule.weight;
      }
    }
    return result;
  }

  /// Kategoria wybierana GŁOSOWANIEM wszystkich etykiet naraz (każda waży
  /// tyle, ile wynosi jej pewność), a nie - jak wcześniej - pierwszą lepszą
  /// etykietą, która do czegokolwiek pasowała. Jeśli żadna kategoria nie
  /// wygrywa wyraźnie, świadomie NIE podpowiadamy nic: pusta kategoria do
  /// uzupełnienia jest mniej myląca niż pewnie wyglądająca, ale błędna.
  Future<ClothingCategory?> _detectCategory(File photo) async {
    final inputImage = InputImage.fromFilePath(photo.path);
    final labels = await _labeler.processImage(inputImage);

    final scores = <ClothingCategory, double>{};
    for (final label in labels) {
      _labelWeights(label.label).forEach((category, weight) {
        scores[category] = (scores[category] ?? 0) + weight * label.confidence;
      });
    }
    if (scores.isEmpty) return null;

    final ranked = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final best = ranked.first;
    final runnerUp = ranked.length > 1 ? ranked[1].value : 0.0;

    if (best.value < _minScore) return null;
    if (runnerUp > 0 && best.value < runnerUp * _minLead) return null;
    return best.key;
  }

  Future<String?> _detectColorHex(File photo) async {
    final bytes = await photo.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 60);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    final pixels = byteData.buffer.asUint8List();
    final width = image.width;
    final height = image.height;

    // Próbkujemy tylko środkową część kadru - w typowym zdjęciu ubrania na
    // wieszaku (nie na czystym, białym tle produktowym, tylko np. na
    // drzwiach szafy) to właśnie środek niemal zawsze pokazuje samo
    // ubranie, a brzegi kadru częściej łapią widoczne tło. Węższy margines
    // w pionie niż w poziomie, bo ubranie zwykle zajmuje większość
    // wysokości zdjęcia (od wieszaka do dołu), ale rzadziej całą szerokość.
    final marginX = (width * 0.2).round();
    final marginY = (height * 0.12).round();

    // Każdy próbkowany piksel "głosuje" na najbliższy kolor z palety appki,
    // zamiast (jak wcześniej) uśredniać surowe RGB wszystkich pikseli razem.
    // Uśrednianie miesza kolor ubrania z widocznym tłem/dodatkami w jedną,
    // rozmytą barwę, która często nie przypomina żadnego z nich (np. szary
    // z niebieskiej sukienki na kolorowym tle) - głosowanie jest odporne na
    // tło w kadrze, dopóki samo ubranie zajmuje większą część próbkowanej,
    // środkowej strefy niż to, co jest za nim.
    final votes = <String, int>{};
    for (int y = marginY; y < height - marginY; y++) {
      for (int x = marginX; x < width - marginX; x++) {
        final i = (y * width + x) * 4;
        final a = pixels[i + 3];
        if (a < 128) continue; // pomijamy przezroczyste piksele
        final r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
        // nadal pomijamy prawie-białe piksele, gdyby akurat trafiło się
        // czyste, jasne tło nawet w tej środkowej strefie
        if (r > 235 && g > 235 && b > 235) continue;
        final hex = _nearestPaletteColor(r.toDouble(), g.toDouble(), b.toDouble());
        votes[hex] = (votes[hex] ?? 0) + 1;
      }
    }
    if (votes.isEmpty) return null;

    return votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _nearestPaletteColor(double r, double g, double b) {
    String bestHex = kClothingColors.first.hex;
    double bestDistance = double.infinity;
    for (final c in kClothingColors) {
      if (c.hex == 'multi') continue; // 'multi' nie jest realnym kolorem do dopasowania
      final color = hexToColor(c.hex);
      final dr = (color.r * 255.0).round() - r;
      final dg = (color.g * 255.0).round() - g;
      final db = (color.b * 255.0).round() - b;
      final distance = dr * dr + dg * dg + db * db;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestHex = c.hex;
      }
    }
    return bestHex;
  }

  void dispose() {
    _labeler.close();
  }
}
