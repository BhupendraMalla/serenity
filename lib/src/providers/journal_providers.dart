import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry_simple.dart';
import '../services/journal_repository.dart';

// Journal repository provider
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return SimpleJournalRepositoryImpl();
});

// User journal entries provider
final journalEntriesProvider = FutureProvider.family<List<JournalEntry>, String>((ref, userId) {
  final repository = ref.read(journalRepositoryProvider);
  return repository.getEntriesByUserId(userId);
});

// Journal entry by ID provider
final journalEntryProvider = FutureProvider.family<JournalEntry?, String>((ref, entryId) {
  final repository = ref.read(journalRepositoryProvider);
  return repository.getEntryById(entryId);
});

// Journal prompts provider
final journalPromptsProvider = FutureProvider<List<JournalPrompt>>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return repository.getPrompts();
});

// Daily journal prompt provider
final dailyJournalPromptProvider = FutureProvider<JournalPrompt?>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return repository.getDailyPrompt();
});

// Journal entry controller for creating/editing entries
class JournalEntryController extends StateNotifier<JournalEntryState> {
  final JournalRepository _repository;

  JournalEntryController(this._repository) : super(const JournalEntryState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setContent(String content) {
    state = state.copyWith(content: content);
  }

  void addTag(String tag) {
    if (!state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  void removeTag(String tag) {
    state = state.copyWith(tags: state.tags.where((t) => t != tag).toList());
  }

  void setMoodEntryId(String? moodEntryId) {
    state = state.copyWith(moodEntryId: moodEntryId);
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }

  void loadEntry(JournalEntry entry) {
    state = JournalEntryState(
      entryId: entry.id,
      title: entry.title,
      content: entry.content,
      tags: entry.tags,
      moodEntryId: entry.moodEntryId,
      isFavorite: entry.isFavorite,
      isExisting: true,
    );
  }

  void reset() {
    state = const JournalEntryState();
  }

  Future<bool> saveEntry(String userId) async {
    if (!state.isValid) return false;

    try {
      state = state.copyWith(isSaving: true);

      final now = DateTime.now();
      final entry = JournalEntry(
        id: state.entryId ?? 'journal_${now.millisecondsSinceEpoch}',
        userId: userId,
        title: state.title,
        content: state.content,
        tags: state.tags,
        moodEntryId: state.moodEntryId,
        createdAt: state.isExisting ? state.createdAt ?? now : now,
        updatedAt: now,
        isFavorite: state.isFavorite,
      );

      await _repository.saveEntry(entry);
      state = state.copyWith(isSaving: false, isExisting: true, entryId: entry.id);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEntry() async {
    if (state.entryId == null) return false;

    try {
      await _repository.deleteEntry(state.entryId!);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

class JournalEntryState {
  final String? entryId;
  final String title;
  final String content;
  final List<String> tags;
  final String? moodEntryId;
  final bool isFavorite;
  final bool isExisting;
  final bool isSaving;
  final String? error;
  final DateTime? createdAt;

  const JournalEntryState({
    this.entryId,
    this.title = '',
    this.content = '',
    this.tags = const [],
    this.moodEntryId,
    this.isFavorite = false,
    this.isExisting = false,
    this.isSaving = false,
    this.error,
    this.createdAt,
  });

  JournalEntryState copyWith({
    String? entryId,
    String? title,
    String? content,
    List<String>? tags,
    String? moodEntryId,
    bool? isFavorite,
    bool? isExisting,
    bool? isSaving,
    String? error,
    DateTime? createdAt,
  }) {
    return JournalEntryState(
      entryId: entryId ?? this.entryId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      moodEntryId: moodEntryId ?? this.moodEntryId,
      isFavorite: isFavorite ?? this.isFavorite,
      isExisting: isExisting ?? this.isExisting,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isValid => title.trim().isNotEmpty && content.trim().isNotEmpty;
  bool get hasChanges => title.isNotEmpty || content.isNotEmpty || tags.isNotEmpty;
}

// Journal entry controller provider
final journalEntryControllerProvider = StateNotifierProvider<JournalEntryController, JournalEntryState>((ref) {
  final repository = ref.read(journalRepositoryProvider);
  return JournalEntryController(repository);
});

// Search and filter providers
final journalSearchQueryProvider = StateProvider<String>((ref) => '');
final journalFilterTypeProvider = StateProvider<JournalEntryType?>((ref) => null);
final journalSortModeProvider = StateProvider<JournalSortMode>((ref) => JournalSortMode.newest);

enum JournalSortMode {
  newest,
  oldest,
  alphabetical,
  favorites,
}

// Filtered journal entries provider
final filteredJournalEntriesProvider = FutureProvider.family<List<JournalEntry>, String>((ref, userId) async {
  final allEntries = await ref.watch(journalEntriesProvider(userId).future);
  final searchQuery = ref.watch(journalSearchQueryProvider).toLowerCase();
  final filterType = ref.watch(journalFilterTypeProvider);
  final sortMode = ref.watch(journalSortModeProvider);

  var filtered = allEntries;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((entry) =>
      entry.title.toLowerCase().contains(searchQuery) ||
      entry.content.toLowerCase().contains(searchQuery) ||
      entry.tags.any((tag) => tag.toLowerCase().contains(searchQuery))
    ).toList();
  }

  // Apply type filter
  if (filterType != null) {
    filtered = filtered.where((entry) => entry.type == filterType).toList();
  }

  // Apply sorting
  switch (sortMode) {
    case JournalSortMode.newest:
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case JournalSortMode.oldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case JournalSortMode.alphabetical:
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
    case JournalSortMode.favorites:
      filtered.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      break;
  }

  return filtered;
});

// Stats providers
final journalStatsProvider = FutureProvider.family<JournalStats, String>((ref, userId) async {
  final entries = await ref.watch(journalEntriesProvider(userId).future);
  
  final totalEntries = entries.length;
  final favoriteEntries = entries.where((e) => e.isFavorite).length;
  final thisWeek = entries.where((e) => 
    DateTime.now().difference(e.createdAt).inDays <= 7
  ).length;
  final thisMonth = entries.where((e) => 
    DateTime.now().difference(e.createdAt).inDays <= 30
  ).length;

  final totalWords = entries.fold<int>(0, (sum, entry) => 
    sum + entry.content.split(' ').length
  );

  final averageWords = totalEntries > 0 ? totalWords / totalEntries : 0.0;

  return JournalStats(
    totalEntries: totalEntries,
    favoriteEntries: favoriteEntries,
    entriesThisWeek: thisWeek,
    entriesThisMonth: thisMonth,
    totalWords: totalWords,
    averageWordsPerEntry: averageWords,
  );
});

class JournalStats {
  final int totalEntries;
  final int favoriteEntries;
  final int entriesThisWeek;
  final int entriesThisMonth;
  final int totalWords;
  final double averageWordsPerEntry;

  const JournalStats({
    required this.totalEntries,
    required this.favoriteEntries,
    required this.entriesThisWeek,
    required this.entriesThisMonth,
    required this.totalWords,
    required this.averageWordsPerEntry,
  });
}