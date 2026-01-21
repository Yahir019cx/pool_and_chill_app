import 'package:flutter/material.dart';
// import 'features/auth/screens/login_screen.dart';
// import 'features/home/screens/welcome.dart';
import 'features/host/screens/welcome_host.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pool & Chill',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 62, 131, 140),
        ),
      ),
      home: const WelcomeAnfitrionScreen(),
    );
  }
}
