import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/auth/screens/login_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/welcome.dart';
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

    // Login / Welcome (sin splash intermedio)
    if (auth.isAuthenticated) {
      return const WelcomeScreen();
    }

    return const LoginScreen();
  }
}
