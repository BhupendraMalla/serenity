import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../models/journal_entry_simple.dart';
import '../../providers/journal_providers.dart';
import '../../providers/auth_providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Please sign in to access your journal'),
            ),
          );
        }
        return _buildJournalContent(user.uid);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildJournalContent(String userId) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort',
                child: Text('Sort & Filter'),
              ),
              const PopupMenuItem(
                value: 'stats',
                child: Text('Statistics'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildDailyPrompt(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildJournalEntries(userId),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewEntry(),
        child: const Icon(Icons.add),
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
                  Icons.book,
                  size: 28,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Personal Journal',
                        style: AppTypography.titleLarge,
                      ),
                      Text(
                        'Capture your thoughts and feelings',
                        style: AppTypography.bodyMedium.copyWith(
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
              'Writing in a journal can help you process emotions, track your mental health journey, and discover patterns in your thoughts and feelings.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPrompt() {
    final dailyPromptAsync = ref.watch(dailyJournalPromptProvider);
    
    return dailyPromptAsync.when(
      data: (prompt) {
        if (prompt == null) return const SizedBox.shrink();
        
        return Card(
          color: AppColors.secondaryGreen.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppColors.secondaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Prompt',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  prompt.title,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  prompt.prompt,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _createEntryFromPrompt(prompt),
                  icon: const Icon(Icons.edit),
                  label: const Text('Write Response'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.mood,
                title: 'Mood Entry',
                description: 'Link to today\'s mood',
                onTap: () => _createMoodLinkedEntry(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.favorite,
                title: 'Gratitude',
                description: 'Write what you\'re grateful for',
                onTap: () => _createGratitudeEntry(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutralGray600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntries(String userId) {
    final filteredEntriesAsync = ref.watch(filteredJournalEntriesProvider(userId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Entries',
              style: AppTypography.titleMedium,
            ),
            const Spacer(),
            _buildSortFilterChip(),
          ],
        ),
        const SizedBox(height: 12),
        filteredEntriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return _buildEmptyState();
            }
            
            return Column(
              children: entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEntryCard(entry),
                ),
              ).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading entries: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilterChip() {
    final sortMode = ref.watch(journalSortModeProvider);
    
    return FilterChip(
      label: Text(_getSortModeLabel(sortMode)),
      onSelected: (selected) => _showSortDialog(),
      avatar: const Icon(Icons.sort, size: 16),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.book_outlined,
                size: 64,
                color: AppColors.neutralGray400,
              ),
              const SizedBox(height: 16),
              Text(
                'Your journal is empty',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Start writing your first entry to begin your journaling journey',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.neutralGray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _createNewEntry(),
                icon: const Icon(Icons.add),
                label: const Text('Write First Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Card(
      child: InkWell(
        onTap: () => _openEntry(entry),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.isFavorite)
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppColors.error,
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleEntryAction(action, entry),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'favorite',
                        child: Text('Toggle Favorite'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: AppTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _formatDate(entry.updatedAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutralGray600,
                    ),
                  ),
                  if (entry.tags.isNotEmpty) ..[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: entry.tags.take(3).map((tag) => 
                          Chip(
                            label: Text(
                              tag,
                              style: AppTypography.labelSmall,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.neutralGray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewEntry() {
    ref.read(journalEntryControllerProvider.notifier).reset();
    context.push('/journal/entry/new');
  }

  void _createEntryFromPrompt(JournalPrompt prompt) {
    ref.read(journalEntryControllerProvider.notifier).reset();
    ref.read(journalEntryControllerProvider.notifier).setTitle(prompt.title);
    ref.read(journalEntryControllerProvider.notifier).setContent('${prompt.prompt}\n\n');
    context.push('/journal/entry/new');
  }

  void _createMoodLinkedEntry() {
    ref.read(journalEntryControllerProvider.notifier).reset();
    ref.read(journalEntryControllerProvider.notifier).setTitle('Mood Reflection');
    ref.read(journalEntryControllerProvider.notifier).setContent('How am I feeling today and why?\n\n');
    context.push('/journal/entry/new');
  }

  void _createGratitudeEntry() {
    ref.read(journalEntryControllerProvider.notifier).reset();
    ref.read(journalEntryControllerProvider.notifier).setTitle('Gratitude Journal');
    ref.read(journalEntryControllerProvider.notifier).setContent('Today I am grateful for:\n\n1. \n2. \n3. \n\n');
    context.push('/journal/entry/new');
  }

  void _openEntry(JournalEntry entry) {
    context.push('/journal/entry/${entry.id}');
  }

  void _handleEntryAction(String action, JournalEntry entry) async {
    switch (action) {
      case 'edit':
        ref.read(journalEntryControllerProvider.notifier).loadEntry(entry);
        context.push('/journal/entry/${entry.id}');
        break;
      case 'favorite':
        final repository = ref.read(journalRepositoryProvider);
        final updatedEntry = entry.copyWith(isFavorite: !entry.isFavorite);
        await repository.saveEntry(updatedEntry);
        ref.invalidate(journalEntriesProvider);
        break;
      case 'delete':
        _showDeleteConfirmation(entry);
        break;
    }
  }

  void _showDeleteConfirmation(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final repository = ref.read(journalRepositoryProvider);
              await repository.deleteEntry(entry.id);
              ref.invalidate(journalEntriesProvider);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Entries'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title, content, or tags...',
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            ref.read(journalSearchQueryProvider.notifier).state = query;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(journalSearchQueryProvider.notifier).state = '';
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort & Filter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by:', style: AppTypography.titleSmall),
            ...JournalSortMode.values.map((mode) => 
              RadioListTile<JournalSortMode>(
                title: Text(_getSortModeLabel(mode)),
                value: mode,
                groupValue: ref.read(journalSortModeProvider),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(journalSortModeProvider.notifier).state = value;
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort':
        _showSortDialog();
        break;
      case 'stats':
        _showStats();
        break;
      case 'export':
        _showExportDialog();
        break;
    }
  }

  void _showStats() {
    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid ?? 'guest';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Journal Statistics'),
        content: Consumer(
          builder: (context, ref, child) {
            final statsAsync = ref.watch(journalStatsProvider(userId));
            
            return statsAsync.when(
              data: (stats) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total Entries', '${stats.totalEntries}'),
                  _buildStatRow('Favorite Entries', '${stats.favoriteEntries}'),
                  _buildStatRow('This Week', '${stats.entriesThisWeek}'),
                  _buildStatRow('This Month', '${stats.entriesThisMonth}'),
                  _buildStatRow('Total Words', '${stats.totalWords}'),
                  _buildStatRow('Avg Words/Entry', stats.averageWordsPerEntry.toStringAsFixed(1)),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: AppTypography.titleSmall),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Journal'),
        content: const Text('Journal export functionality will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSortModeLabel(JournalSortMode mode) {
    switch (mode) {
      case JournalSortMode.newest:
        return 'Newest First';
      case JournalSortMode.oldest:
        return 'Oldest First';
      case JournalSortMode.alphabetical:
        return 'Alphabetical';
      case JournalSortMode.favorites:
        return 'Favorites First';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}