import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignIn = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthStateAuthenticated) {
        context.go('/onboarding');
      } else if (next is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.self_improvement,
                size: 80,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Serenity',
                style: AppTypography.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your wellness journey',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (!_isSignIn) ...[
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState is AuthStateLoading
                      ? null
                      : () {
                          if (_isSignIn) {
                            ref
                                .read(authControllerProvider.notifier)
                                .signInWithEmailAndPassword(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                          } else {
                            ref
                                .read(authControllerProvider.notifier)
                                .createAccount(
                                  _emailController.text,
                                  _passwordController.text,
                                  'User', // Default display name
                                );
                          }
                        },
                  child: authState is AuthStateLoading
                      ? const CircularProgressIndicator()
                      : Text(_isSignIn ? 'Sign In' : 'Sign Up'),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignIn = !_isSignIn;
                  });
                },
                child: Text(
                  _isSignIn
                      ? 'Don\'t have an account? Sign up'
                      : 'Already have an account? Sign in',
                ),
              ),

              const SizedBox(height: 24),

              OutlinedButton(
                onPressed: authState is AuthStateLoading
                    ? null
                    : () {
                        ref
                            .read(authControllerProvider.notifier)
                            .signInAsGuest();
                      },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
