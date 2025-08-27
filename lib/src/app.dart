import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'providers/app_providers_simple.dart';
import 'providers/auth_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/mood/mood_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/journal/journal_entry_editor.dart';
import 'screens/meditation/meditation_screen.dart';
import 'screens/meditation/meditation_player_screen.dart';
import 'screens/tips/tips_screen.dart';
import 'screens/profile/profile_screen.dart';

class SerenityApp extends ConsumerWidget {
  const SerenityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeString = ref.watch(themeModeProvider);
    final themeMode = switch (themeModeString) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Serenity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isOnboardingComplete = ref.watch(isOnboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Check if app is initializing
      final appState = ref.read(appStateProvider);
      if (!appState.isInitialized) {
        return '/splash';
      }

      // Handle authentication flow
      final isLoggedIn = authState.whenOrNull(
        data: (user) => user != null,
      ) ?? false;

      final isOnSplash = state.fullPath == '/splash';
      final isOnAuth = state.fullPath?.startsWith('/auth') ?? false;
      final isOnOnboarding = state.fullPath?.startsWith('/onboarding') ?? false;

      // If not logged in and not on auth screen, redirect to auth
      if (!isLoggedIn && !isOnAuth && !isOnSplash) {
        return '/auth';
      }

      // If logged in but onboarding not complete, redirect to onboarding
      if (isLoggedIn && !isOnboardingComplete && !isOnOnboarding && !isOnSplash) {
        return '/onboarding';
      }

      // If logged in and onboarding complete, but on auth screen, redirect to home
      if (isLoggedIn && isOnboardingComplete && isOnAuth) {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication flow
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Onboarding flow
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Mood tracking
          GoRoute(
            path: '/mood',
            name: 'mood',
            builder: (context, state) => const MoodScreen(),
          ),

          // Journal
          GoRoute(
            path: '/journal',
            name: 'journal',
            builder: (context, state) => const JournalScreen(),
            routes: [
              GoRoute(
                path: '/entry/:id',
                name: 'journal-entry',
                builder: (context, state) {
                  final entryId = state.pathParameters['id']!;
                  return JournalEntryEditor(entryId: entryId);
                },
              ),
            ],
          ),

          // Meditation
          GoRoute(
            path: '/meditation',
            name: 'meditation',
            builder: (context, state) => const MeditationScreen(),
            routes: [
              GoRoute(
                path: '/session/:id',
                name: 'meditation-session',
                builder: (context, state) {
                  final sessionId = state.pathParameters['id']!;
                  return MeditationPlayerScreen(sessionId: sessionId);
                },
              ),
            ],
          ),

          // Tips
          GoRoute(
            path: '/tips',
            name: 'tips',
            builder: (context, state) => const TipsScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Main shell with bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.mood_outlined,
      selectedIcon: Icons.mood,
      label: 'Mood',
      route: '/mood',
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Journal',
      route: '/journal',
    ),
    NavigationItem(
      icon: Icons.self_improvement_outlined,
      selectedIcon: Icons.self_improvement,
      label: 'Meditate',
      route: '/meditation',
    ),
    NavigationItem(
      icon: Icons.lightbulb_outline,
      selectedIcon: Icons.lightbulb,
      label: 'Tips',
      route: '/tips',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          context.go(_navigationItems[index].route);
        },
        destinations: _navigationItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}


