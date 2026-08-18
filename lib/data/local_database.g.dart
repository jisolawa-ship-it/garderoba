// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $ClothingItemRowsTable extends ClothingItemRows
    with TableInfo<$ClothingItemRowsTable, ClothingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryMeta =
      const VerificationMeta('subcategory');
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
      'subcategory', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorHexMeta =
      const VerificationMeta('colorHex');
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
      'color_hex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wearsMeta = const VerificationMeta('wears');
  @override
  late final GeneratedColumn<int> wears = GeneratedColumn<int>(
      'wears', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seasonsJsonMeta =
      const VerificationMeta('seasonsJson');
  @override
  late final GeneratedColumn<String> seasonsJson = GeneratedColumn<String>(
      'seasons_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ownershipAgeMeta =
      const VerificationMeta('ownershipAge');
  @override
  late final GeneratedColumn<String> ownershipAge = GeneratedColumn<String>(
      'ownership_age', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        subcategory,
        colorHex,
        price,
        wears,
        photoPath,
        photoUrl,
        seasonsJson,
        ownershipAge,
        createdAt,
        updatedAt,
        dirty,
        deleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clothing_item_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ClothingItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
          _subcategoryMeta,
          subcategory.isAcceptableOrUnknown(
              data['subcategory']!, _subcategoryMeta));
    }
    if (data.containsKey('color_hex')) {
      context.handle(_colorHexMeta,
          colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta));
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('wears')) {
      context.handle(
          _wearsMeta, wears.isAcceptableOrUnknown(data['wears']!, _wearsMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('seasons_json')) {
      context.handle(
          _seasonsJsonMeta,
          seasonsJson.isAcceptableOrUnknown(
              data['seasons_json']!, _seasonsJsonMeta));
    }
    if (data.containsKey('ownership_age')) {
      context.handle(
          _ownershipAgeMeta,
          ownershipAge.isAcceptableOrUnknown(
              data['ownership_age']!, _ownershipAgeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClothingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClothingItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subcategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory'])!,
      colorHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_hex'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price']),
      wears: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wears'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      seasonsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seasons_json']),
      ownershipAge: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ownership_age']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
    );
  }

  @override
  $ClothingItemRowsTable createAlias(String alias) {
    return $ClothingItemRowsTable(attachedDatabase, alias);
  }
}

class ClothingItemRow extends DataClass implements Insertable<ClothingItemRow> {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String colorHex;
  final double? price;
  final int wears;
  final String? photoPath;
  final String? photoUrl;
  final String? seasonsJson;
  final String? ownershipAge;
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final bool deleted;
  const ClothingItemRow(
      {required this.id,
      required this.name,
      required this.category,
      required this.subcategory,
      required this.colorHex,
      this.price,
      required this.wears,
      this.photoPath,
      this.photoUrl,
      this.seasonsJson,
      this.ownershipAge,
      required this.createdAt,
      required this.updatedAt,
      required this.dirty,
      required this.deleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['subcategory'] = Variable<String>(subcategory);
    map['color_hex'] = Variable<String>(colorHex);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    map['wears'] = Variable<int>(wears);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || seasonsJson != null) {
      map['seasons_json'] = Variable<String>(seasonsJson);
    }
    if (!nullToAbsent || ownershipAge != null) {
      map['ownership_age'] = Variable<String>(ownershipAge);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  ClothingItemRowsCompanion toCompanion(bool nullToAbsent) {
    return ClothingItemRowsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subcategory: Value(subcategory),
      colorHex: Value(colorHex),
      price:
          price == null && nullToAbsent ? const Value.absent() : Value(price),
      wears: Value(wears),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      seasonsJson: seasonsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonsJson),
      ownershipAge: ownershipAge == null && nullToAbsent
          ? const Value.absent()
          : Value(ownershipAge),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      deleted: Value(deleted),
    );
  }

