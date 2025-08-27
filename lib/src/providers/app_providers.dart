import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/app_state_simple.dart';
import '../services/hive_service.dart';

// Connectivity provider
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// App state provider
final appStateProvider = StateNotifierProvider<AppStateController, AppState>((ref) {
  return AppStateController();
});

// Onboarding completion provider
final isOnboardingCompleteProvider = StateProvider<bool>((ref) {
  // Check if onboarding is complete from local storage
  return HiveService.getAppState<bool>('onboarding_complete') ?? false;
});

// Theme mode provider (simplified)
final themeModeProvider = StateProvider<String>((ref) {
  // Get theme mode from local storage or default to system
  return HiveService.getAppState<String>('theme_mode') ?? 'system';
});

class AppStateController extends StateNotifier<AppState> {
  AppStateController() : super(const AppState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Load initial state from storage
    final isOnboardingComplete = HiveService.getAppState<bool>('onboarding_complete') ?? false;
    final lastSyncTime = HiveService.getAppState<String>('last_sync_time');
    
    state = state.copyWith(
      isInitialized: true,
      isOnboardingComplete: isOnboardingComplete,
      lastSyncTime: lastSyncTime != null ? DateTime.parse(lastSyncTime) : null,
    );
  }

  void setConnectivityStatus(ConnectivityStatus status) {
    state = state.copyWith(connectivity: status);
    
    if (status == ConnectivityStatus.online) {
      // Trigger sync when coming online
      _triggerSync();
    }
  }

  void setSyncStatus(SyncStatus status) {
    state = state.copyWith(syncStatus: status);
  }

  void setPendingSyncOperations(int count) {
    state = state.copyWith(pendingSyncOperations: count);
  }

  void setLastSyncTime(DateTime time) {
    state = state.copyWith(lastSyncTime: time);
    HiveService.saveAppState('last_sync_time', time.toIso8601String());
  }

  void setCurrentUserId(String? userId) {
    state = state.copyWith(currentUserId: userId);
  }

  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOfflineMode: isOffline);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isOnboardingComplete: true);
    await HiveService.saveAppState('onboarding_complete', true);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void _triggerSync() {
    // TODO: Implement sync logic
    setSyncStatus(SyncStatus.syncing);
    
    // Simulate sync completion
    Future.delayed(const Duration(seconds: 2), () {
      setSyncStatus(SyncStatus.success);
      setLastSyncTime(DateTime.now());
    });
  }
}

// Sync operations provider
final syncOperationsProvider = FutureProvider<List<SyncOperation>>((ref) {
  // For simplified version, return empty list
  return <SyncOperation>[];
});

// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    await HiveService.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

// Error handling provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(ref);
});

class ErrorHandler {
  final Ref _ref;

  ErrorHandler(this._ref);

  void handleError(Object error, StackTrace stackTrace) {
    // Log error (in production, send to crash analytics)
    debugPrint('Error: $error');
    debugPrint('Stack trace: $stackTrace');

    // Set error state
    _ref.read(appStateProvider.notifier).setError(error.toString());

    // Handle specific error types
    if (error is Exception) {
      _handleException(error);
    }
  }

  void _handleException(Exception exception) {
    // Handle different types of exceptions
    String errorMessage = 'An unexpected error occurred';
    
    if (exception.toString().contains('network')) {
      errorMessage = 'Network connection error';
      _ref.read(appStateProvider.notifier).setOfflineMode(true);
    } else if (exception.toString().contains('permission')) {
      errorMessage = 'Permission denied';
    } else if (exception.toString().contains('storage')) {
      errorMessage = 'Storage error';
    }

    _ref.read(appStateProvider.notifier).setError(errorMessage);
  }

  void clearError() {
    _ref.read(appStateProvider.notifier).clearError();
  }
}