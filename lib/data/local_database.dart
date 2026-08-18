import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'local_database.g.dart';

/// Ubrania - każdy wiersz ma znacznik czasu ostatniej zmiany (`updatedAt`)
/// i dwie flagi kluczowe dla bezpiecznej synchronizacji:
/// - `dirty`: rekord ma lokalne zmiany, które NIE zostały jeszcze wysłane
///   do chmury - dopóki `dirty=true`, synchronizacja nigdy nie nadpisze
///   tego rekordu danymi z chmury.
/// - `deleted`: "grób" (tombstone) - rekord jest logicznie usunięty, ale
///   zostaje chwilę w bazie, żeby dało się przekazać tę informację do
///   chmury, zanim zniknie na dobre.
@DataClassName('ClothingItemRow')
class ClothingItemRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().withDefault(const Constant(''))();
  TextColumn get colorHex => text()();
  RealColumn get price => real().nullable()();
  IntColumn get wears => integer().withDefault(const Constant(0))();
  TextColumn get photoPath => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get seasonsJson => text().nullable()();
  TextColumn get ownershipAge => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stylizacje - `itemIdsJson` trzyma listę ID ubrań zakodowaną jako JSON
/// (Drift nie ma natywnej kolumny na listę Stringów).
@DataClassName('OutfitRow')
class OutfitRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get itemIdsJson => text()();
  TextColumn get layoutJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Wpisy kalendarza - jeden wiersz = jeden dzień + jedna zaplanowana
/// stylizacja. `date` trzymana jako północ danego dnia (bez godziny).
@DataClassName('CalendarEntryRow')
class CalendarEntryRows extends Table {
  TextColumn get id => text()();
  IntColumn get date => integer()();
  TextColumn get outfitId => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ClothingItemRows, OutfitRows, CalendarEntryRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---------------------------------------------------------------------
  // Ubrania
  // ---------------------------------------------------------------------

  /// Wszystkie ubrania widoczne dla użytkowniczki (bez "grobów").
  Future<List<ClothingItemRow>> allActiveItems() =>
      (select(clothingItemRows)..where((t) => t.deleted.equals(false))).get();

  /// Ubrania z niewysłanymi lokalnie zmianami (do wypchnięcia do chmury).
  Future<List<ClothingItemRow>> dirtyItemRows() =>
      (select(clothingItemRows)..where((t) => t.dirty.equals(true))).get();

  /// ID ubrań, które są w pełni zsynchronizowane (brak lokalnych zmian
  /// czekających na wysłanie) - używane do wykrywania usunięć zdalnych.
  Future<Set<String>> nonDirtyActiveItemIds() async {
    final rows = await (select(clothingItemRows)
          ..where((t) => t.dirty.equals(false) & t.deleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<void> upsertItemRow(ClothingItemRowsCompanion row) =>
      into(clothingItemRows).insertOnConflictUpdate(row);

  Future<void> markItemSynced(String id) =>
      (update(clothingItemRows)..where((t) => t.id.equals(id)))
          .write(const ClothingItemRowsCompanion(dirty: Value(false)));

  Future<void> softDeleteItemRow(String id) =>
      (update(clothingItemRows)..where((t) => t.id.equals(id))).write(
        ClothingItemRowsCompanion(
          deleted: const Value(true),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> hardDeleteItem(String id) =>
      (delete(clothingItemRows)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------
  // Stylizacje
  // ---------------------------------------------------------------------

  Future<List<OutfitRow>> allActiveOutfits() =>
      (select(outfitRows)..where((t) => t.deleted.equals(false))).get();

  Future<List<OutfitRow>> dirtyOutfitRows() =>
      (select(outfitRows)..where((t) => t.dirty.equals(true))).get();

  Future<Set<String>> nonDirtyActiveOutfitIds() async {
    final rows = await (select(outfitRows)
          ..where((t) => t.dirty.equals(false) & t.deleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<void> upsertOutfitRow(OutfitRowsCompanion row) =>
      into(outfitRows).insertOnConflictUpdate(row);

  Future<void> markOutfitSynced(String id) =>
      (update(outfitRows)..where((t) => t.id.equals(id)))
          .write(const OutfitRowsCompanion(dirty: Value(false)));

  Future<void> softDeleteOutfitRow(String id) =>
      (update(outfitRows)..where((t) => t.id.equals(id))).write(
        OutfitRowsCompanion(
          deleted: const Value(true),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> hardDeleteOutfit(String id) =>
      (delete(outfitRows)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------
  // Kalendarz
  // ---------------------------------------------------------------------

  Future<List<CalendarEntryRow>> allActiveCalendarEntries() =>
      (select(calendarEntryRows)..where((t) => t.deleted.equals(false))).get();

  Future<List<CalendarEntryRow>> dirtyCalendarEntryRows() =>
      (select(calendarEntryRows)..where((t) => t.dirty.equals(true))).get();

  Future<Set<String>> nonDirtyActiveCalendarEntryIds() async {
    final rows = await (select(calendarEntryRows)
          ..where((t) => t.dirty.equals(false) & t.deleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<void> upsertCalendarEntryRow(CalendarEntryRowsCompanion row) =>
      into(calendarEntryRows).insertOnConflictUpdate(row);

  Future<void> markCalendarEntrySynced(String id) =>
      (update(calendarEntryRows)..where((t) => t.id.equals(id)))
          .write(const CalendarEntryRowsCompanion(dirty: Value(false)));

  Future<void> softDeleteCalendarEntryRow(String id) =>
      (update(calendarEntryRows)..where((t) => t.id.equals(id))).write(
        CalendarEntryRowsCompanion(
          deleted: const Value(true),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> hardDeleteCalendarEntry(String id) =>
      (delete(calendarEntryRows)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'szafnik.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
