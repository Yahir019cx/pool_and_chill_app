import 'package:flutter/material.dart';
import 'card_espacio.dart';

class EspaciosListWidget extends StatelessWidget {
  const EspaciosListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, index) => const EspacioCard(),
    );
  }
}
