enum JournalEntryType {
  freeform,
  guided,
  moodBased,
}

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final JournalEntryType type;
  final List<String> tags;
  final String? moodEntryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEncrypted;
  final bool isFavorite;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.type = JournalEntryType.freeform,
    this.tags = const [],
    this.moodEntryId,
    required this.createdAt,
    required this.updatedAt,
    this.isEncrypted = false,
    this.isFavorite = false,
  });

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    JournalEntryType? type,
    List<String>? tags,
    String? moodEntryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEncrypted,
    bool? isFavorite,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      moodEntryId: moodEntryId ?? this.moodEntryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'type': type.name,
      'tags': tags,
      'moodEntryId': moodEntryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'isFavorite': isFavorite,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: JournalEntryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => JournalEntryType.freeform,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      moodEntryId: json['moodEntryId'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

class JournalPrompt {
  final String id;
  final String title;
  final String prompt;
  final String? category;
  final List<String> tags;
  final bool isDaily;

  const JournalPrompt({
    required this.id,
    required this.title,
    required this.prompt,
    this.category,
    this.tags = const [],
    this.isDaily = false,
  });

  JournalPrompt copyWith({
    String? id,
    String? title,
    String? prompt,
    String? category,
    List<String>? tags,
    bool? isDaily,
  }) {
    return JournalPrompt(
      id: id ?? this.id,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isDaily: isDaily ?? this.isDaily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'category': category,
      'tags': tags,
      'isDaily': isDaily,
    };
  }

  factory JournalPrompt.fromJson(Map<String, dynamic> json) {
    return JournalPrompt(
      id: json['id'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      category: json['category'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isDaily: json['isDaily'] as bool? ?? false,
    );
  }
}