// perfil/widgets/editar_perfil.dart
import 'package:flutter/material.dart';
import './widgets/editar_perfil_form.dart';

class EditarPerfil extends StatelessWidget {
  const EditarPerfil({super.key});

  static const Color primaryColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Editar perfil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: const SafeArea(
        child: EditarPerfilForm(),
      ),
    );
  }
}
