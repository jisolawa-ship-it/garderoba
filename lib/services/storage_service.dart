import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Obsługa plików zdjęć na dysku urządzenia. Dane ubrań/stylizacji
/// (dawniej trzymane też tutaj jako JSON) przeniosły się do lokalnej
/// bazy Drift (`WardrobeLocalStore`) - ten serwis zajmuje się już
/// wyłącznie plikami.
class StorageService {
  /// Kopiuje wybrane zdjęcie do katalogu dokumentów aplikacji i zwraca
  /// docelową ścieżkę pliku, żeby przetrwało po zamknięciu galerii/kamery.
  Future<String> persistPhoto(File sourceFile, String itemId) async {
    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'wardrobe_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final destPath = p.join(photosDir.path, '$itemId$ext');
    final destFile = await sourceFile.copy(destPath);
    return destFile.path;
  }

  Future<void> deletePhoto(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // ignorujemy błędy usuwania pliku - nie blokują reszty aplikacji
    }
  }
}
