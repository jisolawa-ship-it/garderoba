/// Pojedynczy wpis w kalendarzu: konkretny dzień + wybrana stylizacja.
/// Ta sama stylizacja może być przypisana do wielu różnych dni - dlatego to
/// osobny obiekt, a nie data zapisana wprost na Outfit.
class CalendarEntry {
  final String id;
  final DateTime date; // zawsze znormalizowana do samej daty, bez godziny
  String outfitId;
  final DateTime createdAt;
  DateTime updatedAt;

  CalendarEntry({
    required this.id,
    required DateTime date,
    required this.outfitId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = DateTime(date.year, date.month, date.day),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? (createdAt ?? DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'outfitId': outfitId,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory CalendarEntry.fromJson(Map<String, dynamic> json) => CalendarEntry(
        id: json['id'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        outfitId: json['outfitId'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

/// Porównuje same daty (rok/miesiąc/dzień), ignorując godzinę.
bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
