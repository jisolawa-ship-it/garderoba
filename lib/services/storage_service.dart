import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class StorageService {
  static const _dataKey = 'wardrobe_data_v1';

  Future<Map<String, dynamic>> loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    if (raw == null || raw.isEmpty) {
      return {'items': [], 'outfits': []};
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {'items': [], 'outfits': []};
    }
  }

  Future<List<ClothingItem>> loadItems() async {
    final raw = await loadRaw();
    final list = (raw['items'] as List? ?? []);
    return list
        .map((e) => ClothingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Outfit>> loadOutfits() async {
    final raw = await loadRaw();
    final list = (raw['outfits'] as List? ?? []);
    return list.map((e) => Outfit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAll(List<ClothingItem> items, List<Outfit> outfits) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'items': items.map((e) => e.toJson()).toList(),
      'outfits': outfits.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_dataKey, jsonEncode(payload));
  }

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
