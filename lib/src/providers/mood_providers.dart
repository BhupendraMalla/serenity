import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry_simple.dart';
import '../services/mood_repository.dart';
import 'package:uuid/uuid.dart';

// Current user provider (this would be set by authentication)
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// Repository provider
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return SimpleMoodRepositoryImpl();
});

// Mood entries stream provider
final moodEntriesProvider = StreamProvider.family<List<MoodEntry>, String>((ref, userId) {
  final repository = ref.read(moodRepositoryProvider);
  return repository.watchMoodEntries(userId);
});

// Today's mood entry provider
final todayMoodEntryProvider = FutureProvider.family<MoodEntry?, String>((ref, userId) {
  final repository = ref.read(moodRepositoryProvider);
  return repository.getTodayMoodEntry(userId);
});

// Mood statistics provider
final moodStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  final repository = ref.read(moodRepositoryProvider);
  return repository.getMoodStats(userId);
});

// Mood streak provider
final moodStreakProvider = FutureProvider.family<int, String>((ref, userId) {
  final repository = ref.read(moodRepositoryProvider);
  return repository.getMoodStreak(userId);
});

// Mood controller for actions
final moodControllerProvider = Provider<MoodController>((ref) {
  return MoodController(ref.read(moodRepositoryProvider));
});

class MoodController {
  final MoodRepository _repository;
  final _uuid = const Uuid();

  MoodController(this._repository);

  Future<void> addMoodEntry({
    required String userId,
    required MoodLevel mood,
    required List<String> tags,
    String? note,
  }) async {
    final entry = MoodEntry(
      id: _uuid.v4(),
      userId: userId,
      mood: mood,
      tags: tags,
      note: note,
      createdAt: DateTime.now(),
    );

    await _repository.saveMoodEntry(entry);
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    await _repository.saveMoodEntry(entry);
  }

  Future<void> deleteMoodEntry(String id) async {
    await _repository.deleteMoodEntry(id);
  }
}

// Mood tags provider (predefined and user-generated)
final moodTagsProvider = Provider<List<String>>((ref) {
  return [
    'happy',
    'sad',
    'anxious',
    'calm',
    'excited',
    'tired',
    'energetic',
    'stressed',
    'peaceful',
    'overwhelmed',
    'grateful',
    'frustrated',
    'motivated',
    'lonely',
    'confident',
    'worried',
    'content',
    'angry',
    'hopeful',
    'confused',
  ];
});

// Selected mood tags state
final selectedMoodTagsProvider = StateProvider<List<String>>((ref) => []);

// Current mood selection state
final selectedMoodProvider = StateProvider<MoodLevel?>((ref) => null);

// Mood note state
final moodNoteProvider = StateProvider<String>((ref) => '');

// Mood form validation
final isMoodFormValidProvider = Provider<bool>((ref) {
  final selectedMood = ref.watch(selectedMoodProvider);
  return selectedMood != null;
});

// Reset mood form
final resetMoodFormProvider = Provider<VoidCallback>((ref) {
  return () {
    ref.read(selectedMoodProvider.notifier).state = null;
    ref.read(selectedMoodTagsProvider.notifier).state = [];
    ref.read(moodNoteProvider.notifier).state = '';
  };
});