enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

enum SyncStatus {
  idle,
  syncing,
  failed,
  success,
}

class AppState {
  final bool isInitialized;
  final bool isOnboardingComplete;
  final ConnectivityStatus connectivity;
  final SyncStatus syncStatus;
  final int pendingSyncOperations;
  final DateTime? lastSyncTime;
  final String? currentUserId;
  final bool isOfflineMode;
  final String? errorMessage;

  const AppState({
    this.isInitialized = false,
    this.isOnboardingComplete = false,
    this.connectivity = ConnectivityStatus.unknown,
    this.syncStatus = SyncStatus.idle,
    this.pendingSyncOperations = 0,
    this.lastSyncTime,
    this.currentUserId,
    this.isOfflineMode = false,
    this.errorMessage,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isOnboardingComplete,
    ConnectivityStatus? connectivity,
    SyncStatus? syncStatus,
    int? pendingSyncOperations,
    DateTime? lastSyncTime,
    String? currentUserId,
    bool? isOfflineMode,
    String? errorMessage,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      connectivity: connectivity ?? this.connectivity,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingSyncOperations: pendingSyncOperations ?? this.pendingSyncOperations,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      currentUserId: currentUserId ?? this.currentUserId,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isInitialized': isInitialized,
      'isOnboardingComplete': isOnboardingComplete,
      'connectivity': connectivity.name,
      'syncStatus': syncStatus.name,
      'pendingSyncOperations': pendingSyncOperations,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'currentUserId': currentUserId,
      'isOfflineMode': isOfflineMode,
      'errorMessage': errorMessage,
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      isInitialized: json['isInitialized'] as bool? ?? false,
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
      connectivity: ConnectivityStatus.values.firstWhere(
        (e) => e.name == json['connectivity'],
        orElse: () => ConnectivityStatus.unknown,
      ),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == json['syncStatus'],
        orElse: () => SyncStatus.idle,
      ),
      pendingSyncOperations: json['pendingSyncOperations'] as int? ?? 0,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'])
          : null,
      currentUserId: json['currentUserId'] as String?,
      isOfflineMode: json['isOfflineMode'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

enum SyncOperationType {
  moodEntry,
  journalEntry,
  meditationProgress,
  userPreferences,
  deleteData,
}

enum SyncOperationStatus {
  pending,
  syncing,
  completed,
  failed,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final SyncOperationStatus status;
  final String? errorMessage;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.status = SyncOperationStatus.pending,
    this.errorMessage,
  });

  SyncOperation copyWith({
    String? id,
    SyncOperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    SyncOperationStatus? status,
    String? errorMessage,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] as int? ?? 0,
      status: SyncOperationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SyncOperationStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}