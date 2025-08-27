import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String appStateBox = 'app_state';
  static const String userDataBox = 'user_data';
  static const String moodEntriesBox = 'mood_entries';
  static const String journalEntriesBox = 'journal_entries';
  static const String settingsBox = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Open simple boxes for basic data storage
    await Future.wait([
      Hive.openBox<dynamic>(appStateBox),
      Hive.openBox<dynamic>(userDataBox),
      Hive.openBox<dynamic>(moodEntriesBox),
      Hive.openBox<dynamic>(journalEntriesBox),
      Hive.openBox<dynamic>(settingsBox),
    ]);
  }

  // App State Methods
  static Box<dynamic> get _appStateBox => Hive.box<dynamic>(appStateBox);

  static Future<void> saveAppState(String key, dynamic value) async {
    await _appStateBox.put(key, value);
  }

  static T? getAppState<T>(String key) {
    return _appStateBox.get(key) as T?;
  }

  // User Data Methods
  static Box<dynamic> get _userDataBox => Hive.box<dynamic>(userDataBox);

  static Future<void> saveUserData(String key, dynamic value) async {
    await _userDataBox.put(key, value);
  }

  static T? getUserData<T>(String key) {
    return _userDataBox.get(key) as T?;
  }

  // Mood Entries Methods
  static Box<dynamic> get _moodEntriesBox => Hive.box<dynamic>(moodEntriesBox);

  static Future<void> saveMoodEntry(String id, Map<String, dynamic> entry) async {
    await _moodEntriesBox.put(id, entry);
  }

  static Map<String, dynamic>? getMoodEntry(String id) {
    return _moodEntriesBox.get(id) as Map<String, dynamic>?;
  }

  static List<Map<String, dynamic>> getAllMoodEntries() {
    return _moodEntriesBox.values
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> deleteMoodEntry(String id) async {
    await _moodEntriesBox.delete(id);
  }

  // Journal Entries Methods
  static Box<dynamic> get _journalEntriesBox => Hive.box<dynamic>(journalEntriesBox);

  static Future<void> saveJournalEntry(String id, Map<String, dynamic> entry) async {
    await _journalEntriesBox.put(id, entry);
  }

  static Map<String, dynamic>? getJournalEntry(String id) {
    return _journalEntriesBox.get(id) as Map<String, dynamic>?;
  }

  static List<Map<String, dynamic>> getAllJournalEntries() {
    return _journalEntriesBox.values
        .cast<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> deleteJournalEntry(String id) async {
    await _journalEntriesBox.delete(id);
  }

  // Settings Methods
  static Box<dynamic> get _settingsBox => Hive.box<dynamic>(settingsBox);

  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Future.wait([
      _appStateBox.clear(),
      _userDataBox.clear(),
      _moodEntriesBox.clear(),
      _journalEntriesBox.clear(),
      _settingsBox.clear(),
    ]);
  }

  // Clear user specific data
  static Future<void> clearUserData(String userId) async {
    // Remove user-specific entries
    final moodEntriesToRemove = <String>[];
    final journalEntriesToRemove = <String>[];

    // Find entries for this user
    for (final entry in _moodEntriesBox.toMap().entries) {
      final moodData = entry.value as Map<String, dynamic>?;
      if (moodData?['userId'] == userId) {
        moodEntriesToRemove.add(entry.key);
      }
    }

    for (final entry in _journalEntriesBox.toMap().entries) {
      final journalData = entry.value as Map<String, dynamic>?;
      if (journalData?['userId'] == userId) {
        journalEntriesToRemove.add(entry.key);
      }
    }

    // Remove the entries
    for (final id in moodEntriesToRemove) {
      await _moodEntriesBox.delete(id);
    }

    for (final id in journalEntriesToRemove) {
      await _journalEntriesBox.delete(id);
    }

    // Remove user data
    await _userDataBox.delete(userId);
  }

  // Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}