import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'local_database.dart';
import '../models/calendar_entry.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

/// Rekord z lokalnej bazy razem z informacją, czy jest "grobem" (do
/// usunięcia zdalnie) - potrzebne przy wysyłaniu zmian do chmury.
class DirtyRecord<T> {
  final T value;
  final bool wasDeleted;
  DirtyRecord(this.value, this.wasDeleted);
}

class WardrobeLocalStore {
  final AppDatabase _db = AppDatabase();

  static const _legacyKey = 'wardrobe_data_v1';

  /// Jednorazowa migracja ze starego formatu (jeden JSON w SharedPreferences)
  /// do lokalnej bazy Drift. Bezpieczna do wywołania wielokrotnie - jeśli
  /// nie ma starych danych, nic się nie dzieje.
  Future<void> migrateFromLegacyIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_legacyKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final e in (data['items'] as List? ?? [])) {
        final item = ClothingItem.fromJson(Map<String, dynamic>.from(e as Map));
        await upsertItem(item, dirty: true); // dirty=true, żeby wysłać do chmury przy najbliższej okazji
      }
      for (final e in (data['outfits'] as List? ?? [])) {
        final outfit = Outfit.fromJson(Map<String, dynamic>.from(e as Map));
        await upsertOutfit(outfit, dirty: true);
      }
    } catch (_) {
      // Stare dane uszkodzone - nie blokujemy startu appki. Trudno,
      // zaczynamy z pustą (nową) lokalną bazą.
    } finally {
      await prefs.remove(_legacyKey);
    }
  }

  // ---------------------------------------------------------------------
  // Odczyt
  // ---------------------------------------------------------------------

  Future<List<ClothingItem>> loadItems() async {
    final rows = await _db.allActiveItems();
    return rows.map(_itemFromRow).toList();
  }

  Future<List<Outfit>> loadOutfits() async {
    final rows = await _db.allActiveOutfits();
    return rows.map(_outfitFromRow).toList();
  }

  Future<List<CalendarEntry>> loadCalendarEntries() async {
    final rows = await _db.allActiveCalendarEntries();
    return rows.map(_calendarEntryFromRow).toList();
  }

  // ---------------------------------------------------------------------
  // Zapis
  // ---------------------------------------------------------------------

  /// Zapisuje ubranie lokalnie. `dirty: true` = "to jest zmiana, którą
  /// trzeba jeszcze wysłać do chmury" (normalna edycja przez użytkowniczkę).
  /// `dirty: false` = "to już jest zsynchronizowane" (np. dane właśnie
  /// ściągnięte z chmury).
  Future<void> upsertItem(ClothingItem item, {required bool dirty}) {
    return _db.upsertItemRow(ClothingItemRowsCompanion.insert(
      id: item.id,
      name: item.name,
      category: item.category.name,
      subcategory: Value(item.subcategory),
      colorHex: item.colorHex,
      price: Value(item.price),
      wears: Value(item.wears),
      photoPath: Value(item.photoPath),
      photoUrl: Value(item.photoUrl),
      seasonsJson: Value(item.seasons.isEmpty ? null : jsonEncode(item.seasons)),
      ownershipAge: Value(item.ownershipAge),
      createdAt: item.createdAt.millisecondsSinceEpoch,
      updatedAt: item.updatedAt.millisecondsSinceEpoch,
      dirty: Value(dirty),
      deleted: const Value(false),
    ));
  }

  Future<void> upsertOutfit(Outfit outfit, {required bool dirty}) {
    return _db.upsertOutfitRow(OutfitRowsCompanion.insert(
      id: outfit.id,
      name: outfit.name,
      itemIdsJson: jsonEncode(outfit.itemIds),
      layoutJson: Value(
        outfit.layout == null
            ? null
            : jsonEncode(outfit.layout!.map((k, v) => MapEntry(k, v.toJson()))),
      ),
      createdAt: outfit.createdAt.millisecondsSinceEpoch,
      updatedAt: outfit.updatedAt.millisecondsSinceEpoch,
      dirty: Value(dirty),
      deleted: const Value(false),
    ));
  }

  /// Usunięcie = tylko oznaczenie "grobu" (nic nie znika od razu) - dzięki
  /// temu appka wie, że musi przekazać tę informację do chmury, zanim
  /// rekord zniknie na dobre.
  Future<void> softDeleteItem(String id) => _db.softDeleteItemRow(id);
  Future<void> softDeleteOutfit(String id) => _db.softDeleteOutfitRow(id);
  Future<void> softDeleteCalendarEntry(String id) => _db.softDeleteCalendarEntryRow(id);

  Future<void> upsertCalendarEntry(CalendarEntry entry, {required bool dirty}) {
    return _db.upsertCalendarEntryRow(CalendarEntryRowsCompanion.insert(
      id: entry.id,
      date: entry.date.millisecondsSinceEpoch,
      outfitId: entry.outfitId,
      createdAt: entry.createdAt.millisecondsSinceEpoch,
      updatedAt: entry.updatedAt.millisecondsSinceEpoch,
      dirty: Value(dirty),
      deleted: const Value(false),
    ));
  }

  // ---------------------------------------------------------------------
  // Synchronizacja
  // ---------------------------------------------------------------------

  Future<List<DirtyRecord<ClothingItem>>> dirtyItems() async {
    final rows = await _db.dirtyItemRows();
    return rows.map((r) => DirtyRecord(_itemFromRow(r), r.deleted)).toList();
  }

  Future<List<DirtyRecord<Outfit>>> dirtyOutfits() async {
    final rows = await _db.dirtyOutfitRows();
    return rows.map((r) => DirtyRecord(_outfitFromRow(r), r.deleted)).toList();
  }

  Future<List<DirtyRecord<CalendarEntry>>> dirtyCalendarEntries() async {
    final rows = await _db.dirtyCalendarEntryRows();
    return rows.map((r) => DirtyRecord(_calendarEntryFromRow(r), r.deleted)).toList();
  }

  /// Wywoływane po udanym wysłaniu zmiany do chmury: jeśli to była
  /// zmiana zwykła - zdejmujemy flagę "niezsynchronizowane". Jeśli to
  /// był "grób" (usunięcie) - można go już bezpiecznie skasować lokalnie
  /// na dobre, bo chmura już o tym wie.
  Future<void> confirmItemPushed(String id, {required bool wasDeleted}) {
    return wasDeleted ? _db.hardDeleteItem(id) : _db.markItemSynced(id);
  }

  Future<void> confirmOutfitPushed(String id, {required bool wasDeleted}) {
    return wasDeleted ? _db.hardDeleteOutfit(id) : _db.markOutfitSynced(id);
  }

  Future<void> confirmCalendarEntryPushed(String id, {required bool wasDeleted}) {
    return wasDeleted ? _db.hardDeleteCalendarEntry(id) : _db.markCalendarEntrySynced(id);
  }

  Future<Set<String>> nonDirtyItemIds() => _db.nonDirtyActiveItemIds();
  Future<Set<String>> nonDirtyOutfitIds() => _db.nonDirtyActiveOutfitIds();
  Future<Set<String>> nonDirtyCalendarEntryIds() => _db.nonDirtyActiveCalendarEntryIds();

  /// Ubranie zniknęło na innym urządzeniu (nie ma go już w chmurze), a
  /// lokalnie nie mamy do niego żadnych niewysłanych zmian - można je
  /// bezpiecznie usunąć też tutaj, bez pytania (bo to już nie utrata
  /// danych, tylko dogonienie stanu, który i tak już obowiązuje).
  Future<void> hardDeleteItemIfPresent(String id) => _db.hardDeleteItem(id);
  Future<void> hardDeleteOutfitIfPresent(String id) => _db.hardDeleteOutfit(id);
  Future<void> hardDeleteCalendarEntryIfPresent(String id) => _db.hardDeleteCalendarEntry(id);

  /// Zapisuje dane ściągnięte z chmury jako już-zsynchronizowane
  /// (dirty: false) - używane wyłącznie przy odbieraniu zmian, nigdy przy
  /// zwykłej edycji przez użytkowniczkę.
  Future<void> applyRemoteItem(ClothingItem item) =>
      upsertItem(item, dirty: false);
  Future<void> applyRemoteOutfit(Outfit outfit) =>
      upsertOutfit(outfit, dirty: false);
  Future<void> applyRemoteCalendarEntry(CalendarEntry entry) =>
      upsertCalendarEntry(entry, dirty: false);

  // ---------------------------------------------------------------------
  // Mapowanie wiersz <-> model
  // ---------------------------------------------------------------------

  ClothingItem _itemFromRow(ClothingItemRow r) => ClothingItem(
        id: r.id,
        name: r.name,
        category: ClothingCategory.values.byName(r.category),
        subcategory: r.subcategory,
        colorHex: r.colorHex,
        price: r.price,
        wears: r.wears,
        photoPath: r.photoPath,
        photoUrl: r.photoUrl,
        seasons: r.seasonsJson == null
            ? const []
            : (jsonDecode(r.seasonsJson!) as List).map((e) => e as String).toList(),
        ownershipAge: r.ownershipAge,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt),
      );

  Outfit _outfitFromRow(OutfitRow r) => Outfit(
        id: r.id,
        name: r.name,
        itemIds: (jsonDecode(r.itemIdsJson) as List).map((e) => e as String).toList(),
        layout: r.layoutJson == null
            ? null
            : (jsonDecode(r.layoutJson!) as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  OutfitItemLayout.fromJson(Map<String, dynamic>.from(value as Map)),
                ),
              ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt),
      );

  CalendarEntry _calendarEntryFromRow(CalendarEntryRow r) => CalendarEntry(
        id: r.id,
        date: DateTime.fromMillisecondsSinceEpoch(r.date),
        outfitId: r.outfitId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt),
      );
}
