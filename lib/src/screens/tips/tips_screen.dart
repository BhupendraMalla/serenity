import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';
import '../../models/tip_simple.dart';
import '../../providers/tips_providers.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips & Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'stats',
                child: Text('Reading Stats'),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Text('Browse Categories'),
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
            _buildDailyQuote(),
            const SizedBox(height: 20),
            _buildCategoryFilter(),
            const SizedBox(height: 20),
            _buildFeaturedTips(),
            const SizedBox(height: 20),
            _buildAllTips(),
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
                  Icons.lightbulb,
                  size: 28,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mental Health Tips',
                        style: AppTypography.titleLarge,
                      ),
                      Text(
                        'Evidence-based insights for your wellbeing',
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
              'Discover practical strategies, expert advice, and daily wisdom to support your mental health journey. Each tip is carefully curated by mental health professionals.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuote() {
    final dailyQuoteAsync = ref.watch(dailyQuoteProvider);
    
    return dailyQuoteAsync.when(
      data: (quote) {
        if (quote == null) return const SizedBox.shrink();
        
        return Card(
          color: AppColors.accent.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_quote,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quote of the Day',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"${quote.quote}"',
                  style: AppTypography.bodyLarge.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '— ${quote.author}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutralGray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (quote.source != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    quote.source!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutralGray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryFilter() {
    final selectedCategory = ref.watch(selectedTipCategoryProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by Category',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip('All', null, selectedCategory),
              const SizedBox(width: 8),
              ...TipCategory.values.map((category) => 
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(
                    _getCategoryDisplayName(category), 
                    category, 
                    selectedCategory
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, TipCategory? category, TipCategory? selectedCategory) {
    final isSelected = selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(selectedTipCategoryProvider.notifier).state = 
            selected ? category : null;
      },
      backgroundColor: AppColors.neutralGray100,
      selectedColor: AppColors.accent.withValues(alpha: 0.1),
      side: isSelected 
          ? const BorderSide(color: AppColors.accent)
          : BorderSide.none,
    );
  }

  Widget _buildFeaturedTips() {
    final featuredTipsAsync = ref.watch(featuredTipsProvider);
    
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
              'Featured Tips',
              style: AppTypography.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        featuredTipsAsync.when(
          data: (tips) {
            if (tips.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Container(
                    width: 300,
                    margin: EdgeInsets.only(
                      right: index < tips.length - 1 ? 16 : 0,
                    ),
                    child: _buildFeaturedTipCard(tip),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFeaturedTipCard(Tip tip) {
    return Card(
      child: InkWell(
        onTap: () => _openTipDetail(tip),
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
                      color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(tip.category),
                      color: _getCategoryColor(tip.category),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: AppTypography.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  tip.content.length > 120 
                      ? '${tip.content.substring(0, 120)}...'
                      : tip.content,
                  style: AppTypography.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (tip.author != null) ...[
                    Text(
                      'by ${tip.author}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutralGray600,
                      ),
                    ),
                    const Spacer(),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryDisplayName(tip.category),
                      style: AppTypography.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllTips() {
    final filteredTipsAsync = ref.watch(filteredTipsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Tips',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: 12),
        filteredTipsAsync.when(
          data: (tips) {
            if (tips.isEmpty) {
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
                          'No tips found',
                          style: AppTypography.bodyLarge,
                        ),
                        Text(
                          'Try adjusting your search or category filter',
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
              children: tips.map((tip) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTipListItem(tip),
                ),
              ).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading tips: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildTipListItem(Tip tip) {
    return Card(
      child: ListTile(
        onTap: () => _openTipDetail(tip),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _getCategoryIcon(tip.category),
            color: _getCategoryColor(tip.category),
          ),
        ),
        title: Text(
          tip.title,
          style: AppTypography.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.content.length > 100 
                  ? '${tip.content.substring(0, 100)}...'
                  : tip.content,
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _getCategoryDisplayName(tip.category),
                  style: AppTypography.labelSmall.copyWith(
                    color: _getCategoryColor(tip.category),
                  ),
                ),
                if (tip.author != null) ...[
                  const Text(' • '),
                  Text(
                    tip.author!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.neutralGray600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tip.isFeatured)
              const Icon(
                Icons.star,
                color: AppColors.accent,
                size: 16,
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 12),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _openTipDetail(Tip tip) {
    ref.read(markTipAsReadProvider)(tip.id);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TipDetailScreen(tip: tip),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tips'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title, content, or author...',
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            ref.read(tipsSearchQueryProvider.notifier).state = query;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(tipsSearchQueryProvider.notifier).state = '';
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'stats':
        _showReadingStats();
        break;
      case 'categories':
        _showCategoriesDialog();
        break;
    }
  }

  void _showReadingStats() {
    final stats = ref.read(readingStatsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Tips Read', '${stats.totalTipsRead}'),
            _buildStatRow('Reading Time', '${stats.totalReadingTime} min'),
            _buildStatRow('Favorite Category', _getCategoryDisplayName(stats.favoriteCategory)),
            _buildStatRow('Daily Streak', '${stats.streakDays} days'),
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

  void _showCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Browse Categories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TipCategory.values.map((category) => 
            ListTile(
              leading: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
              ),
              title: Text(_getCategoryDisplayName(category)),
              onTap: () {
                ref.read(selectedTipCategoryProvider.notifier).state = category;
                Navigator.of(context).pop();
              },
            ),
          ).toList(),
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

  String _getCategoryDisplayName(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return 'Stress Management';
      case TipCategory.anxiety:
        return 'Anxiety Relief';
      case TipCategory.sleep:
        return 'Sleep & Rest';
      case TipCategory.mindfulness:
        return 'Mindfulness';
      case TipCategory.productivity:
        return 'Focus & Productivity';
      case TipCategory.relationships:
        return 'Relationships';
      case TipCategory.general:
        return 'General Wellness';
    }
  }

  IconData _getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return Icons.spa;
      case TipCategory.anxiety:
        return Icons.healing;
      case TipCategory.sleep:
        return Icons.bedtime;
      case TipCategory.mindfulness:
        return Icons.psychology;
      case TipCategory.productivity:
        return Icons.work;
      case TipCategory.relationships:
        return Icons.people;
      case TipCategory.general:
        return Icons.favorite;
    }
  }

  Color _getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return AppColors.secondaryGreen;
      case TipCategory.anxiety:
        return Colors.teal;
      case TipCategory.sleep:
        return Colors.indigo;
      case TipCategory.mindfulness:
        return Colors.purple;
      case TipCategory.productivity:
        return AppColors.primaryBlue;
      case TipCategory.relationships:
        return Colors.pink;
      case TipCategory.general:
        return AppColors.accent;
    }
  }
}

// Tip Detail Screen
class TipDetailScreen extends StatelessWidget {
  final Tip tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(tip.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getCategoryColor(tip.category),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(tip.category),
                    size: 16,
                    color: _getCategoryColor(tip.category),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getCategoryDisplayName(tip.category),
                    style: AppTypography.labelMedium.copyWith(
                      color: _getCategoryColor(tip.category),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              tip.title,
              style: AppTypography.heading2,
            ),
            
            const SizedBox(height: 16),
            
            // Author and source
            if (tip.author != null || tip.source != null)
              Card(
                color: AppColors.neutralGray50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.neutralGray600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tip.author != null)
                              Text(
                                'by ${tip.author}',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            if (tip.source != null)
                              Text(
                                tip.source!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.neutralGray600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Content
            Text(
              tip.content,
              style: AppTypography.bodyLarge.copyWith(
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Tags
            if (tip.tags.isNotEmpty) ...[
              Text(
                'Related Tags',
                style: AppTypography.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tip.tags.map((tag) => 
                  Chip(
                    label: Text(
                      tag,
                      style: AppTypography.labelSmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return 'Stress Management';
      case TipCategory.anxiety:
        return 'Anxiety Relief';
      case TipCategory.sleep:
        return 'Sleep & Rest';
      case TipCategory.mindfulness:
        return 'Mindfulness';
      case TipCategory.productivity:
        return 'Focus & Productivity';
      case TipCategory.relationships:
        return 'Relationships';
      case TipCategory.general:
        return 'General Wellness';
    }
  }

  IconData _getCategoryIcon(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return Icons.spa;
      case TipCategory.anxiety:
        return Icons.healing;
      case TipCategory.sleep:
        return Icons.bedtime;
      case TipCategory.mindfulness:
        return Icons.psychology;
      case TipCategory.productivity:
        return Icons.work;
      case TipCategory.relationships:
        return Icons.people;
      case TipCategory.general:
        return Icons.favorite;
    }
  }

  Color _getCategoryColor(TipCategory category) {
    switch (category) {
      case TipCategory.stress:
        return AppColors.secondaryGreen;
      case TipCategory.anxiety:
        return Colors.teal;
      case TipCategory.sleep:
        return Colors.indigo;
      case TipCategory.mindfulness:
        return Colors.purple;
      case TipCategory.productivity:
        return AppColors.primaryBlue;
      case TipCategory.relationships:
        return Colors.pink;
      case TipCategory.general:
        return AppColors.accent;
    }
  }
}