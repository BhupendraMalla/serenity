import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_simple.dart' as app_user;
// import '../services/hive_service.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

// Authentication state provider
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Current app user provider
final currentUserProvider = StateProvider<app_user.User?>((ref) => null);

// Current user ID provider
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// Authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firebaseAuthProvider), ref);
});

// Authentication controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

class AuthService {
  final firebase_auth.FirebaseAuth _auth;
  final Ref _ref;

  AuthService(this._auth, this._ref);

  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _setCurrentUser(credential.user!);
        return AuthResult.success();
      } else {
        return AuthResult.failure('Sign in failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  Future<AuthResult> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        await _setCurrentUser(credential.user!);
        return AuthResult.success();
      } else {
        return AuthResult.failure('Account creation failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  Future<AuthResult> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      
      if (credential.user != null) {
        await _setCurrentUser(credential.user!);
        return AuthResult.success();
      } else {
        return AuthResult.failure('Guest sign in failed');
      }
    } catch (e) {
      return AuthResult.failure('Guest sign in failed');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _ref.read(currentUserProvider.notifier).state = null;
    
    // Clear local data when signing out
    // TODO: Implement data clearing for anonymous users
  }

  Future<void> _setCurrentUser(firebase_auth.User firebaseUser) async {
    // Get or create user preferences
    // For simplified version, use default preferences
    const preferences = app_user.UserPreferences();

    final user = app_user.User(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      preferences: preferences,
      isPremium: false, // TODO: Check premium status
    );

    _ref.read(currentUserProvider.notifier).state = user;
    _ref.read(currentUserIdProvider.notifier).state = user.uid;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState.initial());

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AuthState.loading();
    
    final result = await _authService.signInWithEmailAndPassword(email, password);
    
    if (result.isSuccess) {
      state = const AuthState.authenticated();
    } else {
      state = AuthState.error(result.errorMessage!);
    }
  }

  Future<void> createAccount(String email, String password, String displayName) async {
    state = const AuthState.loading();
    
    final result = await _authService.createUserWithEmailAndPassword(email, password, displayName);
    
    if (result.isSuccess) {
      state = const AuthState.authenticated();
    } else {
      state = AuthState.error(result.errorMessage!);
    }
  }

  Future<void> signInAsGuest() async {
    state = const AuthState.loading();
    
    final result = await _authService.signInAsGuest();
    
    if (result.isSuccess) {
      state = const AuthState.authenticated();
    } else {
      state = AuthState.error(result.errorMessage!);
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    await _authService.signOut();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

// Authentication state
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated() = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

// Authentication result
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  const AuthResult._(this.isSuccess, this.errorMessage);

  factory AuthResult.success() => const AuthResult._(true, null);
  factory AuthResult.failure(String message) => AuthResult._(false, message);
}