  factory ClothingItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClothingItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String>(json['subcategory']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      price: serializer.fromJson<double?>(json['price']),
      wears: serializer.fromJson<int>(json['wears']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      seasonsJson: serializer.fromJson<String?>(json['seasonsJson']),
      ownershipAge: serializer.fromJson<String?>(json['ownershipAge']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String>(subcategory),
      'colorHex': serializer.toJson<String>(colorHex),
      'price': serializer.toJson<double?>(price),
      'wears': serializer.toJson<int>(wears),
      'photoPath': serializer.toJson<String?>(photoPath),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'seasonsJson': serializer.toJson<String?>(seasonsJson),
      'ownershipAge': serializer.toJson<String?>(ownershipAge),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  ClothingItemRow copyWith(
          {String? id,
          String? name,
          String? category,
          String? subcategory,
          String? colorHex,
          Value<double?> price = const Value.absent(),
          int? wears,
          Value<String?> photoPath = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> seasonsJson = const Value.absent(),
          Value<String?> ownershipAge = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          bool? dirty,
          bool? deleted}) =>
      ClothingItemRow(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        colorHex: colorHex ?? this.colorHex,
        price: price.present ? price.value : this.price,
        wears: wears ?? this.wears,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        seasonsJson: seasonsJson.present ? seasonsJson.value : this.seasonsJson,
        ownershipAge:
            ownershipAge.present ? ownershipAge.value : this.ownershipAge,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );
  ClothingItemRow copyWithCompanion(ClothingItemRowsCompanion data) {
    return ClothingItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory:
          data.subcategory.present ? data.subcategory.value : this.subcategory,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      price: data.price.present ? data.price.value : this.price,
      wears: data.wears.present ? data.wears.value : this.wears,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      seasonsJson:
          data.seasonsJson.present ? data.seasonsJson.value : this.seasonsJson,
      ownershipAge: data.ownershipAge.present
          ? data.ownershipAge.value
          : this.ownershipAge,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('colorHex: $colorHex, ')
          ..write('price: $price, ')
          ..write('wears: $wears, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('seasonsJson: $seasonsJson, ')
          ..write('ownershipAge: $ownershipAge, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      subcategory,
      colorHex,
      price,
      wears,
      photoPath,
      photoUrl,
      seasonsJson,
      ownershipAge,
      createdAt,
      updatedAt,
      dirty,
      deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClothingItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.colorHex == this.colorHex &&
          other.price == this.price &&
          other.wears == this.wears &&
          other.photoPath == this.photoPath &&
          other.photoUrl == this.photoUrl &&
          other.seasonsJson == this.seasonsJson &&
          other.ownershipAge == this.ownershipAge &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deleted == this.deleted);
}

class ClothingItemRowsCompanion extends UpdateCompanion<ClothingItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> subcategory;
  final Value<String> colorHex;
  final Value<double?> price;
  final Value<int> wears;
  final Value<String?> photoPath;
  final Value<String?> photoUrl;
  final Value<String?> seasonsJson;
  final Value<String?> ownershipAge;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<bool> deleted;
  final Value<int> rowid;
  const ClothingItemRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.price = const Value.absent(),
    this.wears = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.seasonsJson = const Value.absent(),
    this.ownershipAge = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClothingItemRowsCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.subcategory = const Value.absent(),
    required String colorHex,
    this.price = const Value.absent(),
    this.wears = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.seasonsJson = const Value.absent(),
    this.ownershipAge = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        colorHex = Value(colorHex),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClothingItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? colorHex,
    Expression<double>? price,
    Expression<int>? wears,
    Expression<String>? photoPath,
    Expression<String>? photoUrl,
    Expression<String>? seasonsJson,
    Expression<String>? ownershipAge,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (colorHex != null) 'color_hex': colorHex,
      if (price != null) 'price': price,
      if (wears != null) 'wears': wears,
      if (photoPath != null) 'photo_path': photoPath,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (seasonsJson != null) 'seasons_json': seasonsJson,
      if (ownershipAge != null) 'ownership_age': ownershipAge,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClothingItemRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? subcategory,
      Value<String>? colorHex,
      Value<double?>? price,
      Value<int>? wears,
      Value<String?>? photoPath,
      Value<String?>? photoUrl,
      Value<String?>? seasonsJson,
      Value<String?>? ownershipAge,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<bool>? dirty,
      Value<bool>? deleted,
      Value<int>? rowid}) {
    return ClothingItemRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      colorHex: colorHex ?? this.colorHex,
      price: price ?? this.price,
      wears: wears ?? this.wears,
      photoPath: photoPath ?? this.photoPath,
      photoUrl: photoUrl ?? this.photoUrl,
      seasonsJson: seasonsJson ?? this.seasonsJson,
      ownershipAge: ownershipAge ?? this.ownershipAge,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (wears.present) {
      map['wears'] = Variable<int>(wears.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (seasonsJson.present) {
      map['seasons_json'] = Variable<String>(seasonsJson.value);
    }
    if (ownershipAge.present) {
      map['ownership_age'] = Variable<String>(ownershipAge.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('colorHex: $colorHex, ')
          ..write('price: $price, ')
          ..write('wears: $wears, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('seasonsJson: $seasonsJson, ')
          ..write('ownershipAge: $ownershipAge, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitRowsTable extends OutfitRows
    with TableInfo<$OutfitRowsTable, OutfitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdsJsonMeta =
      const VerificationMeta('itemIdsJson');
  @override
  late final GeneratedColumn<String> itemIdsJson = GeneratedColumn<String>(
      'item_ids_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _layoutJsonMeta =
      const VerificationMeta('layoutJson');
  @override
  late final GeneratedColumn<String> layoutJson = GeneratedColumn<String>(
      'layout_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, itemIdsJson, layoutJson, createdAt, updatedAt, dirty, deleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_rows';
  @override
  VerificationContext validateIntegrity(Insertable<OutfitRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('item_ids_json')) {
      context.handle(
          _itemIdsJsonMeta,
          itemIdsJson.isAcceptableOrUnknown(
              data['item_ids_json']!, _itemIdsJsonMeta));
    } else if (isInserting) {
      context.missing(_itemIdsJsonMeta);
    }
    if (data.containsKey('layout_json')) {
      context.handle(
          _layoutJsonMeta,
          layoutJson.isAcceptableOrUnknown(
              data['layout_json']!, _layoutJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutfitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      itemIdsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_ids_json'])!,
      layoutJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}layout_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
    );
  }

  @override
  $OutfitRowsTable createAlias(String alias) {
    return $OutfitRowsTable(attachedDatabase, alias);
  }
}

class OutfitRow extends DataClass implements Insertable<OutfitRow> {
  final String id;
  final String name;
  final String itemIdsJson;
  final String? layoutJson;
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final bool deleted;
  const OutfitRow(
      {required this.id,
      required this.name,
      required this.itemIdsJson,
      this.layoutJson,
      required this.createdAt,
      required this.updatedAt,
      required this.dirty,
      required this.deleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['item_ids_json'] = Variable<String>(itemIdsJson);
    if (!nullToAbsent || layoutJson != null) {
      map['layout_json'] = Variable<String>(layoutJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  OutfitRowsCompanion toCompanion(bool nullToAbsent) {
    return OutfitRowsCompanion(
      id: Value(id),
      name: Value(name),
      itemIdsJson: Value(itemIdsJson),
      layoutJson: layoutJson == null && nullToAbsent
          ? const Value.absent()
          : Value(layoutJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      deleted: Value(deleted),
    );
  }

  factory OutfitRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      itemIdsJson: serializer.fromJson<String>(json['itemIdsJson']),
      layoutJson: serializer.fromJson<String?>(json['layoutJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'itemIdsJson': serializer.toJson<String>(itemIdsJson),
      'layoutJson': serializer.toJson<String?>(layoutJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  OutfitRow copyWith(
          {String? id,
          String? name,
          String? itemIdsJson,
          Value<String?> layoutJson = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          bool? dirty,
          bool? deleted}) =>
      OutfitRow(
        id: id ?? this.id,
        name: name ?? this.name,
        itemIdsJson: itemIdsJson ?? this.itemIdsJson,
        layoutJson: layoutJson.present ? layoutJson.value : this.layoutJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );
  OutfitRow copyWithCompanion(OutfitRowsCompanion data) {
    return OutfitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      itemIdsJson:
          data.itemIdsJson.present ? data.itemIdsJson.value : this.itemIdsJson,
      layoutJson:
          data.layoutJson.present ? data.layoutJson.value : this.layoutJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemIdsJson: $itemIdsJson, ')
          ..write('layoutJson: $layoutJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, itemIdsJson, layoutJson, createdAt, updatedAt, dirty, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.itemIdsJson == this.itemIdsJson &&
          other.layoutJson == this.layoutJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deleted == this.deleted);
}

class OutfitRowsCompanion extends UpdateCompanion<OutfitRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> itemIdsJson;
  final Value<String?> layoutJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<bool> deleted;
  final Value<int> rowid;
  const OutfitRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.itemIdsJson = const Value.absent(),
    this.layoutJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitRowsCompanion.insert({
    required String id,
    required String name,
    required String itemIdsJson,
    this.layoutJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        itemIdsJson = Value(itemIdsJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<OutfitRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? itemIdsJson,
    Expression<String>? layoutJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (itemIdsJson != null) 'item_ids_json': itemIdsJson,
      if (layoutJson != null) 'layout_json': layoutJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? itemIdsJson,
      Value<String?>? layoutJson,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<bool>? dirty,
      Value<bool>? deleted,
      Value<int>? rowid}) {
    return OutfitRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      itemIdsJson: itemIdsJson ?? this.itemIdsJson,
      layoutJson: layoutJson ?? this.layoutJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (itemIdsJson.present) {
      map['item_ids_json'] = Variable<String>(itemIdsJson.value);
    }
    if (layoutJson.present) {
      map['layout_json'] = Variable<String>(layoutJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('itemIdsJson: $itemIdsJson, ')
          ..write('layoutJson: $layoutJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEntryRowsTable extends CalendarEntryRows
    with TableInfo<$CalendarEntryRowsTable, CalendarEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEntryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
      'date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _outfitIdMeta =
      const VerificationMeta('outfitId');
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>(
      'outfit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, outfitId, createdAt, updatedAt, dirty, deleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_entry_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('outfit_id')) {
      context.handle(_outfitIdMeta,
          outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta));
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}date'])!,
      outfitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outfit_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
    );
  }

  @override
  $CalendarEntryRowsTable createAlias(String alias) {
    return $CalendarEntryRowsTable(attachedDatabase, alias);
  }
}

class CalendarEntryRow extends DataClass
    implements Insertable<CalendarEntryRow> {
  final String id;
  final int date;
  final String outfitId;
  final int createdAt;
  final int updatedAt;
  final bool dirty;
  final bool deleted;
  const CalendarEntryRow(
      {required this.id,
      required this.date,
      required this.outfitId,
      required this.createdAt,
      required this.updatedAt,
      required this.dirty,
      required this.deleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<int>(date);
    map['outfit_id'] = Variable<String>(outfitId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  CalendarEntryRowsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEntryRowsCompanion(
      id: Value(id),
      date: Value(date),
      outfitId: Value(outfitId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
      deleted: Value(deleted),
    );
  }

  factory CalendarEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEntryRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<int>(json['date']),
      outfitId: serializer.fromJson<String>(json['outfitId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<int>(date),
      'outfitId': serializer.toJson<String>(outfitId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  CalendarEntryRow copyWith(
          {String? id,
          int? date,
          String? outfitId,
          int? createdAt,
          int? updatedAt,
          bool? dirty,
          bool? deleted}) =>
      CalendarEntryRow(
        id: id ?? this.id,
        date: date ?? this.date,
        outfitId: outfitId ?? this.outfitId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );
  CalendarEntryRow copyWithCompanion(CalendarEntryRowsCompanion data) {
    return CalendarEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('outfitId: $outfitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, outfitId, createdAt, updatedAt, dirty, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.outfitId == this.outfitId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty &&
          other.deleted == this.deleted);
}

class CalendarEntryRowsCompanion extends UpdateCompanion<CalendarEntryRow> {
  final Value<String> id;
  final Value<int> date;
  final Value<String> outfitId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<bool> dirty;
  final Value<bool> deleted;
  final Value<int> rowid;
  const CalendarEntryRowsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.outfitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEntryRowsCompanion.insert({
    required String id,
    required int date,
    required String outfitId,
    required int createdAt,
    required int updatedAt,
    this.dirty = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        outfitId = Value(outfitId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CalendarEntryRow> custom({
    Expression<String>? id,
    Expression<int>? date,
    Expression<String>? outfitId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<bool>? dirty,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (outfitId != null) 'outfit_id': outfitId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEntryRowsCompanion copyWith(
      {Value<String>? id,
      Value<int>? date,
      Value<String>? outfitId,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<bool>? dirty,
      Value<bool>? deleted,
      Value<int>? rowid}) {
    return CalendarEntryRowsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEntryRowsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('outfitId: $outfitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClothingItemRowsTable clothingItemRows =
      $ClothingItemRowsTable(this);
  late final $OutfitRowsTable outfitRows = $OutfitRowsTable(this);
  late final $CalendarEntryRowsTable calendarEntryRows =
      $CalendarEntryRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [clothingItemRows, outfitRows, calendarEntryRows];
}

typedef $$ClothingItemRowsTableCreateCompanionBuilder
    = ClothingItemRowsCompanion Function({
  required String id,
  required String name,
  required String category,
  Value<String> subcategory,
  required String colorHex,
  Value<double?> price,
  Value<int> wears,
  Value<String?> photoPath,
  Value<String?> photoUrl,
  Value<String?> seasonsJson,
  Value<String?> ownershipAge,
  required int createdAt,
  required int updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$ClothingItemRowsTableUpdateCompanionBuilder
    = ClothingItemRowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> subcategory,
  Value<String> colorHex,
  Value<double?> price,
  Value<int> wears,
  Value<String?> photoPath,
  Value<String?> photoUrl,
  Value<String?> seasonsJson,
  Value<String?> ownershipAge,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$ClothingItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ClothingItemRowsTable> {
  $$ClothingItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wears => $composableBuilder(
      column: $table.wears, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seasonsJson => $composableBuilder(
      column: $table.seasonsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownershipAge => $composableBuilder(
      column: $table.ownershipAge, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));
}

class $$ClothingItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClothingItemRowsTable> {
  $$ClothingItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorHex => $composableBuilder(
      column: $table.colorHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wears => $composableBuilder(
      column: $table.wears, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seasonsJson => $composableBuilder(
      column: $table.seasonsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownershipAge => $composableBuilder(
      column: $table.ownershipAge,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));
}

class $$ClothingItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClothingItemRowsTable> {
  $$ClothingItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
      column: $table.subcategory, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get wears =>
      $composableBuilder(column: $table.wears, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get seasonsJson => $composableBuilder(
      column: $table.seasonsJson, builder: (column) => column);

  GeneratedColumn<String> get ownershipAge => $composableBuilder(
      column: $table.ownershipAge, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$ClothingItemRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClothingItemRowsTable,
    ClothingItemRow,
    $$ClothingItemRowsTableFilterComposer,
    $$ClothingItemRowsTableOrderingComposer,
    $$ClothingItemRowsTableAnnotationComposer,
    $$ClothingItemRowsTableCreateCompanionBuilder,
    $$ClothingItemRowsTableUpdateCompanionBuilder,
    (
      ClothingItemRow,
      BaseReferences<_$AppDatabase, $ClothingItemRowsTable, ClothingItemRow>
    ),
    ClothingItemRow,
    PrefetchHooks Function()> {
  $$ClothingItemRowsTableTableManager(
      _$AppDatabase db, $ClothingItemRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClothingItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClothingItemRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClothingItemRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subcategory = const Value.absent(),
            Value<String> colorHex = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<int> wears = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> seasonsJson = const Value.absent(),
            Value<String?> ownershipAge = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClothingItemRowsCompanion(
            id: id,
            name: name,
            category: category,
            subcategory: subcategory,
            colorHex: colorHex,
            price: price,
            wears: wears,
            photoPath: photoPath,
            photoUrl: photoUrl,
            seasonsJson: seasonsJson,
            ownershipAge: ownershipAge,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            Value<String> subcategory = const Value.absent(),
            required String colorHex,
            Value<double?> price = const Value.absent(),
            Value<int> wears = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> seasonsJson = const Value.absent(),
            Value<String?> ownershipAge = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClothingItemRowsCompanion.insert(
            id: id,
            name: name,
            category: category,
            subcategory: subcategory,
            colorHex: colorHex,
            price: price,
            wears: wears,
            photoPath: photoPath,
            photoUrl: photoUrl,
            seasonsJson: seasonsJson,
            ownershipAge: ownershipAge,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClothingItemRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClothingItemRowsTable,
    ClothingItemRow,
    $$ClothingItemRowsTableFilterComposer,
    $$ClothingItemRowsTableOrderingComposer,
    $$ClothingItemRowsTableAnnotationComposer,
    $$ClothingItemRowsTableCreateCompanionBuilder,
    $$ClothingItemRowsTableUpdateCompanionBuilder,
    (
      ClothingItemRow,
      BaseReferences<_$AppDatabase, $ClothingItemRowsTable, ClothingItemRow>
    ),
    ClothingItemRow,
    PrefetchHooks Function()>;
typedef $$OutfitRowsTableCreateCompanionBuilder = OutfitRowsCompanion Function({
  required String id,
  required String name,
  required String itemIdsJson,
  Value<String?> layoutJson,
  required int createdAt,
  required int updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$OutfitRowsTableUpdateCompanionBuilder = OutfitRowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> itemIdsJson,
  Value<String?> layoutJson,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$OutfitRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitRowsTable> {
  $$OutfitRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemIdsJson => $composableBuilder(
      column: $table.itemIdsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));
}

class $$OutfitRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitRowsTable> {
  $$OutfitRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemIdsJson => $composableBuilder(
      column: $table.itemIdsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));
}

class $$OutfitRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitRowsTable> {
  $$OutfitRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get itemIdsJson => $composableBuilder(
      column: $table.itemIdsJson, builder: (column) => column);

  GeneratedColumn<String> get layoutJson => $composableBuilder(
      column: $table.layoutJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$OutfitRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutfitRowsTable,
    OutfitRow,
    $$OutfitRowsTableFilterComposer,
    $$OutfitRowsTableOrderingComposer,
    $$OutfitRowsTableAnnotationComposer,
    $$OutfitRowsTableCreateCompanionBuilder,
    $$OutfitRowsTableUpdateCompanionBuilder,
    (OutfitRow, BaseReferences<_$AppDatabase, $OutfitRowsTable, OutfitRow>),
    OutfitRow,
    PrefetchHooks Function()> {
  $$OutfitRowsTableTableManager(_$AppDatabase db, $OutfitRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> itemIdsJson = const Value.absent(),
            Value<String?> layoutJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutfitRowsCompanion(
            id: id,
            name: name,
            itemIdsJson: itemIdsJson,
            layoutJson: layoutJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String itemIdsJson,
            Value<String?> layoutJson = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutfitRowsCompanion.insert(
            id: id,
            name: name,
            itemIdsJson: itemIdsJson,
            layoutJson: layoutJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutfitRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutfitRowsTable,
    OutfitRow,
    $$OutfitRowsTableFilterComposer,
    $$OutfitRowsTableOrderingComposer,
    $$OutfitRowsTableAnnotationComposer,
    $$OutfitRowsTableCreateCompanionBuilder,
    $$OutfitRowsTableUpdateCompanionBuilder,
    (OutfitRow, BaseReferences<_$AppDatabase, $OutfitRowsTable, OutfitRow>),
    OutfitRow,
    PrefetchHooks Function()>;
typedef $$CalendarEntryRowsTableCreateCompanionBuilder
    = CalendarEntryRowsCompanion Function({
  required String id,
  required int date,
  required String outfitId,
  required int createdAt,
  required int updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});
typedef $$CalendarEntryRowsTableUpdateCompanionBuilder
    = CalendarEntryRowsCompanion Function({
  Value<String> id,
  Value<int> date,
  Value<String> outfitId,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<bool> dirty,
  Value<bool> deleted,
  Value<int> rowid,
});

class $$CalendarEntryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEntryRowsTable> {
  $$CalendarEntryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outfitId => $composableBuilder(
      column: $table.outfitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));
}

class $$CalendarEntryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEntryRowsTable> {
  $$CalendarEntryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outfitId => $composableBuilder(
      column: $table.outfitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));
}

class $$CalendarEntryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEntryRowsTable> {
  $$CalendarEntryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get outfitId =>
      $composableBuilder(column: $table.outfitId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);
}

class $$CalendarEntryRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarEntryRowsTable,
    CalendarEntryRow,
    $$CalendarEntryRowsTableFilterComposer,
    $$CalendarEntryRowsTableOrderingComposer,
    $$CalendarEntryRowsTableAnnotationComposer,
    $$CalendarEntryRowsTableCreateCompanionBuilder,
    $$CalendarEntryRowsTableUpdateCompanionBuilder,
    (
      CalendarEntryRow,
      BaseReferences<_$AppDatabase, $CalendarEntryRowsTable, CalendarEntryRow>
    ),
    CalendarEntryRow,
    PrefetchHooks Function()> {
  $$CalendarEntryRowsTableTableManager(
      _$AppDatabase db, $CalendarEntryRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEntryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEntryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEntryRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> date = const Value.absent(),
            Value<String> outfitId = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEntryRowsCompanion(
            id: id,
            date: date,
            outfitId: outfitId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int date,
            required String outfitId,
            required int createdAt,
            required int updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEntryRowsCompanion.insert(
            id: id,
            date: date,
            outfitId: outfitId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dirty: dirty,
            deleted: deleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CalendarEntryRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarEntryRowsTable,
    CalendarEntryRow,
    $$CalendarEntryRowsTableFilterComposer,
    $$CalendarEntryRowsTableOrderingComposer,
    $$CalendarEntryRowsTableAnnotationComposer,
    $$CalendarEntryRowsTableCreateCompanionBuilder,
    $$CalendarEntryRowsTableUpdateCompanionBuilder,
    (
      CalendarEntryRow,
      BaseReferences<_$AppDatabase, $CalendarEntryRowsTable, CalendarEntryRow>
    ),
    CalendarEntryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClothingItemRowsTableTableManager get clothingItemRows =>
      $$ClothingItemRowsTableTableManager(_db, _db.clothingItemRows);
  $$OutfitRowsTableTableManager get outfitRows =>
      $$OutfitRowsTableTableManager(_db, _db.outfitRows);
  $$CalendarEntryRowsTableTableManager get calendarEntryRows =>
      $$CalendarEntryRowsTableTableManager(_db, _db.calendarEntryRows);
}
