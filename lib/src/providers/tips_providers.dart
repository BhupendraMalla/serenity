import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tip_simple.dart';
import '../services/tips_repository.dart';

// Tips repository provider
final tipsRepositoryProvider = Provider<TipsRepository>((ref) {
  return SimpleTipsRepositoryImpl();
});

// All tips provider
final allTipsProvider = FutureProvider<List<Tip>>((ref) {
  final repository = ref.read(tipsRepositoryProvider);
  return repository.getAllTips();
});

// Tips by category provider
final tipsByCategoryProvider = FutureProvider.family<List<Tip>, TipCategory>((ref, category) {
  final repository = ref.read(tipsRepositoryProvider);
  return repository.getTipsByCategory(category);
});

// Featured tips provider
final featuredTipsProvider = FutureProvider<List<Tip>>((ref) {
  final repository = ref.read(tipsRepositoryProvider);
  return repository.getFeaturedTips();
});

// Daily quote provider
final dailyQuoteProvider = FutureProvider<DailyQuote?>((ref) {
  final repository = ref.read(tipsRepositoryProvider);
  return repository.getTodayQuote();
});

// Search and filter providers
final tipsSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedTipCategoryProvider = StateProvider<TipCategory?>((ref) => null);

// Filtered tips provider
final filteredTipsProvider = FutureProvider<List<Tip>>((ref) async {
  final allTips = await ref.watch(allTipsProvider.future);
  final searchQuery = ref.watch(tipsSearchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedTipCategoryProvider);

  var filtered = allTips;

  // Filter by category
  if (selectedCategory != null) {
    filtered = filtered.where((tip) => tip.category == selectedCategory).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((tip) =>
      tip.title.toLowerCase().contains(searchQuery) ||
      tip.content.toLowerCase().contains(searchQuery) ||
      tip.tags.any((tag) => tag.toLowerCase().contains(searchQuery)) ||
      (tip.author?.toLowerCase().contains(searchQuery) ?? false)
    ).toList();
  }

  return filtered;
});

// Tip reading progress provider
final tipReadingProgressProvider = StateProvider.family<bool, String>((ref, tipId) => false);

// Mark tip as read
final markTipAsReadProvider = Provider((ref) {
  return (String tipId) {
    ref.read(tipReadingProgressProvider(tipId).notifier).state = true;
  };
});

// Get reading stats
final readingStatsProvider = Provider<ReadingStats>((ref) {
  // This would normally come from a service that tracks reading progress
  // For demo purposes, we'll return sample stats
  return const ReadingStats(
    totalTipsRead: 12,
    totalReadingTime: 45, // minutes
    favoriteCategory: TipCategory.mindfulness,
    streakDays: 5,
  );
});

class ReadingStats {
  final int totalTipsRead;
  final int totalReadingTime; // in minutes
  final TipCategory favoriteCategory;
  final int streakDays;

  const ReadingStats({
    required this.totalTipsRead,
    required this.totalReadingTime,
    required this.favoriteCategory,
    required this.streakDays,
  });
}