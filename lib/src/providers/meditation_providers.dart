import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meditation_session_simple.dart';
import '../services/meditation_repository.dart';

// Meditation repository provider
final meditationRepositoryProvider = Provider<MeditationRepository>((ref) {
  return SimpleMeditationRepositoryImpl();
});

// All meditation sessions provider
final meditationSessionsProvider = FutureProvider<List<MeditationSession>>((ref) {
  final repository = ref.read(meditationRepositoryProvider);
  return repository.getAllSessions();
});

// Meditation sessions by theme provider
final meditationSessionsByThemeProvider = FutureProvider.family<List<MeditationSession>, MeditationTheme>((ref, theme) {
  final repository = ref.read(meditationRepositoryProvider);
  return repository.getSessionsByTheme(theme);
});

// Featured meditation sessions provider
final featuredMeditationSessionsProvider = FutureProvider<List<MeditationSession>>((ref) {
  final repository = ref.read(meditationRepositoryProvider);
  return repository.getFeaturedSessions();
});

// Meditation session by ID provider
final meditationSessionProvider = FutureProvider.family<MeditationSession?, String>((ref, sessionId) {
  final repository = ref.read(meditationRepositoryProvider);
  return repository.getSessionById(sessionId);
});

// User meditation progress provider
final meditationProgressProvider = FutureProvider.family<List<MeditationProgress>, String>((ref, userId) {
  final repository = ref.read(meditationRepositoryProvider);
  return repository.getUserProgress(userId);
});

// Meditation player state
enum MediaPlayerState {
  stopped,
  playing,
  paused,
  loading,
  completed,
}

class MeditationPlayerController extends StateNotifier<MeditationPlayerState> {
  MeditationPlayerController() : super(const MeditationPlayerState());

  void play() {
    state = state.copyWith(
      playerState: MediaPlayerState.playing,
      isPlaying: true,
    );
  }

  void pause() {
    state = state.copyWith(
      playerState: MediaPlayerState.paused,
      isPlaying: false,
    );
  }

  void stop() {
    state = state.copyWith(
      playerState: MediaPlayerState.stopped,
      isPlaying: false,
      currentPosition: Duration.zero,
    );
  }

  void updatePosition(Duration position) {
    state = state.copyWith(currentPosition: position);
  }

  void updateDuration(Duration duration) {
    state = state.copyWith(totalDuration: duration);
  }

  void complete() {
    state = state.copyWith(
      playerState: MediaPlayerState.completed,
      isPlaying: false,
      currentPosition: state.totalDuration,
    );
  }

  void setLoading() {
    state = state.copyWith(playerState: MediaPlayerState.loading);
  }

  void setSession(MeditationSession session) {
    state = state.copyWith(
      currentSession: session,
      totalDuration: Duration(seconds: session.durationSeconds),
    );
  }
}

class MeditationPlayerState {
  final MeditationSession? currentSession;
  final MediaPlayerState playerState;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final double volume;

  const MeditationPlayerState({
    this.currentSession,
    this.playerState = MediaPlayerState.stopped,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.volume = 1.0,
  });

  MeditationPlayerState copyWith({
    MeditationSession? currentSession,
    MediaPlayerState? playerState,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    double? volume,
  }) {
    return MeditationPlayerState(
      currentSession: currentSession ?? this.currentSession,
      playerState: playerState ?? this.playerState,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      volume: volume ?? this.volume,
    );
  }

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  String get formattedPosition {
    return _formatDuration(currentPosition);
  }

  String get formattedDuration {
    return _formatDuration(totalDuration);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Meditation player provider
final meditationPlayerProvider = StateNotifierProvider<MeditationPlayerController, MeditationPlayerState>((ref) {
  return MeditationPlayerController();
});

// Selected meditation theme filter provider
final selectedMeditationThemeProvider = StateProvider<MeditationTheme?>((ref) => null);

// Search query provider
final meditationSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered meditation sessions provider
final filteredMeditationSessionsProvider = FutureProvider<List<MeditationSession>>((ref) async {
  final allSessions = await ref.watch(meditationSessionsProvider.future);
  final selectedTheme = ref.watch(selectedMeditationThemeProvider);
  final searchQuery = ref.watch(meditationSearchQueryProvider).toLowerCase();

  var filtered = allSessions;

  // Filter by theme
  if (selectedTheme != null) {
    filtered = filtered.where((session) => session.theme == selectedTheme).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((session) => 
      session.title.toLowerCase().contains(searchQuery) ||
      session.description?.toLowerCase().contains(searchQuery) == true ||
      session.tags.any((tag) => tag.toLowerCase().contains(searchQuery))
    ).toList();
  }

  return filtered;
});