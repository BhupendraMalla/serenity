import 'dart:async';
import '../models/meditation_session_simple.dart';

abstract class MeditationRepository {
  Future<List<MeditationSession>> getAllSessions();
  Future<List<MeditationSession>> getSessionsByTheme(MeditationTheme theme);
  Future<List<MeditationSession>> getFeaturedSessions();
  Future<MeditationSession?> getSessionById(String sessionId);
  Future<List<MeditationProgress>> getUserProgress(String userId);
  Future<void> saveProgress(MeditationProgress progress);
  Future<void> markSessionCompleted(String userId, String sessionId, Duration completedDuration, double? rating);
}

class SimpleMeditationRepositoryImpl implements MeditationRepository {
  final List<MeditationSession> _sessions = _generateSampleSessions();
  final List<MeditationProgress> _progressRecords = [];

  static List<MeditationSession> _generateSampleSessions() {
    final now = DateTime.now();
    
    return [
      // Stress Relief Sessions
      MeditationSession(
        id: 'stress_01',
        title: 'Deep Breathing for Stress',
        theme: MeditationTheme.stress,
        durationSeconds: 300, // 5 minutes
        audioUrl: 'assets/audio/stress_breathing.mp3',
        description: 'A calming breathing exercise to help release stress and tension from your day.',
        tags: ['breathing', 'relaxation', 'stress'],
        isFeatured: true,
        instructorName: 'Sarah Chen',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      MeditationSession(
        id: 'stress_02',
        title: 'Progressive Muscle Relaxation',
        theme: MeditationTheme.stress,
        durationSeconds: 900, // 15 minutes
        audioUrl: 'assets/audio/muscle_relaxation.mp3',
        description: 'Systematically relax each muscle group to release physical tension.',
        tags: ['relaxation', 'body', 'tension'],
        instructorName: 'Dr. Michael Torres',
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      
      // Focus Sessions
      MeditationSession(
        id: 'focus_01',
        title: 'Concentration Meditation',
        theme: MeditationTheme.focus,
        durationSeconds: 600, // 10 minutes
        audioUrl: 'assets/audio/concentration.mp3',
        description: 'Improve your focus and concentration with this mindful attention practice.',
        tags: ['focus', 'concentration', 'productivity'],
        isFeatured: true,
        instructorName: 'Emma Watson',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      MeditationSession(
        id: 'focus_02',
        title: 'Work Break Mindfulness',
        theme: MeditationTheme.focus,
        durationSeconds: 180, // 3 minutes
        audioUrl: 'assets/audio/work_break.mp3',
        description: 'A quick meditation to refresh your mind during work breaks.',
        tags: ['work', 'productivity', 'short'],
        instructorName: 'James Rodriguez',
        createdAt: now.subtract(const Duration(days: 18)),
      ),

      // Sleep Sessions
      MeditationSession(
        id: 'sleep_01',
        title: 'Bedtime Body Scan',
        theme: MeditationTheme.sleep,
        durationSeconds: 1200, // 20 minutes
        audioUrl: 'assets/audio/bedtime_scan.mp3',
        description: 'A gentle body scan meditation to prepare your mind and body for restful sleep.',
        tags: ['sleep', 'body scan', 'bedtime'],
        isFeatured: true,
        instructorName: 'Luna Night',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      MeditationSession(
        id: 'sleep_02',
        title: 'Sleep Stories',
        theme: MeditationTheme.sleep,
        durationSeconds: 1800, // 30 minutes
        audioUrl: 'assets/audio/sleep_story.mp3',
        description: 'Drift off to peaceful sleep with calming bedtime stories.',
        tags: ['sleep', 'stories', 'relaxation'],
        instructorName: 'Robert Dream',
        createdAt: now.subtract(const Duration(days: 12)),
      ),

      // Mindfulness Sessions
      MeditationSession(
        id: 'mindfulness_01',
        title: 'Present Moment Awareness',
        theme: MeditationTheme.mindfulness,
        durationSeconds: 480, // 8 minutes
        audioUrl: 'assets/audio/present_moment.mp3',
        description: 'Cultivate awareness of the present moment with this mindfulness practice.',
        tags: ['mindfulness', 'present', 'awareness'],
        isFeatured: true,
        instructorName: 'Zen Master Li',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      MeditationSession(
        id: 'mindfulness_02',
        title: 'Mindful Walking',
        theme: MeditationTheme.mindfulness,
        durationSeconds: 360, // 6 minutes
        audioUrl: 'assets/audio/mindful_walking.mp3',
        description: 'Practice mindfulness while walking, perfect for outdoor meditation.',
        tags: ['mindfulness', 'walking', 'outdoor'],
        instructorName: 'Nature Guide Anna',
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      // Anxiety Sessions
      MeditationSession(
        id: 'anxiety_01',
        title: 'Anxiety Relief Breathing',
        theme: MeditationTheme.anxiety,
        durationSeconds: 420, // 7 minutes
        audioUrl: 'assets/audio/anxiety_breathing.mp3',
        description: 'Calm anxiety with specific breathing techniques designed to soothe the nervous system.',
        tags: ['anxiety', 'breathing', 'calm'],
        isFeatured: true,
        instructorName: 'Dr. Calm Heart',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      MeditationSession(
        id: 'anxiety_02',
        title: 'Grounding Meditation',
        theme: MeditationTheme.anxiety,
        durationSeconds: 540, // 9 minutes
        audioUrl: 'assets/audio/grounding.mp3',
        description: 'Ground yourself in the present moment and find stability during anxious times.',
        tags: ['anxiety', 'grounding', 'stability'],
        instructorName: 'Peaceful Mind',
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Energy Sessions
      MeditationSession(
        id: 'energy_01',
        title: 'Morning Energy Boost',
        theme: MeditationTheme.energy,
        durationSeconds: 300, // 5 minutes
        audioUrl: 'assets/audio/morning_energy.mp3',
        description: 'Start your day with renewed energy and positive intentions.',
        tags: ['energy', 'morning', 'motivation'],
        isFeatured: true,
        instructorName: 'Sunrise Guide',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MeditationSession(
        id: 'energy_02',
        title: 'Afternoon Revival',
        theme: MeditationTheme.energy,
        durationSeconds: 240, // 4 minutes
        audioUrl: 'assets/audio/afternoon_revival.mp3',
        description: 'Revitalize your energy levels for the second half of your day.',
        tags: ['energy', 'afternoon', 'revival'],
        instructorName: 'Energy Master',
        createdAt: now,
      ),
    ];
  }

  @override
  Future<List<MeditationSession>> getAllSessions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_sessions);
  }

  @override
  Future<List<MeditationSession>> getSessionsByTheme(MeditationTheme theme) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions.where((session) => session.theme == theme).toList();
  }

  @override
  Future<List<MeditationSession>> getFeaturedSessions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions.where((session) => session.isFeatured).toList();
  }

  @override
  Future<MeditationSession?> getSessionById(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MeditationProgress>> getUserProgress(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _progressRecords.where((progress) => progress.userId == userId).toList();
  }

  @override
  Future<void> saveProgress(MeditationProgress progress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Remove any existing progress for the same session
    _progressRecords.removeWhere((p) => 
        p.userId == progress.userId && p.sessionId == progress.sessionId);
    
    _progressRecords.add(progress);
  }

  @override
  Future<void> markSessionCompleted(String userId, String sessionId, Duration completedDuration, double? rating) async {
    final progress = MeditationProgress(
      id: '${userId}_${sessionId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      sessionId: sessionId,
      completedSeconds: completedDuration.inSeconds,
      isCompleted: true,
      startedAt: DateTime.now().subtract(completedDuration),
      completedAt: DateTime.now(),
      rating: rating,
    );

    await saveProgress(progress);
  }
}