import 'package:flutter/material.dart';
import 'step1_screen.dart';
import 'FirstAnfitrionesScreen.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  /// 🔹 Más adelante aquí vivirán:
  /// - Riverpod
  /// - estado global del registro
  /// - validaciones de pasos

  @override
  Widget build(BuildContext context) {
    return FirstAnfitrionesScreen(
      onStartPressed: _goToStep1,
    );
  }

  void _goToStep1() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Step1Screen(),
      ),
    );
  }
}
