import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/auth/screens/login_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/welcome.dart';
import 'package:pool_and_chill_app/features/splash/splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.tryRestoreSession();

    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!_initialized || auth.isLoading) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const WelcomeScreen();
    }

    return const LoginScreen();
  }
}
