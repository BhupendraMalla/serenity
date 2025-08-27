enum MoodLevel {
  veryLow(1, '😔', 'Very Low', 'Feeling down'),
  low(2, '😕', 'Low', 'Not great'),
  neutral(3, '😐', 'Neutral', 'Okay'),
  high(4, '🙂', 'High', 'Pretty good'),
  veryHigh(5, '😊', 'Very High', 'Excellent');

  const MoodLevel(this.value, this.emoji, this.label, this.description);

  final int value;
  final String emoji;
  final String label;
  final String description;

  String get accessibilityLabel => '$label mood, $description';
}

enum EntrySource {
  manual,
  import,
  reminder,
}

class MoodEntry {
  final String id;
  final String userId;
  final MoodLevel mood;
  final List<String> tags;
  final String? note;
  final DateTime createdAt;
  final EntrySource source;

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.tags,
    this.note,
    required this.createdAt,
    this.source = EntrySource.manual,
  });

  MoodEntry copyWith({
    String? id,
    String? userId,
    MoodLevel? mood,
    List<String>? tags,
    String? note,
    DateTime? createdAt,
    EntrySource? source,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood.name,
      'tags': tags,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'source': source.name,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      userId: json['userId'],
      mood: MoodLevel.values.firstWhere((e) => e.name == json['mood']),
      tags: List<String>.from(json['tags']),
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      source: EntrySource.values.firstWhere((e) => e.name == json['source']),
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, userId: $userId, mood: $mood, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}