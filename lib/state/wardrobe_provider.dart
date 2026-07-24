import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/storage_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final AuthService _auth = AuthService();
  final CloudSyncService _cloud = CloudSyncService();
  final _uuid = const Uuid();

  List<ClothingItem> _items = [];
  List<Outfit> _outfits = [];
  bool _loading = true;

  User? _user;
  bool _syncing = false;
  String? _syncError;
  DateTime? _lastSyncedAt;
  StreamSubscription<User?>? _authSub;

  List<ClothingItem> get items => List.unmodifiable(_items);
  List<Outfit> get outfits => List.unmodifiable(_outfits);
  bool get isLoading => _loading;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isSyncing => _syncing;
  String? get syncError => _syncError;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  Future<void> load() async {
    _items = await _storage.loadItems();
    _outfits = await _storage.loadOutfits();
    _loading = false;
    notifyListeners();

    _authSub = _auth.authStateChanges.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    notifyListeners();
    if (user != null) {
      await _syncAfterSignIn(user.uid);
    }
  }

  Future<void> signInWithGoogle() async {
    _syncError = null;
    try {
      await _auth.signInWithGoogle();
      // reszta (pobranie/wgranie danych) dzieje się w _onAuthChanged
    } catch (e) {
      _syncError = 'Nie udało się zalogować: $e';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _lastSyncedAt = null;
    notifyListeners();
  }

  /// Po zalogowaniu: jeśli w chmurze są już jakieś dane - stają się źródłem
  /// prawdy (pobieramy je, nadpisując lokalne). Jeśli chmura jest pusta
  /// (pierwsze logowanie), wysyłamy to, co mamy lokalnie.
  Future<void> _syncAfterSignIn(String uid) async {
    _syncing = true;
    _syncError = null;
    notifyListeners();
    try {
      final cloudData = await _cloud.pullFromCloud(uid);
      if (cloudData != null && cloudData.items.isNotEmpty) {
        _items = cloudData.items;
        _outfits = cloudData.outfits;
        await _storage.saveAll(_items, _outfits);
      } else {
        _items = await _cloud.pushToCloud(uid, _items, _outfits);
        await _storage.saveAll(_items, _outfits);
      }
      _lastSyncedAt = DateTime.now();
    } catch (e) {
      _syncError = 'Synchronizacja nie powiodła się: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// Ręczna synchronizacja na żądanie (np. przycisk "Synchronizuj teraz").
  Future<void> syncNow() async {
    if (_user == null) return;
    _syncing = true;
    _syncError = null;
    notifyListeners();
    try {
      _items = await _cloud.pushToCloud(_user!.uid, _items, _outfits);
      await _storage.saveAll(_items, _outfits);
      _lastSyncedAt = DateTime.now();
    } catch (e) {
      _syncError = 'Synchronizacja nie powiodła się: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> _persistAndSync() async {
    await _storage.saveAll(_items, _outfits);
    if (_user != null) {
      // Synchronizacja w tle - nie blokuje UI i nie przerywa działania
      // przy braku internetu (błąd jest po prostu zapisywany do wglądu).
      unawaited(_backgroundSync());
    }
  }

  Future<void> _backgroundSync() async {
    if (_user == null) return;
    try {
      _items = await _cloud.pushToCloud(_user!.uid, _items, _outfits);
      _lastSyncedAt = DateTime.now();
      _syncError = null;
    } catch (e) {
      _syncError = 'Brak połączenia - zmiany zapisane tylko lokalnie';
    }
    notifyListeners();
  }

  ClothingItem? findItem(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<void> addItem({
    required String name,
    required ClothingCategory category,
    required String subcategory,
    required String colorHex,
    required double price,
    required File photoFile,
  }) async {
    final id = _uuid.v4();
    final photoPath = await _storage.persistPhoto(photoFile, id);
    final item = ClothingItem(
      id: id,
      name: name,
      category: category,
      subcategory: subcategory,
      colorHex: colorHex,
      price: price,
      photoPath: photoPath,
    );
    _items.add(item);
    await _persistAndSync();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final item = findItem(id);
    _items.removeWhere((i) => i.id == id);
    for (final outfit in _outfits) {
      outfit.itemIds.removeWhere((itemId) => itemId == id);
    }
    if (item != null) {
      await _storage.deletePhoto(item.photoPath);
      if (_user != null) {
        unawaited(_cloud.deletePhoto(_user!.uid, item.id));
      }
    }
    await _persistAndSync();
    notifyListeners();
  }

  Future<void> wearItem(String id) async {
    final item = findItem(id);
    if (item == null) return;
    item.wears += 1;
    await _persistAndSync();
    notifyListeners();
  }

  Future<void> unwearItem(String id) async {
    final item = findItem(id);
    if (item == null || item.wears == 0) return;
    item.wears -= 1;
    await _persistAndSync();
    notifyListeners();
  }

  Future<void> addOutfit(String name, List<String> itemIds) async {
    final outfit = Outfit(id: _uuid.v4(), name: name, itemIds: itemIds);
    _outfits.add(outfit);
    await _persistAndSync();
    notifyListeners();
  }

  Future<void> deleteOutfit(String id) async {
    _outfits.removeWhere((o) => o.id == id);
    await _persistAndSync();
    notifyListeners();
  }
}
