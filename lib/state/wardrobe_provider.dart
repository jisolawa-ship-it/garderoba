import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/wardrobe_local_store.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/storage_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final WardrobeLocalStore _local = WardrobeLocalStore();
  final StorageService _photoStorage = StorageService();
  final AuthService _auth = AuthService();
  final CloudSyncService _cloud = CloudSyncService();
  final _uuid = const Uuid();

  List<ClothingItem> _items = [];
  List<Outfit> _outfits = [];
  List<CalendarEntry> _calendarEntries = [];
  bool _loading = true;

  User? _user;
  bool _syncing = false;
  String? _syncError;
  DateTime? _lastSyncedAt;
  bool _isPremium = false;
  StreamSubscription<User?>? _authSub;

  List<ClothingItem> get items => List.unmodifiable(_items);
  List<Outfit> get outfits => List.unmodifiable(_outfits);
  List<CalendarEntry> get calendarEntries => List.unmodifiable(_calendarEntries);
  bool get isLoading => _loading;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isSyncing => _syncing;
  String? get syncError => _syncError;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get isPremium => _isPremium;

  /// Limit ubrań w darmowej wersji - kolejne dodanie jest blokowane po
  /// osiągnięciu tej liczby, chyba że konto ma isPremium == true.
  static const int freeItemLimit = 50;

  bool get hasReachedFreeLimit => !_isPremium && _items.length >= freeItemLimit;

  Future<void> load() async {
    // Dane lokalne (Drift) wczytują się od razu, bez czekania na sieć -
    // appka jest w pełni użyteczna offline od pierwszej klatki.
    await _local.migrateFromLegacyIfNeeded();
    _items = await _local.loadItems();
    _outfits = await _local.loadOutfits();
    _calendarEntries = await _local.loadCalendarEntries();
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
      unawaited(_reconcileWithCloud(user.uid));
    }
  }

  Future<void> signInWithGoogle() async {
    _syncError = null;
    try {
      await _auth.signInWithGoogle();
      // reszta (synchronizacja) dzieje się w _onAuthChanged
    } catch (e) {
      _syncError = 'Nie udało się zalogować: $e';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _lastSyncedAt = null;
    _isPremium = false;
    notifyListeners();
  }

  /// Ręczna synchronizacja na żądanie (np. przycisk "Synchronizuj teraz").
  Future<void> syncNow() async {
    if (_user == null) return;
    await _reconcileWithCloud(_user!.uid);
  }

  /// Serce bezpiecznej synchronizacji: NAJPIERW wysyła wszystkie lokalne,
  /// niewysłane jeszcze zmiany (żeby nic offline nigdy nie zginęło), a
  /// DOPIERO POTEM ściąga to, co nowsze z chmury - i to tylko dla rekordów,
  /// które nie mają lokalnie oczekujących zmian. Dzięki temu nic lokalnego
  /// nigdy nie zostaje nadpisane danymi z chmury bez wysłania najpierw.
  Future<void> _reconcileWithCloud(String uid) async {
    if (_syncing) return; // synchronizacja już trwa - kolejna okazja dogoni zmiany
    _syncing = true;
    _syncError = null;
    notifyListeners();

    try {
      // 1. Wypchnij lokalne zmiany (w tym usunięcia) do chmury.
      for (final rec in await _local.dirtyItems()) {
        if (rec.wasDeleted) {
          await _cloud.deleteItemRemote(uid, rec.value.id);
          await _local.confirmItemPushed(rec.value.id, wasDeleted: true);
        } else {
          final pushed = await _cloud.pushItem(uid, rec.value);
          await _local.upsertItem(pushed, dirty: false);
        }
      }
      for (final rec in await _local.dirtyOutfits()) {
        if (rec.wasDeleted) {
          await _cloud.deleteOutfitRemote(uid, rec.value.id);
          await _local.confirmOutfitPushed(rec.value.id, wasDeleted: true);
        } else {
          await _cloud.pushOutfit(uid, rec.value);
          await _local.upsertOutfit(rec.value, dirty: false);
        }
      }
      for (final rec in await _local.dirtyCalendarEntries()) {
        if (rec.wasDeleted) {
          await _cloud.deleteCalendarEntryRemote(uid, rec.value.id);
          await _local.confirmCalendarEntryPushed(rec.value.id, wasDeleted: true);
        } else {
          await _cloud.pushCalendarEntry(uid, rec.value);
          await _local.upsertCalendarEntry(rec.value, dirty: false);
        }
      }

      // 2. Ściągnij stan z chmury i dogadaj z lokalną bazą.
      final remoteItems = await _cloud.fetchAllItems(uid);
      final remoteOutfits = await _cloud.fetchAllOutfits(uid);
      final remoteCalendarEntries = await _cloud.fetchAllCalendarEntries(uid);

      // Jednorazowa migracja danych sprzed wprowadzenia osobnych kolekcji
      // (stare dane trzymane jako pola items/outfits w głównym dokumencie).
      final legacy = await _cloud.fetchLegacyDocData(uid);
      if (legacy != null) {
        final existingItemIds = remoteItems.map((i) => i.id).toSet();
        for (final item in legacy.items) {
          if (!existingItemIds.contains(item.id)) {
            remoteItems.add(await _cloud.pushItem(uid, item));
          }
        }
        final existingOutfitIds = remoteOutfits.map((o) => o.id).toSet();
        for (final outfit in legacy.outfits) {
          if (!existingOutfitIds.contains(outfit.id)) {
            await _cloud.pushOutfit(uid, outfit);
            remoteOutfits.add(outfit);
          }
        }
        await _cloud.clearLegacyDocFields(uid);
      }

      final remoteItemIds = remoteItems.map((i) => i.id).toSet();
      final remoteOutfitIds = remoteOutfits.map((o) => o.id).toSet();
      final remoteCalendarEntryIds = remoteCalendarEntries.map((e) => e.id).toSet();

      // Świeży odczyt "co nadal ma niewysłane zmiany" - na wypadek gdyby
      // coś zostało zmienione lokalnie w trakcie trwania synchronizacji.
      final stillDirtyItemIds =
          (await _local.dirtyItems()).map((r) => r.value.id).toSet();
      final stillDirtyOutfitIds =
          (await _local.dirtyOutfits()).map((r) => r.value.id).toSet();
      final stillDirtyCalendarEntryIds =
          (await _local.dirtyCalendarEntries()).map((r) => r.value.id).toSet();

      for (final remoteItem in remoteItems) {
        if (stillDirtyItemIds.contains(remoteItem.id)) continue;
        await _local.applyRemoteItem(remoteItem);
      }
      for (final remoteOutfit in remoteOutfits) {
        if (stillDirtyOutfitIds.contains(remoteOutfit.id)) continue;
        await _local.applyRemoteOutfit(remoteOutfit);
      }
      for (final remoteEntry in remoteCalendarEntries) {
        if (stillDirtyCalendarEntryIds.contains(remoteEntry.id)) continue;
        await _local.applyRemoteCalendarEntry(remoteEntry);
      }

      // Rekordy zsynchronizowane wcześniej, których już nie ma w chmurze -
      // zostały usunięte na innym urządzeniu, więc dogania to i tutaj.
      //
      // ZABEZPIECZENIE: jeśli chmura zwróciła podejrzanie mało danych (np.
      // zero), a lokalnie mamy sporo już zsynchronizowanych rekordów, to
      // prawdopodobnie ściąganie danych nie powiodło się w pełni, a nie że
      // wszystko zostało naprawdę usunięte gdzie indziej. W takim wypadku
      // appka NIE kasuje niczego lokalnie - bezpieczniej zostawić dane i
      // spróbować ponownie przy następnej synchronizacji, niż zgadywać.
      final localNonDirtyItemIds = await _local.nonDirtyItemIds();
      final itemFetchLooksSuspicious =
          remoteItems.isEmpty && localNonDirtyItemIds.length >= 3;
      if (!itemFetchLooksSuspicious) {
        for (final id in localNonDirtyItemIds) {
          if (!remoteItemIds.contains(id) && !stillDirtyItemIds.contains(id)) {
            await _local.hardDeleteItemIfPresent(id);
          }
        }
      }
      final localNonDirtyOutfitIds = await _local.nonDirtyOutfitIds();
      final outfitFetchLooksSuspicious =
          remoteOutfits.isEmpty && localNonDirtyOutfitIds.length >= 3;
      if (!outfitFetchLooksSuspicious) {
        for (final id in localNonDirtyOutfitIds) {
          if (!remoteOutfitIds.contains(id) && !stillDirtyOutfitIds.contains(id)) {
            await _local.hardDeleteOutfitIfPresent(id);
          }
        }
      }
      final localNonDirtyCalendarEntryIds = await _local.nonDirtyCalendarEntryIds();
      final calendarFetchLooksSuspicious =
          remoteCalendarEntries.isEmpty && localNonDirtyCalendarEntryIds.length >= 3;
      if (!calendarFetchLooksSuspicious) {
        for (final id in localNonDirtyCalendarEntryIds) {
          if (!remoteCalendarEntryIds.contains(id) && !stillDirtyCalendarEntryIds.contains(id)) {
            await _local.hardDeleteCalendarEntryIfPresent(id);
          }
        }
      }

      // 3. Odśwież to, co widzi UI.
      _items = await _local.loadItems();
      _outfits = await _local.loadOutfits();
      _calendarEntries = await _local.loadCalendarEntries();
      _isPremium = await _cloud.fetchIsPremium(uid);
      _lastSyncedAt = DateTime.now();
      _syncError = null;
    } catch (e) {
      _syncError = 'Synchronizacja nie powiodła się: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  void _triggerBackgroundSync() {
    if (_user != null) {
      unawaited(_reconcileWithCloud(_user!.uid));
    }
  }

  ClothingItem? findItem(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// Zwraca `true`, jeśli ubranie zostało dodane, `false` jeśli zablokowane
  /// przez limit darmowej wersji ([hasReachedFreeLimit]) - w takim
  /// przypadku appka nic nie zapisuje (żadnego "częściowego" dodania).
  Future<bool> addItem({
    String name = '',
    required ClothingCategory category,
    required String subcategory,
    required String colorHex,
    double? price,
    required File photoFile,
    List<String> seasons = const [],
    String? ownershipAge,
    int? initialWears,
  }) async {
    if (hasReachedFreeLimit) return false;

    final id = _uuid.v4();
    final photoPath = await _photoStorage.persistPhoto(photoFile, id);
    final now = DateTime.now();
    final item = ClothingItem(
      id: id,
      name: name,
      category: category,
      subcategory: subcategory,
      colorHex: colorHex,
      price: price,
      photoPath: photoPath,
      seasons: seasons,
      ownershipAge: ownershipAge,
      // "Ile razy już noszone" - deklaracja przy dodawaniu ubrania, które
      // nie jest nowe. Appka nie zna prawdziwej historii sprzed dodania do
      // szafy, więc pozwala to zadeklarować z grubsza, żeby koszt za
      // noszenie nie startował od zera dla starych, sprawdzonych ubrań.
      wears: initialWears ?? 0,
      createdAt: now,
      updatedAt: now,
    );
    await _local.upsertItem(item, dirty: true);
    _items = await _local.loadItems();
    notifyListeners();
    _triggerBackgroundSync();
    return true;
  }

  /// Aktualizuje istniejące ubranie. Jeśli podano [newPhotoFile], stare
  /// lokalne zdjęcie jest zastępowane nowym, a adres w chmurze zerowany,
  /// żeby przy najbliższej synchronizacji appka wysłała nowe zdjęcie zamiast
  /// zachować nieaktualne (adres w Firebase Storage jest stały dla danego
  /// ubrania, więc nowe zdjęcie po prostu je nadpisze).
  Future<void> updateItem({
    required String id,
    String name = '',
    required ClothingCategory category,
    required String subcategory,
    required String colorHex,
    double? price,
    File? newPhotoFile,
    List<String> seasons = const [],
    String? ownershipAge,
    int? wears,
  }) async {
    final item = findItem(id);
    if (item == null) return;

    if (newPhotoFile != null) {
      await _photoStorage.deletePhoto(item.photoPath);
      item.photoPath = await _photoStorage.persistPhoto(newPhotoFile, id);
      item.photoUrl = null;
    }

    item.name = name;
    item.category = category;
    item.subcategory = subcategory;
    item.colorHex = colorHex;
    item.price = price;
    item.seasons = seasons;
    item.ownershipAge = ownershipAge;
    if (wears != null) item.wears = wears;
    item.updatedAt = DateTime.now();

    await _local.upsertItem(item, dirty: true);
    _items = await _local.loadItems();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<void> deleteItem(String id) async {
    final item = findItem(id);
    await _local.softDeleteItem(id);

    if (item != null) {
      await _photoStorage.deletePhoto(item.photoPath);
    }

    // Usuń to ubranie też z każdej stylizacji, która je zawierała.
    for (final outfit in _outfits) {
      if (outfit.itemIds.contains(id)) {
        outfit.itemIds.remove(id);
        outfit.updatedAt = DateTime.now();
        await _local.upsertOutfit(outfit, dirty: true);
      }
    }

    _items = await _local.loadItems();
    _outfits = await _local.loadOutfits();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<void> wearItem(String id) async {
    final item = findItem(id);
    if (item == null) return;
    item.wears += 1;
    item.updatedAt = DateTime.now();
    await _local.upsertItem(item, dirty: true);
    _items = await _local.loadItems();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<void> unwearItem(String id) async {
    final item = findItem(id);
    if (item == null || item.wears == 0) return;
    item.wears -= 1;
    item.updatedAt = DateTime.now();
    await _local.upsertItem(item, dirty: true);
    _items = await _local.loadItems();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<String> addOutfit(
    String name,
    List<String> itemIds, {
    Map<String, OutfitItemLayout>? layout,
  }) async {
    final now = DateTime.now();
    final outfit = Outfit(
      id: _uuid.v4(),
      name: name,
      itemIds: itemIds,
      layout: layout,
      createdAt: now,
      updatedAt: now,
    );
    await _local.upsertOutfit(outfit, dirty: true);
    _outfits = await _local.loadOutfits();
    notifyListeners();
    _triggerBackgroundSync();
    return outfit.id;
  }

  /// Aktualizuje istniejącą stylizację - np. po edycji układu w Przymierzalni.
  Future<void> updateOutfit(
    String id, {
    String? name,
    List<String>? itemIds,
    Map<String, OutfitItemLayout>? layout,
  }) async {
    final outfit = findOutfit(id);
    if (outfit == null) return;
    if (name != null) outfit.name = name;
    if (itemIds != null) outfit.itemIds = itemIds;
    if (layout != null) outfit.layout = layout;
    outfit.updatedAt = DateTime.now();
    await _local.upsertOutfit(outfit, dirty: true);
    _outfits = await _local.loadOutfits();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<void> deleteOutfit(String id) async {
    await _local.softDeleteOutfit(id);

    // Usuń też wpisy kalendarza, które wskazywały na tę stylizację - inaczej
    // zostałyby "wiszącym" odniesieniem do nieistniejącej już stylizacji.
    for (final entry in _calendarEntries) {
      if (entry.outfitId == id) {
        await _local.softDeleteCalendarEntry(entry.id);
      }
    }

    _outfits = await _local.loadOutfits();
    _calendarEntries = await _local.loadCalendarEntries();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Outfit? findOutfit(String id) {
    for (final o in _outfits) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Zaplanowana stylizacja na dany dzień - null, jeśli nic nie zaplanowano.
  CalendarEntry? entryForDate(DateTime date) {
    for (final e in _calendarEntries) {
      if (isSameDate(e.date, date)) return e;
    }
    return null;
  }

  /// Przypisuje stylizację do dnia. Jeśli ten dzień ma już zaplanowaną
  /// stylizację, ta metoda ją NADPISUJE - potwierdzenie u użytkowniczki
  /// (np. dialog "Nadpisać zaplanowaną stylizację?") należy pokazać PRZED
  /// wywołaniem tej metody, nie w niej.
  Future<void> planOutfit(DateTime date, String outfitId) async {
    final existing = entryForDate(date);
    final now = DateTime.now();

    if (existing != null) {
      existing.outfitId = outfitId;
      existing.updatedAt = now;
      await _local.upsertCalendarEntry(existing, dirty: true);
    } else {
      final entry = CalendarEntry(
        id: _uuid.v4(),
        date: date,
        outfitId: outfitId,
        createdAt: now,
        updatedAt: now,
      );
      await _local.upsertCalendarEntry(entry, dirty: true);
    }

    _calendarEntries = await _local.loadCalendarEntries();
    notifyListeners();
    _triggerBackgroundSync();
  }

  Future<void> removePlannedOutfit(DateTime date) async {
    final existing = entryForDate(date);
    if (existing == null) return;
    await _local.softDeleteCalendarEntry(existing.id);
    _calendarEntries = await _local.loadCalendarEntries();
    notifyListeners();
    _triggerBackgroundSync();
  }
}
