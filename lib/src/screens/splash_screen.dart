import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers_simple.dart';
import '../providers/auth_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for animations to start
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if app is initialized
    final appInitialized = await ref.read(appInitializationProvider.future);
    
    if (!appInitialized) {
      // Handle initialization error
      _showInitializationError();
      return;
    }

    // Mark app as initialized
    ref.read(appStateProvider.notifier).completeOnboarding();

    // Wait for animation to complete
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Check authentication state
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          // User is signed in, check onboarding
          final isOnboardingComplete = ref.read(isOnboardingCompleteProvider);
          if (isOnboardingComplete) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        } else {
          // User is not signed in
          context.go('/auth');
        }
      },
      loading: () {
        // Still loading auth state, wait a bit more
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/auth');
          }
        });
      },
      error: (error, stack) {
        // Error in auth state, go to auth screen
        context.go('/auth');
      },
    );
  }

  void _showInitializationError() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: const Text(
          'There was an error initializing the app. Please restart the application.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Try to reinitialize
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon/Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 60,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // App Name
                      Text(
                        'Serenity',
                        style: AppTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Tagline
                      Text(
                        'Find your peace, one breath at a time',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Loading indicator
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}