import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routing/app_router.dart';
import '../auth/presentation/auth_controller.dart';
import '../../models/user.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    try {
      final authState = await ref.read(authControllerProvider.future);
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (authState == null) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      } else {
        if (authState.role == UserRole.provider) {
          Navigator.of(context).pushReplacementNamed(AppRouter.providerMain);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRouter.customerMain);
        }
      }
    } catch (e) {
      // In case of any error checking session, go to login
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'AI Services',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
