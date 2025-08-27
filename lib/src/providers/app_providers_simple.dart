import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/app_state_simple.dart';

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
  // For now, default to false. In a real app, this would be persisted
  return false;
});

// Theme mode provider (simplified)
final themeModeProvider = StateProvider<String>((ref) {
  // Default to system theme
  return 'system';
});

class AppStateController extends StateNotifier<AppState> {
  AppStateController() : super(const AppState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Mark as initialized immediately for simplified version
    state = state.copyWith(
      isInitialized: true,
      isOnboardingComplete: false,
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
    // In a real app, this would be persisted to storage
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

// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // For simplified version, just return true
    await Future.delayed(const Duration(milliseconds: 500));
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
