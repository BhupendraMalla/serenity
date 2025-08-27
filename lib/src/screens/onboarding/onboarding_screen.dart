import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers_simple.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.self_improvement,
                size: 100,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Serenity',
                style: AppTypography.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your journey to mental wellness starts here. Let\'s set up your personalized experience.',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(appStateProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await ref.read(appStateProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}