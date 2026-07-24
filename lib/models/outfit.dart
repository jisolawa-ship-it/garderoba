class Outfit {
  final String id;
  String name;
  List<String> itemIds;
  final DateTime createdAt;

  Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'itemIds': itemIds,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'] as String,
        name: json['name'] as String,
        itemIds: (json['itemIds'] as List).map((e) => e as String).toList(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}
