import 'dart:io';
import 'dart:math' as math;
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
    // Najpierw próbujemy przyciąć kadr do samego ubrania. Zdjęcia robione w
    // domu to zwykle ubranie rozłożone na podłodze albo dywanie - reszta
    // kadru to tło, które model widzi razem z ubraniem i które psuje wynik
    // (podpowiada mu "dywan", "drewno", "wnętrze" zamiast typu ubrania).
    // Jeśli przycięcie się nie uda albo wyjdzie podejrzane, po cichu
    // pracujemy na oryginale - dokładnie tak jak wcześniej.
    File? cropped;
    try {
      cropped = await _cropToGarment(photo);
    } catch (_) {
      cropped = null;
    }
    final source = cropped ?? photo;

    try {
      ClothingCategory? category;
      try {
        category = await _detectCategory(source);
      } catch (_) {
        // Rozpoznawanie nie powiodło się (np. brak modelu na urządzeniu) -
        // po prostu nie sugerujemy kategorii, formularz zostaje jak był.
      }

      String? colorHex;
      try {
        colorHex = await _detectColorHex(source);
      } catch (_) {
        // jw. - w razie błędu po prostu nie sugerujemy koloru.
      }

      return PhotoAnalysisResult(category: category, colorHex: colorHex);
    } finally {
      // Przycięta kopia była wyłącznie na potrzeby rozpoznawania - w szafie
      // i tak zapisujemy oryginalne zdjęcie, więc kasujemy ją od razu.
      if (cropped != null) {
        try {
          await cropped.delete();
        } catch (_) {}
      }
    }
  }

  /// Szerokość, do której skalujemy zdjęcie na czas szukania ubrania w
  /// kadrze. Mniej pikseli = szybciej (w paczce potrafi być 25 zdjęć), a do
  /// znalezienia obrysu i tak nie potrzeba pełnej rozdzielczości.
  static const int _analysisWidth = 512;

  /// Wycina z kadru sam prostokąt z ubraniem i zapisuje go jako plik
  /// tymczasowy. Zwraca null, gdy nie da się tego zrobić sensownie - wtedy
  /// wolimy zostawić oryginał niż wyciąć coś przypadkowego.
  ///
  /// Zasada: tło (podłoga, dywan) dotyka brzegów kadru, ubranie leży na
  /// środku. Liczymy więc kolor brzegów i szukamy pikseli, które się od
  /// niego wyraźnie różnią.
  Future<File?> _cropToGarment(File photo) async {
    final bytes = await photo.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: _analysisWidth);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) return null;
      final px = data.buffer.asUint8List();
      final w = image.width;
      final h = image.height;
      if (w < 40 || h < 40) return null;

      // 1. Kolor tła - z ramki przy krawędziach kadru.
      final ringX = (w * 0.06).round().clamp(1, w);
      final ringY = (h * 0.06).round().clamp(1, h);
      double sr = 0, sg = 0, sb = 0;
      int n = 0;
      for (int y = 0; y < h; y++) {
        final edgeRow = y < ringY || y >= h - ringY;
        for (int x = 0; x < w; x++) {
          if (!edgeRow && x >= ringX && x < w - ringX) continue;
          final i = (y * w + x) * 4;
          if (px[i + 3] < 128) continue;
          sr += px[i];
          sg += px[i + 1];
          sb += px[i + 2];
          n++;
        }
      }
      if (n == 0) return null;
      final br = sr / n, bg = sg / n, bb = sb / n;

      // 2. Jak bardzo samo tło jest niejednolite. Mocno wzorzysty dywan
      //    znaczy, że nie odróżnimy go pewnie od ubrania - wtedy odpuszczamy.
      double varSum = 0;
      for (int y = 0; y < h; y++) {
        final edgeRow = y < ringY || y >= h - ringY;
        for (int x = 0; x < w; x++) {
          if (!edgeRow && x >= ringX && x < w - ringX) continue;
          final i = (y * w + x) * 4;
          if (px[i + 3] < 128) continue;
          final dr = px[i] - br, dg2 = px[i + 1] - bg, db = px[i + 2] - bb;
          varSum += dr * dr + dg2 * dg2 + db * db;
        }
      }
      final spread = math.sqrt(varSum / n);
      // Próg dobrany na zdjęciach z realnej szafy: podłoga z widocznymi
      // fugami czy liniami ma niejednolitość rzędu 50-90 i nadal da się na
      // niej znaleźć ubranie. Przy naprawdę wzorzystym tle i tak zadziała
      // zabezpieczenie niżej (obrys wyjdzie na cały kadr i odpuszczamy).
      if (spread > 90) return null;

      // 3. Próg "to już nie jest tło" - zależny od tego, jak spokojne jest
      //    samo tło, żeby jasna bluzka na jasnej podłodze też się wybroniła.
      final threshold = math.max(34.0, spread * 2.5);
      final thresholdSq = threshold * threshold;

      // 4. Zamiast pojedynczych pikseli patrzymy na całe wiersze i kolumny -
      //    pojedynczy odblask czy okruch na podłodze nie rozciągnie wtedy
      //    obrysu na pół kadru.
      final rowHits = List<int>.filled(h, 0);
      final colHits = List<int>.filled(w, 0);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          if (px[i + 3] < 128) continue;
          final dr = px[i] - br, dg2 = px[i + 1] - bg, db = px[i + 2] - bb;
          if (dr * dr + dg2 * dg2 + db * db > thresholdSq) {
            rowHits[y]++;
            colHits[x]++;
          }
        }
      }

      final minRow = (w * 0.04).ceil();
      final minCol = (h * 0.04).ceil();
      int top = 0, bottom = h - 1, left = 0, right = w - 1;
      while (top < h && rowHits[top] < minRow) {
        top++;
      }
      while (bottom > top && rowHits[bottom] < minRow) {
        bottom--;
      }
      while (left < w && colHits[left] < minCol) {
        left++;
      }
      while (right > left && colHits[right] < minCol) {
        right--;
      }
      if (right <= left || bottom <= top) return null;

      // 5. Odrobina zapasu, żeby nie obcinać ubrania równo przy krawędzi.
      final padX = (w * 0.04).round();
      final padY = (h * 0.04).round();
      left = (left - padX).clamp(0, w - 1);
      right = (right + padX).clamp(0, w - 1);
      top = (top - padY).clamp(0, h - 1);
      bottom = (bottom + padY).clamp(0, h - 1);

      final cw = right - left + 1;
      final ch = bottom - top + 1;

      // 6. Zdrowy rozsądek: za mały wycinek to pewnie przypadkowy detal, a
      //    prawie cały kadr znaczy, że i tak nic nie zyskujemy.
      final coverage = (cw * ch) / (w * h);
      if (coverage < 0.08 || coverage > 0.95) return null;
      if (cw < w * 0.15 || ch < h * 0.15) return null;

      // 7. Wycinamy i zapisujemy jako plik tymczasowy - ML Kit czyta z pliku.
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        image,
        ui.Rect.fromLTWH(left.toDouble(), top.toDouble(), cw.toDouble(), ch.toDouble()),
        ui.Rect.fromLTWH(0, 0, cw.toDouble(), ch.toDouble()),
        ui.Paint(),
      );
      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(cw, ch);
      picture.dispose();
      try {
        final png = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
        if (png == null) return null;
        final file = File(
          '${Directory.systemTemp.path}/szafnik_crop_${DateTime.now().microsecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(png.buffer.asUint8List(), flush: true);
        return file;
      } finally {
        croppedImage.dispose();
      }
    } finally {
      image.dispose();
    }
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
