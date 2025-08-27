import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../models/meditation_session_simple.dart';
import '../../providers/meditation_providers.dart';
import '../../providers/auth_providers.dart';

class MeditationPlayerScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const MeditationPlayerScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends ConsumerState<MeditationPlayerScreen> {
  bool _isSessionStarted = false;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    // Load the session when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSession();
    });
  }

  void _loadSession() async {
    final sessionAsync = ref.read(meditationSessionProvider(widget.sessionId));
    sessionAsync.when(
      data: (session) {
        if (session != null) {
          ref.read(meditationPlayerProvider.notifier).setSession(session);
        }
      },
      loading: () {},
      error: (error, stack) {
        // Handle error if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(meditationSessionProvider(widget.sessionId));
    final playerState = ref.watch(meditationPlayerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareSession(),
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('Session not found'),
            );
          }
          return _buildPlayerContent(session, playerState);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading session: $error'),
        ),
      ),
    );
  }

  Widget _buildPlayerContent(MeditationSession session, MeditationPlayerState playerState) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSessionInfo(session),
                    const SizedBox(height: 32),
                    _buildSessionImage(session),
                    const SizedBox(height: 32),
                    _buildProgressIndicator(playerState),
                    const SizedBox(height: 24),
                    _buildTimeDisplay(playerState),
                    const SizedBox(height: 32),
                    _buildPlayerControls(session, playerState),
                    const SizedBox(height: 24),
                    _buildVolumeControl(playerState),
                  ],
                ),
              ),
            ),
            if (playerState.playerState == MediaPlayerState.completed)
              _buildCompletionActions(session),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(MeditationSession session) {
    return Column(
      children: [
        Text(
          session.title,
          style: AppTypography.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          session.instructorName ?? 'Guided Meditation',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.neutralGray600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${session.durationMinutes} minutes \u2022 ${_getThemeDisplayName(session.theme)}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutralGray500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSessionImage(MeditationSession session) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getThemeColor(session.theme).withValues(alpha: 0.3),
            _getThemeColor(session.theme).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: _getThemeColor(session.theme).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        _getThemeIcon(session.theme),
        size: 80,
        color: _getThemeColor(session.theme),
      ),
    );
  }

  Widget _buildProgressIndicator(MeditationPlayerState playerState) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: playerState.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              // In a real implementation, this would seek to the position
              final newPosition = Duration(
                milliseconds: (value * playerState.totalDuration.inMilliseconds).round(),
              );
              ref.read(meditationPlayerProvider.notifier).updatePosition(newPosition);
            },
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.neutralGray200,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(MeditationPlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          playerState.formattedPosition,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutralGray600,
          ),
        ),
        Text(
          playerState.formattedDuration,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutralGray600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(MeditationSession session, MeditationPlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10 seconds
        IconButton(
          onPressed: () => _rewind10Seconds(playerState),
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
        ),
        
        const SizedBox(width: 24),
        
        // Main play/pause button
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _togglePlayPause(playerState),
            icon: Icon(
              _getPlayPauseIcon(playerState.playerState),
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Forward 10 seconds
        IconButton(
          onPressed: () => _forward10Seconds(playerState),
          icon: const Icon(Icons.forward_10),
          iconSize: 32,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(MeditationPlayerState playerState) {
    return Row(
      children: [
        const Icon(
          Icons.volume_down,
          color: AppColors.neutralGray500,
        ),
        Expanded(
          child: Slider(
            value: playerState.volume,
            onChanged: (value) {
              // In a real implementation, this would control audio volume
            },
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.neutralGray200,
          ),
        ),
        const Icon(
          Icons.volume_up,
          color: AppColors.neutralGray500,
        ),
      ],
    );
  }

  Widget _buildCompletionActions(MeditationSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Meditation Complete! 🧘‍♀️',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'How was your session?',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1.0),
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: AppColors.accent,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _restartSession(),
                    child: const Text('Restart'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _completeSession(session),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlayPauseIcon(MediaPlayerState state) {
    switch (state) {
      case MediaPlayerState.playing:
        return Icons.pause;
      case MediaPlayerState.loading:
        return Icons.hourglass_empty;
      case MediaPlayerState.completed:
        return Icons.replay;
      default:
        return Icons.play_arrow;
    }
  }

  void _togglePlayPause(MeditationPlayerState playerState) {
    final controller = ref.read(meditationPlayerProvider.notifier);
    
    if (!_isSessionStarted) {
      _isSessionStarted = true;
      controller.play();
      _startMockProgress(playerState);
    } else if (playerState.isPlaying) {
      controller.pause();
    } else if (playerState.playerState == MediaPlayerState.completed) {
      _restartSession();
    } else {
      controller.play();
      _startMockProgress(playerState);
    }
  }

  void _rewind10Seconds(MeditationPlayerState playerState) {
    final newPosition = playerState.currentPosition - const Duration(seconds: 10);
    final clampedPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
    ref.read(meditationPlayerProvider.notifier).updatePosition(clampedPosition);
  }

  void _forward10Seconds(MeditationPlayerState playerState) {
    final newPosition = playerState.currentPosition + const Duration(seconds: 10);
    final clampedPosition = newPosition > playerState.totalDuration 
        ? playerState.totalDuration 
        : newPosition;
    ref.read(meditationPlayerProvider.notifier).updatePosition(clampedPosition);
  }

  void _restartSession() {
    final controller = ref.read(meditationPlayerProvider.notifier);
    controller.stop();
    controller.updatePosition(Duration.zero);
    _isSessionStarted = false;
    setState(() => _rating = 0.0);
  }

  void _completeSession(MeditationSession session) async {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid ?? 'guest';
    
    // Save progress
    final repository = ref.read(meditationRepositoryProvider);
    await repository.markSessionCompleted(
      userId, 
      session.id, 
      Duration(seconds: session.durationSeconds),
      _rating > 0 ? _rating : null,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meditation session completed!'),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.pop();
    }
  }

  void _shareSession() {
    // In a real implementation, this would share the session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _startMockProgress(MeditationPlayerState playerState) {
    // Mock audio progress - in a real app, this would be handled by the audio player
    if (playerState.isPlaying && playerState.currentPosition < playerState.totalDuration) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && ref.read(meditationPlayerProvider).isPlaying) {
          final newPosition = playerState.currentPosition + const Duration(seconds: 1);
          if (newPosition >= playerState.totalDuration) {
            ref.read(meditationPlayerProvider.notifier).complete();
          } else {
            ref.read(meditationPlayerProvider.notifier).updatePosition(newPosition);
            _startMockProgress(ref.read(meditationPlayerProvider));
          }
        }
      });
    }
  }

  String _getThemeDisplayName(MeditationTheme theme) {
    switch (theme) {
      case MeditationTheme.stress:
        return 'Stress Relief';
      case MeditationTheme.focus:
        return 'Focus';
      case MeditationTheme.sleep:
        return 'Sleep';
      case MeditationTheme.mindfulness:
        return 'Mindfulness';
      case MeditationTheme.anxiety:
        return 'Anxiety';
      case MeditationTheme.energy:
        return 'Energy';
    }
  }

  IconData _getThemeIcon(MeditationTheme theme) {
    switch (theme) {
      case MeditationTheme.stress:
        return Icons.spa;
      case MeditationTheme.focus:
        return Icons.center_focus_strong;
      case MeditationTheme.sleep:
        return Icons.bedtime;
      case MeditationTheme.mindfulness:
        return Icons.psychology;
      case MeditationTheme.anxiety:
        return Icons.healing;
      case MeditationTheme.energy:
        return Icons.bolt;
    }
  }

  Color _getThemeColor(MeditationTheme theme) {
    switch (theme) {
      case MeditationTheme.stress:
        return AppColors.secondaryGreen;
      case MeditationTheme.focus:
        return AppColors.primaryBlue;
      case MeditationTheme.sleep:
        return Colors.indigo;
      case MeditationTheme.mindfulness:
        return Colors.purple;
      case MeditationTheme.anxiety:
        return Colors.teal;
      case MeditationTheme.energy:
        return Colors.orange;
    }
  }
}