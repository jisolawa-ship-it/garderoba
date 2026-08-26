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

/// Rozpoznawanie ubrania ze zdjęcia w całości na urządzeniu:
/// - kategoria: Google ML Kit Image Labeling (model lokalny, offline, bez opłat
///   za zapytanie - w zamian za mniejszą dokładność niż płatne AI w chmurze),
/// - kolor: analiza dominującego koloru pikseli, dopasowana do palety aplikacji
///   (brak AI - czysta matematyka, więc zero kosztu i błędu "halucynacji").
class PhotoAnalysisService {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.6),
  );

  static const Map<ClothingCategory, List<String>> _categoryKeywords = {
    ClothingCategory.dress: ['dress', 'gown'],
    ClothingCategory.outerwear: [
      'jacket', 'coat', 'blazer', 'outerwear', 'parka', 'cardigan'
    ],
    ClothingCategory.shoes: [
      'shoe', 'shoes', 'footwear', 'boot', 'sneaker', 'sneakers', 'sandal', 'heel'
    ],
    ClothingCategory.accessory: [
      'bag', 'handbag', 'hat', 'cap', 'scarf', 'belt', 'jewelry', 'watch',
      'sunglasses', 'accessory', 'fashion accessory'
    ],
    ClothingCategory.bottom: [
      'jeans', 'trousers', 'pants', 'shorts', 'skirt'
    ],
    ClothingCategory.top: [
      'shirt', 't-shirt', 'blouse', 'sweater', 'hoodie', 'top', 'sweatshirt'
    ],
  };

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

  Future<ClothingCategory?> _detectCategory(File photo) async {
    final inputImage = InputImage.fromFilePath(photo.path);
    final labels = await _labeler.processImage(inputImage);
    labels.sort((a, b) => b.confidence.compareTo(a.confidence));

    for (final label in labels) {
      final text = label.label.toLowerCase();
      for (final entry in _categoryKeywords.entries) {
        if (entry.value.any((keyword) => text.contains(keyword))) {
          return entry.key;
        }
      }
    }
    return null;
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

    int rSum = 0, gSum = 0, bSum = 0, count = 0;
    for (int y = marginY; y < height - marginY; y++) {
      for (int x = marginX; x < width - marginX; x++) {
        final i = (y * width + x) * 4;
        final a = pixels[i + 3];
        if (a < 128) continue; // pomijamy przezroczyste piksele
        final r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
        // nadal pomijamy prawie-białe piksele, gdyby akurat trafiło się
        // czyste, jasne tło nawet w tej środkowej strefie
        if (r > 235 && g > 235 && b > 235) continue;
        rSum += r;
        gSum += g;
        bSum += b;
        count++;
      }
    }
    if (count == 0) return null;

    final avgR = rSum / count;
    final avgG = gSum / count;
    final avgB = bSum / count;

    return _nearestPaletteColor(avgR, avgG, avgB);
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
