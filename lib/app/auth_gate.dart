import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/auth/screens/login_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/welcome.dart';
import 'package:pool_and_chill_app/features/host/screens/welcome_host.dart';
import 'package:pool_and_chill_app/features/host/home_host.dart';
import 'package:pool_and_chill_app/features/splash/splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // SOLO para arranque inicial
    if (!auth.isBootstrapped) {
      return const SplashScreen();
    }

    // No autenticado
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final profile = auth.profile!;

    // Host en onboarding (isHostOnboarded == 1) → Bienvenida host
    if (profile.isHost && profile.isHostOnboarded == 1) {
      return const WelcomeAnfitrionScreen();
    }

    // Host con onboarding completo (isHostOnboarded == 2) → Dashboard host
    if (profile.isHost && profile.isHostOnboarded == 2) {
      return const HomeHostScreen();
    }

    // Usuario normal (isHostOnboarded == 0) → Home normal
    return const WelcomeScreen();
  }
}
