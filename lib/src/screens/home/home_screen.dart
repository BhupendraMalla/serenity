import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../providers/mood_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, ${currentUser?.displayName ?? 'Friend'}',
          style: AppTypography.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(context),
                  const SizedBox(height: 16),

                  // Quick Mood Check
                  _buildQuickMoodCard(context, ref, userId),
                  const SizedBox(height: 16),

                  // Daily Quote
                  _buildDailyQuoteCard(context),
                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 16),

                  // Recent Activity
                  _buildRecentActivity(context, ref, userId),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good morning!';
    } else if (now.hour < 17) {
      greeting = 'Good afternoon!';
    } else {
      greeting = 'Good evening!';
    }

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.calmGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.heading3.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a moment to check in with yourself today.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMoodCard(BuildContext context, WidgetRef ref, String userId) {
    final todayMoodAsync = ref.watch(todayMoodEntryProvider(userId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How are you feeling?',
                  style: AppTypography.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.mood),
                  onPressed: () => context.go('/mood'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            todayMoodAsync.when(
              data: (moodEntry) {
                if (moodEntry != null) {
                  return Row(
                    children: [
                      Text(
                        moodEntry.mood.emoji,
                        style: AppTypography.moodEmoji,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feeling ${moodEntry.mood.label.toLowerCase()}',
                              style: AppTypography.bodyLarge,
                            ),
                            if (moodEntry.note?.isNotEmpty == true)
                              Text(
                                moodEntry.note!,
                                style: AppTypography.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => context.go('/mood'),
                    child: const Text('Log your mood'),
                  );
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => const Text('Error loading mood'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuoteCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_quote, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Daily Inspiration',
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"The present moment is the only time over which we have dominion."',
              style: AppTypography.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— Thích Nhất Hạnh',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neutralGray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.self_improvement,
        label: 'Meditate',
        color: AppColors.secondaryGreen,
        onTap: () => context.go('/meditation'),
      ),
      _QuickAction(
        icon: Icons.book,
        label: 'Journal',
        color: AppColors.primaryBlue,
        onTap: () => context.go('/journal'),
      ),
      _QuickAction(
        icon: Icons.lightbulb,
        label: 'Tips',
        color: AppColors.accentLavender,
        onTap: () => context.go('/tips'),
      ),
      _QuickAction(
        icon: Icons.analytics,
        label: 'Insights',
        color: AppColors.accentPeach,
        onTap: () => context.go('/mood'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions.map((action) => _buildQuickActionButton(action)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(_QuickAction action) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: action.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(action.icon, color: action.color, size: 28),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: action.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref, String userId) {
    final moodEntriesAsync = ref.watch(moodEntriesProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        moodEntriesAsync.when(
          data: (entries) {
            final recentEntries = entries.take(3).toList();
            if (recentEntries.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No recent activity. Start by logging your mood!',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            
            return Column(
              children: recentEntries.map((entry) => Card(
                child: ListTile(
                  leading: Text(
                    entry.mood.emoji,
                    style: AppTypography.moodEmoji.copyWith(fontSize: 24),
                  ),
                  title: Text(entry.mood.label),
                  subtitle: Text(
                    '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/mood'),
                ),
              )).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Error loading recent activity'),
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}