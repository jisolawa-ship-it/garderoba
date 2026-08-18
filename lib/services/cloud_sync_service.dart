import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

/// Obsługuje synchronizację z Firebase - RÓB PER REKORD (jedno ubranie /
/// jedna stylizacja = jeden dokument), a nie jeden wielki dokument na całą
/// szafę. To kluczowe dla bezpiecznej, dwukierunkowej synchronizacji:
/// appka wysyła/odbiera pojedyncze zmiany, więc nic nigdy nie nadpisuje
/// całości na raz.
class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _itemsCol(String uid) =>
      _userDoc(uid).collection('items');

  CollectionReference<Map<String, dynamic>> _outfitsCol(String uid) =>
      _userDoc(uid).collection('outfits');

  CollectionReference<Map<String, dynamic>> _calendarCol(String uid) =>
      _userDoc(uid).collection('calendarEntries');

  // ---------------------------------------------------------------------
  // Ubrania
  // ---------------------------------------------------------------------

  /// Wysyła jedno ubranie do chmury. Jeśli ma tylko lokalne zdjęcie i nie
  /// ma jeszcze adresu w Storage, najpierw je wgrywa. Zwraca zaktualizowany
  /// obiekt (z uzupełnionym `photoUrl`, jeśli trzeba było wgrać zdjęcie).
  Future<ClothingItem> pushItem(String uid, ClothingItem item) async {
    if (item.photoUrl == null &&
        item.photoPath != null &&
        File(item.photoPath!).existsSync()) {
      item.photoUrl = await _uploadPhoto(uid, item.id, File(item.photoPath!));
    }
    await _itemsCol(uid).doc(item.id).set(item.toJson());
    return item;
  }

  Future<void> deleteItemRemote(String uid, String itemId) async {
    await _itemsCol(uid).doc(itemId).delete();
    await _deletePhoto(uid, itemId);
  }

  Future<List<ClothingItem>> fetchAllItems(String uid) async {
    final snap = await _itemsCol(uid).get();
    return snap.docs.map((d) => ClothingItem.fromJson(d.data())).toList();
  }

  Future<String> _uploadPhoto(String uid, String itemId, File file) async {
    final ref = _storage.ref('users/$uid/photos/$itemId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _deletePhoto(String uid, String itemId) async {
    try {
      await _storage.ref('users/$uid/photos/$itemId.jpg').delete();
    } catch (_) {
      // zdjęcie mogło już nie istnieć w chmurze - nic się nie dzieje
    }
  }

  // ---------------------------------------------------------------------
  // Stylizacje
  // ---------------------------------------------------------------------

  Future<void> pushOutfit(String uid, Outfit outfit) async {
    await _outfitsCol(uid).doc(outfit.id).set(outfit.toJson());
  }

  Future<void> deleteOutfitRemote(String uid, String outfitId) async {
    await _outfitsCol(uid).doc(outfitId).delete();
  }

  Future<List<Outfit>> fetchAllOutfits(String uid) async {
    final snap = await _outfitsCol(uid).get();
    return snap.docs.map((d) => Outfit.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Kalendarz
  // ---------------------------------------------------------------------

  Future<void> pushCalendarEntry(String uid, CalendarEntry entry) async {
    await _calendarCol(uid).doc(entry.id).set(entry.toJson());
  }

  Future<void> deleteCalendarEntryRemote(String uid, String entryId) async {
    await _calendarCol(uid).doc(entryId).delete();
  }

  Future<List<CalendarEntry>> fetchAllCalendarEntries(String uid) async {
    final snap = await _calendarCol(uid).get();
    return snap.docs.map((d) => CalendarEntry.fromJson(d.data())).toList();
  }

  // ---------------------------------------------------------------------
  // Migracja ze starego formatu (sprzed wprowadzenia osobnych kolekcji) -
  // dane trzymane jako pola `items`/`outfits` bezpośrednio w users/{uid}.
  // ---------------------------------------------------------------------

  Future<({List<ClothingItem> items, List<Outfit> outfits})?> fetchLegacyDocData(
    String uid,
  ) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    if (!data.containsKey('items') && !data.containsKey('outfits')) return null;
    final items = (data['items'] as List? ?? [])
        .map((e) => ClothingItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final outfits = (data['outfits'] as List? ?? [])
        .map((e) => Outfit.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (items: items, outfits: outfits);
  }

  Future<void> clearLegacyDocFields(String uid) async {
    await _userDoc(uid).update({
      'items': FieldValue.delete(),
      'outfits': FieldValue.delete(),
      'updatedAt': FieldValue.delete(),
    });
  }

  // ---------------------------------------------------------------------
  // Konto
  // ---------------------------------------------------------------------

  /// Odczytuje flagę konta premium (ustawianą na razie ręcznie w konsoli
  /// Firebase - pole `isPremium: true` w dokumencie users/{uid}).
  Future<bool> fetchIsPremium(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return false;
    return (snap.data()!['isPremium'] as bool?) ?? false;
  }
}
