import 'package:flutter/material.dart';

enum WellnessGoal {
  stress('Stress Relief', 'Reduce daily stress and anxiety'),
  sleep('Better Sleep', 'Improve sleep quality and routine'),
  focus('Enhanced Focus', 'Increase concentration and mindfulness'),
  anxiety('Anxiety Management', 'Cope with anxiety and worry');

  const WellnessGoal(this.label, this.description);

  final String label;
  final String description;
}

class UserPreferences {
  final List<String> favoriteThemes;
  final int preferredSessionDuration;
  final bool notificationsEnabled;
  final TimeOfDay reminderTime;
  final ThemeMode themeMode;
  final WellnessGoal primaryGoal;
  final bool soundEnabled;
  final double volume;

  const UserPreferences({
    this.favoriteThemes = const ['mindfulness'],
    this.preferredSessionDuration = 10,
    this.notificationsEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.themeMode = ThemeMode.system,
    this.primaryGoal = WellnessGoal.stress,
    this.soundEnabled = true,
    this.volume = 0.7,
  });

  UserPreferences copyWith({
    List<String>? favoriteThemes,
    int? preferredSessionDuration,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    ThemeMode? themeMode,
    WellnessGoal? primaryGoal,
    bool? soundEnabled,
    double? volume,
  }) {
    return UserPreferences(
      favoriteThemes: favoriteThemes ?? this.favoriteThemes,
      preferredSessionDuration: preferredSessionDuration ?? this.preferredSessionDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      themeMode: themeMode ?? this.themeMode,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      volume: volume ?? this.volume,
    );
  }
}

class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final UserPreferences preferences;
  final bool isPremium;

  const User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.preferences,
    this.isPremium = false,
  });

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    UserPreferences? preferences,
    bool? isPremium,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
