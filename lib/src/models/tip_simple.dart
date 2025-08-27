enum TipCategory {
  stress,
  anxiety,
  sleep,
  mindfulness,
  productivity,
  relationships,
  general,
}

class Tip {
  final String id;
  final String title;
  final String content;
  final TipCategory category;
  final List<String> tags;
  final String? imageUrl;
  final String? author;
  final String? source;
  final DateTime createdAt;
  final bool isFeatured;

  const Tip({
    required this.id,
    required this.title,
    required this.content,
    this.category = TipCategory.general,
    this.tags = const [],
    this.imageUrl,
    this.author,
    this.source,
    required this.createdAt,
    this.isFeatured = false,
  });

  Tip copyWith({
    String? id,
    String? title,
    String? content,
    TipCategory? category,
    List<String>? tags,
    String? imageUrl,
    String? author,
    String? source,
    DateTime? createdAt,
    bool? isFeatured,
  }) {
    return Tip(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category.name,
      'tags': tags,
      'imageUrl': imageUrl,
      'author': author,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'isFeatured': isFeatured,
    };
  }

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: TipCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TipCategory.general,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      imageUrl: json['imageUrl'] as String?,
      author: json['author'] as String?,
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}

class DailyQuote {
  final String id;
  final String quote;
  final String author;
  final String? source;
  final TipCategory? category;
  final DateTime date;

  const DailyQuote({
    required this.id,
    required this.quote,
    required this.author,
    this.source,
    this.category,
    required this.date,
  });

  DailyQuote copyWith({
    String? id,
    String? quote,
    String? author,
    String? source,
    TipCategory? category,
    DateTime? date,
  }) {
    return DailyQuote(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      source: source ?? this.source,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'source': source,
      'category': category?.name,
      'date': date.toIso8601String(),
    };
  }

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    return DailyQuote(
      id: json['id'] as String,
      quote: json['quote'] as String,
      author: json['author'] as String,
      source: json['source'] as String?,
      category: json['category'] != null
          ? TipCategory.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => TipCategory.general,
            )
          : null,
      date: DateTime.parse(json['date']),
    );
  }
}