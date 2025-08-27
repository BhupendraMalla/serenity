import 'dart:async';
import '../models/mood_entry_simple.dart';

abstract class MoodRepository {
  Future<void> saveMoodEntry(MoodEntry entry);
  Future<void> deleteMoodEntry(String id);
  Stream<List<MoodEntry>> watchMoodEntries(String userId);
  Future<List<MoodEntry>> getMoodEntries(String userId);
  Future<MoodEntry?> getTodayMoodEntry(String userId);
  Future<Map<String, dynamic>> getMoodStats(String userId);
  Future<int> getMoodStreak(String userId);
}

class SimpleMoodRepositoryImpl implements MoodRepository {
  final _moodController = StreamController<List<MoodEntry>>.broadcast();
  final List<MoodEntry> _entries = [];

  @override
  Future<void> saveMoodEntry(MoodEntry entry) async {
    // Remove existing entry for the same day if exists
    _entries.removeWhere((e) => 
        e.userId == entry.userId && 
        e.createdAt.day == entry.createdAt.day &&
        e.createdAt.month == entry.createdAt.month &&
        e.createdAt.year == entry.createdAt.year);
    
    _entries.add(entry);
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Update stream
    final userEntries = _entries.where((e) => e.userId == entry.userId).toList();
    _moodController.add(userEntries);
  }

  @override
  Future<void> deleteMoodEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _moodController.add(_entries);
  }

  @override
  Stream<List<MoodEntry>> watchMoodEntries(String userId) {
    // Emit initial data
    final initialEntries = _entries.where((e) => e.userId == userId).toList();
    _moodController.add(initialEntries);
    
    // Return filtered stream for this user
    return _moodController.stream.map((entries) => 
        entries.where((entry) => entry.userId == userId).toList());
  }

  @override
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    return _entries.where((e) => e.userId == userId).toList();
  }

  @override
  Future<MoodEntry?> getTodayMoodEntry(String userId) async {
    final today = DateTime.now();
    return _entries
        .where((entry) => 
            entry.userId == userId &&
            entry.createdAt.year == today.year &&
            entry.createdAt.month == today.month &&
            entry.createdAt.day == today.day)
        .firstOrNull;
  }

  @override
  Future<Map<String, dynamic>> getMoodStats(String userId) async {
    final entries = _entries.where((e) => e.userId == userId).toList();
    
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMood': 0.0,
        'moodDistribution': <MoodLevel, int>{},
        'weeklyAverage': 0.0,
        'monthlyAverage': 0.0,
      };
    }

    // Calculate basic stats
    final totalEntries = entries.length;
    final averageMood = entries.map((e) => e.mood.value).reduce((a, b) => a + b) / totalEntries;
    
    // Mood distribution
    final moodDistribution = <MoodLevel, int>{};
    for (final mood in MoodLevel.values) {
      moodDistribution[mood] = entries.where((e) => e.mood == mood).length;
    }

    // Weekly average (last 7 days)
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyEntries = entries.where((e) => e.createdAt.isAfter(oneWeekAgo)).toList();
    final weeklyAverage = weeklyEntries.isEmpty ? 0.0 : 
        weeklyEntries.map((e) => e.mood.value).reduce((a, b) => a + b) / weeklyEntries.length;

    // Monthly average (last 30 days)
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthlyEntries = entries.where((e) => e.createdAt.isAfter(oneMonthAgo)).toList();
    final monthlyAverage = monthlyEntries.isEmpty ? 0.0 :
        monthlyEntries.map((e) => e.mood.value).reduce((a, b) => a + b) / monthlyEntries.length;

    return {
      'totalEntries': totalEntries,
      'averageMood': averageMood,
      'moodDistribution': moodDistribution,
      'weeklyAverage': weeklyAverage,
      'monthlyAverage': monthlyAverage,
    };
  }

  @override
  Future<int> getMoodStreak(String userId) async {
    final entries = _entries.where((e) => e.userId == userId).toList();
    
    if (entries.isEmpty) return 0;

    // Sort entries by date (newest first)
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime? lastDate;

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      if (lastDate == null) {
        // First entry
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        if (entryDate.isAtSameMomentAs(todayDate) || 
            entryDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
          streak = 1;
          lastDate = entryDate;
        } else {
          // Gap found, no current streak
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        
        if (entryDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastDate = entryDate;
        } else {
          // Gap found, streak broken
          break;
        }
      }
    }

    return streak;
  }

  void dispose() {
    _moodController.close();
  }
}
