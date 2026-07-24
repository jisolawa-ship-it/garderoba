import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

/// Obsługuje zapisywanie i pobieranie całej szafy z Firebase dla
/// zalogowanego użytkownika. Struktura: jeden dokument na użytkownika
/// (users/{uid}) zawierający listy `items` i `outfits` jako JSON — prosto
/// i wystarczająco dla jednoosobowej szafy na kilku urządzeniach.
class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Wysyła lokalny stan (ubrania + stylizacje) do chmury. Jeśli dany
  /// przedmiot ma tylko lokalne zdjęcie (photoPath) i nie ma jeszcze
  /// photoUrl, najpierw wgrywa zdjęcie do Firebase Storage.
  Future<List<ClothingItem>> pushToCloud(
    String uid,
    List<ClothingItem> items,
    List<Outfit> outfits,
  ) async {
    final updatedItems = <ClothingItem>[];
    for (final item in items) {
      if (item.photoUrl == null &&
          item.photoPath != null &&
          File(item.photoPath!).existsSync()) {
        final url = await _uploadPhoto(uid, item.id, File(item.photoPath!));
        item.photoUrl = url;
      }
      updatedItems.add(item);
    }

    await _userDoc(uid).set({
      'items': updatedItems.map((e) => e.toJson()).toList(),
      'outfits': outfits.map((e) => e.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return updatedItems;
  }

  Future<String> _uploadPhoto(String uid, String itemId, File file) async {
    final ref = _storage.ref('users/$uid/photos/$itemId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deletePhoto(String uid, String itemId) async {
    try {
      await _storage.ref('users/$uid/photos/$itemId.jpg').delete();
    } catch (_) {
      // zdjęcie mogło już nie istnieć w chmurze - nic się nie dzieje
    }
  }

  /// Pobiera dane z chmury. Zwraca null, jeśli użytkownik nie ma jeszcze
  /// żadnych zapisanych danych (pierwsze logowanie na nowym koncie).
  Future<({List<ClothingItem> items, List<Outfit> outfits})?> pullFromCloud(
    String uid,
  ) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    final items = (data['items'] as List? ?? [])
        .map((e) => ClothingItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final outfits = (data['outfits'] as List? ?? [])
        .map((e) => Outfit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (items: items, outfits: outfits);
  }
}
