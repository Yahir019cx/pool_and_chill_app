import 'package:flutter/material.dart';
import '../widgets/card_espacio_host.dart';

class MisEspaciosHostScreen extends StatefulWidget {
  const MisEspaciosHostScreen({super.key});

  @override
  State<MisEspaciosHostScreen> createState() => _MisEspaciosHostScreenState();
}

class _MisEspaciosHostScreenState extends State<MisEspaciosHostScreen> {
  static const Color primary = Color(0xFF2D9D91);

  // Datos de ejemplo - en producción vendrían de un provider/bloc
  final List<Map<String, dynamic>> _espacios = [
    {
      'nombre': 'Alberca Principal',
      'ubicacion': 'Col. Centro, Monterrey',
      'precio': 1200.0,
      'rating': 4.8,
      'reservas': 24,
      'activo': true,
      'fotos': <String>[],
    },
    {
      'nombre': 'Alberca con Jardín',
      'ubicacion': 'Col. Valle, Monterrey',
      'precio': 1500.0,
      'rating': 4.9,
      'reservas': 18,
      'activo': true,
      'fotos': <String>[],
    },
    {
      'nombre': 'Terraza con Alberca',
      'ubicacion': 'Col. Cumbres, Monterrey',
      'precio': 2000.0,
      'rating': 4.7,
      'reservas': 12,
      'activo': false,
      'fotos': <String>[],
    },
  ];

  void _toggleEspacioStatus(int index, bool newStatus) {
    setState(() {
      _espacios[index]['activo'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mis espacios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navegar a agregar espacio
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_espacios.length} espacios',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_espacios.where((e) => e['activo'] == true).length} activos',
                    style: TextStyle(
                      fontSize: 13,
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de espacios
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: _espacios.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final espacio = _espacios[index];
                  return EspacioHostCard(
                    nombre: espacio['nombre'],
                    ubicacion: espacio['ubicacion'],
                    precioPorDia: espacio['precio'],
                    rating: espacio['rating'],
                    totalReservas: espacio['reservas'],
                    isActivo: espacio['activo'],
                    fotos: List<String>.from(espacio['fotos']),
                    onTap: () {
                      // Navegar a detalle del espacio
                    },
                    onEdit: () {
                      // Navegar a editar espacio
                    },
                    onToggleStatus: (newStatus) {
                      _toggleEspacioStatus(index, newStatus);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
