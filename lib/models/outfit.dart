/// Pozycja, skala i obrót jednego elementu ubrania na manekinie w
/// Przymierzalni - zapisywane tylko dla stylizacji stworzonych/edytowanych
/// tam (ręcznie tworzone przez stary kreator nie mają układu - `null`).
class OutfitItemLayout {
  final double x;
  final double y;
  final double scale;
  final double rotation;

  OutfitItemLayout({
    required this.x,
    required this.y,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'scale': scale, 'rotation': rotation};

  factory OutfitItemLayout.fromJson(Map<String, dynamic> json) => OutfitItemLayout(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      );
}

class Outfit {
  final String id;
  String name;
  List<String> itemIds; // kolejność = warstwy na manekinie (ostatni = na wierzchu)
  Map<String, OutfitItemLayout>? layout; // null = brak zapisanego układu wizualnego
  final DateTime createdAt;
  DateTime updatedAt; // moment ostatniej zmiany - podstawa bezpiecznej synchronizacji

  Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    this.layout,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? (createdAt ?? DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'itemIds': itemIds,
        'layout': layout?.map((key, value) => MapEntry(key, value.toJson())),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'] as String,
        name: json['name'] as String,
        itemIds: (json['itemIds'] as List).map((e) => e as String).toList(),
        layout: (json['layout'] as Map?)?.map(
          (key, value) => MapEntry(
            key as String,
            OutfitItemLayout.fromJson(Map<String, dynamic>.from(value as Map)),
          ),
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}
