import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mood_providers.dart';
import '../../providers/auth_providers.dart';
import '../../models/mood_entry_simple.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodSelector(context, ref, userId),
            const SizedBox(height: 24),
            _buildMoodHistory(context, ref, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, WidgetRef ref, String userId) {
    final selectedMood = ref.watch(selectedMoodProvider);
    final moodNote = ref.watch(moodNoteProvider);
    final isValid = ref.watch(isMoodFormValidProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Mood emoji selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodLevel.values.map((mood) {
                final isSelected = selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedMoodProvider.notifier).state = mood;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: AppColors.primaryBlue, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood.emoji,
                          style: AppTypography.moodEmoji,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: AppTypography.moodLabel,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Mood note
            TextField(
              decoration: const InputDecoration(
                labelText: 'How\'s your day going? (Optional)',
                hintText: 'Share what\'s on your mind...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                ref.read(moodNoteProvider.notifier).state = value;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid ? () async {
                  final controller = ref.read(moodControllerProvider);
                  final tags = ref.read(selectedMoodTagsProvider);
                  
                  await controller.addMoodEntry(
                    userId: userId,
                    mood: selectedMood!,
                    tags: tags,
                    note: moodNote.isEmpty ? null : moodNote,
                  );
                  
                  // Reset form
                  ref.read(resetMoodFormProvider)();
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mood logged successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } : null,
                child: const Text('Save Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHistory(BuildContext context, WidgetRef ref, String userId) {
    final moodEntriesAsync = ref.watch(moodEntriesProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Moods',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        moodEntriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mood_outlined,
                          size: 48,
                          color: AppColors.neutralGray400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No mood entries yet',
                          style: AppTypography.bodyLarge,
                        ),
                        Text(
                          'Start tracking your daily moods!',
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
              children: entries.take(10).map((entry) => Card(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getMoodColor(entry.mood).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        entry.mood.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(entry.mood.label),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year} at ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                      if (entry.note?.isNotEmpty == true)
                        Text(
                          entry.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref, entry);
                      }
                    },
                  ),
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading mood entries: $error'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.veryLow:
        return AppColors.moodVeryLow;
      case MoodLevel.low:
        return AppColors.moodLow;
      case MoodLevel.neutral:
        return AppColors.moodNeutral;
      case MoodLevel.high:
        return AppColors.moodHigh;
      case MoodLevel.veryHigh:
        return AppColors.moodVeryHigh;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mood Entry'),
        content: const Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(moodControllerProvider).deleteMoodEntry(entry.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mood entry deleted'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}