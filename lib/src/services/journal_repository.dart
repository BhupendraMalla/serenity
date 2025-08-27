import 'dart:async';
import '../models/journal_entry_simple.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getEntriesByUserId(String userId);
  Future<JournalEntry?> getEntryById(String entryId);
  Future<void> saveEntry(JournalEntry entry);
  Future<void> deleteEntry(String entryId);
  Future<List<JournalPrompt>> getPrompts();
  Future<JournalPrompt?> getDailyPrompt();
}

class SimpleJournalRepositoryImpl implements JournalRepository {
  final List<JournalEntry> _entries = [];
  final List<JournalPrompt> _prompts = _generateSamplePrompts();

  static List<JournalPrompt> _generateSamplePrompts() {
    return [
      const JournalPrompt(
        id: 'prompt_1',
        title: 'Gratitude Reflection',
        prompt: 'What are three things you\'re grateful for today? How did they make you feel?',
        category: 'Gratitude',
        tags: ['gratitude', 'reflection', 'positivity'],
        isDaily: true,
      ),
      const JournalPrompt(
        id: 'prompt_2',
        title: 'Daily Achievements',
        prompt: 'What did you accomplish today, no matter how small? How does it feel to recognize these achievements?',
        category: 'Achievement',
        tags: ['achievement', 'success', 'self-recognition'],
        isDaily: true,
      ),
      const JournalPrompt(
        id: 'prompt_3',
        title: 'Emotional Check-in',
        prompt: 'How are you feeling right now? What emotions have you experienced today, and what might have triggered them?',
        category: 'Emotions',
        tags: ['emotions', 'awareness', 'mindfulness'],
        isDaily: true,
      ),
      const JournalPrompt(
        id: 'prompt_4',
        title: 'Learning and Growth',
        prompt: 'What did you learn about yourself today? How did you grow or change, even in small ways?',
        category: 'Growth',
        tags: ['learning', 'growth', 'self-discovery'],
      ),
      const JournalPrompt(
        id: 'prompt_5',
        title: 'Future Self',
        prompt: 'Write a letter to yourself one year from now. What do you want to tell your future self?',
        category: 'Future',
        tags: ['future', 'goals', 'aspirations'],
      ),
      const JournalPrompt(
        id: 'prompt_6',
        title: 'Stress and Challenges',
        prompt: 'What challenged you today? How did you handle it, and what would you do differently next time?',
        category: 'Challenges',
        tags: ['stress', 'challenges', 'problem-solving'],
      ),
      const JournalPrompt(
        id: 'prompt_7',
        title: 'Relationships',
        prompt: 'How did your interactions with others make you feel today? What relationships are you most grateful for?',
        category: 'Relationships',
        tags: ['relationships', 'connection', 'social'],
      ),
      const JournalPrompt(
        id: 'prompt_8',
        title: 'Mindful Moments',
        prompt: 'Describe a moment today when you felt truly present. What were you doing, and how did it feel?',
        category: 'Mindfulness',
        tags: ['mindfulness', 'presence', 'awareness'],
      ),
      const JournalPrompt(
        id: 'prompt_9',
        title: 'Creative Expression',
        prompt: 'If you could express your current feelings through art, music, or writing, what would you create?',
        category: 'Creativity',
        tags: ['creativity', 'expression', 'art'],
      ),
      const JournalPrompt(
        id: 'prompt_10',
        title: 'Self-Care Reflection',
        prompt: 'How did you take care of yourself today? What does self-care mean to you right now?',
        category: 'Self-Care',
        tags: ['self-care', 'wellness', 'health'],
      ),
    ];
  }

  @override
  Future<List<JournalEntry>> getEntriesByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _entries.where((entry) => entry.userId == userId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<JournalEntry?> getEntryById(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _entries.firstWhere((entry) => entry.id == entryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Remove existing entry if updating
    _entries.removeWhere((e) => e.id == entry.id);
    
    // Add the new/updated entry
    _entries.add(entry);
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _entries.removeWhere((entry) => entry.id == entryId);
  }

  @override
  Future<List<JournalPrompt>> getPrompts() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_prompts);
  }

  @override
  Future<JournalPrompt?> getDailyPrompt() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Get a daily prompt based on the current date
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final dailyPrompts = _prompts.where((p) => p.isDaily).toList();
    
    if (dailyPrompts.isEmpty) return null;
    
    return dailyPrompts[dayOfYear % dailyPrompts.length];
  }
}