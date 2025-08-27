enum MeditationTheme {
  stress,
  focus,
  sleep,
  mindfulness,
  anxiety,
  energy,
}

class MeditationSession {
  final String id;
  final String title;
  final MeditationTheme theme;
  final int durationSeconds;
  final String audioUrl;
  final String? description;
  final List<String> tags;
  final bool isPremium;
  final bool isFeatured;
  final String? instructorName;
  final String? thumbnailUrl;
  final DateTime createdAt;

  const MeditationSession({
    required this.id,
    required this.title,
    required this.theme,
    required this.durationSeconds,
    required this.audioUrl,
    this.description,
    this.tags = const [],
    this.isPremium = false,
    this.isFeatured = false,
    this.instructorName,
    this.thumbnailUrl,
    required this.createdAt,
  });

  MeditationSession copyWith({
    String? id,
    String? title,
    MeditationTheme? theme,
    int? durationSeconds,
    String? audioUrl,
    String? description,
    List<String>? tags,
    bool? isPremium,
    bool? isFeatured,
    String? instructorName,
    String? thumbnailUrl,
    DateTime? createdAt,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      isFeatured: isFeatured ?? this.isFeatured,
      instructorName: instructorName ?? this.instructorName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get durationMinutes => (durationSeconds / 60).round();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme.name,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'description': description,
      'tags': tags,
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'instructorName': instructorName,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      title: json['title'] as String,
      theme: MeditationTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => MeditationTheme.mindfulness,
      ),
      durationSeconds: json['durationSeconds'] as int,
      audioUrl: json['audioUrl'] as String,
      description: json['description'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isPremium: json['isPremium'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      instructorName: json['instructorName'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MeditationProgress {
  final String id;
  final String userId;
  final String sessionId;
  final int completedSeconds;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double? rating;
  final String? notes;

  const MeditationProgress({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.completedSeconds,
    this.isCompleted = false,
    required this.startedAt,
    this.completedAt,
    this.rating,
    this.notes,
  });

  MeditationProgress copyWith({
    String? id,
    String? userId,
    String? sessionId,
    int? completedSeconds,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    double? rating,
    String? notes,
  }) {
    return MeditationProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      completedSeconds: completedSeconds ?? this.completedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'completedSeconds': completedSeconds,
      'isCompleted': isCompleted,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }

  factory MeditationProgress.fromJson(Map<String, dynamic> json) {
    return MeditationProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      completedSeconds: json['completedSeconds'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      rating: json['rating'] as double?,
      notes: json['notes'] as String?,
    );
  }
}