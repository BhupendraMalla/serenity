import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../models/meditation_session_simple.dart';
import '../../providers/meditation_providers.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            _buildThemeFilter(),
            const SizedBox(height: 24),
            _buildFeaturedSessions(),
            const SizedBox(height: 24),
            _buildAllSessions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.self_improvement,
                  size: 32,
                  color: AppColors.secondaryGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your Peace',
                        style: AppTypography.titleLarge,
                      ),
                      Text(
                        'Guided meditations for every moment',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutralGray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Take a few minutes to center yourself with our carefully curated meditation library. Choose from different themes based on what you need most today.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeFilter() {
    final selectedTheme = ref.watch(selectedMeditationThemeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by Theme',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildThemeChip('All', null, selectedTheme),
              const SizedBox(width: 8),
              ...MeditationTheme.values.map((theme) => 
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildThemeChip(_getThemeDisplayName(theme), theme, selectedTheme),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeChip(String label, MeditationTheme? theme, MeditationTheme? selectedTheme) {
    final isSelected = selectedTheme == theme;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(selectedMeditationThemeProvider.notifier).state = 
            selected ? theme : null;
      },
      backgroundColor: AppColors.neutralGray100,
      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      side: isSelected 
          ? const BorderSide(color: AppColors.primaryBlue)
          : BorderSide.none,
    );
  }

  Widget _buildFeaturedSessions() {
    final featuredSessionsAsync = ref.watch(featuredMeditationSessionsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.star,
              color: AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Featured Meditations',
              style: AppTypography.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        featuredSessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < sessions.length - 1 ? 16 : 0,
                    ),
                    child: _buildFeaturedSessionCard(session),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SizedBox(
            height: 200,
            child: Center(
              child: Text('Error loading featured sessions: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSessionCard(MeditationSession session) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToPlayer(session),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getThemeColor(session.theme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getThemeIcon(session.theme),
                      color: _getThemeColor(session.theme),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: AppTypography.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${session.durationMinutes} min • ${session.instructorName ?? 'Guided'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                session.description ?? '',
                style: AppTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getThemeDisplayName(session.theme),
                      style: AppTypography.labelSmall,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.play_circle_fill,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllSessions() {
    final filteredSessionsAsync = ref.watch(filteredMeditationSessionsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Meditations',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        filteredSessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.neutralGray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meditations found',
                          style: AppTypography.bodyLarge,
                        ),
                        Text(
                          'Try adjusting your filters',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.neutralGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: sessions.map((session) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSessionListTile(session),
                ),
              ).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading sessions: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionListTile(MeditationSession session) {
    return Card(
      child: ListTile(
        onTap: () => _navigateToPlayer(session),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getThemeColor(session.theme).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _getThemeIcon(session.theme),
            color: _getThemeColor(session.theme),
          ),
        ),
        title: Text(
          session.title,
          style: AppTypography.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${session.durationMinutes} min • ${session.instructorName ?? 'Guided'}',
              style: AppTypography.bodySmall,
            ),
            if (session.description?.isNotEmpty == true)
              Text(
                session.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutralGray600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (session.isFeatured)
              const Icon(
                Icons.star,
                color: AppColors.accent,
                size: 16,
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_circle_outline,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
        isThreeLine: session.description?.isNotEmpty == true,
      ),
    );
  }

  void _navigateToPlayer(MeditationSession session) {
    context.push('/meditation/session/${session.id}');
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Meditations'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title, instructor, or tags...',
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            ref.read(meditationSearchQueryProvider.notifier).state = query;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(meditationSearchQueryProvider.notifier).state = '';
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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