// perfil/widgets/editar_perfil_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'avatar_perfil.dart';

class EditarPerfilForm extends StatefulWidget {
  const EditarPerfilForm({super.key});

  @override
  State<EditarPerfilForm> createState() => _EditarPerfilFormState();
}

class _EditarPerfilFormState extends State<EditarPerfilForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  DateTime? _fechaNacimiento;

  static const Color primary = Color(0xFF3CA2A2);
  static const Color inputBg = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          /// ---------- AVATAR ----------
          AvatarPerfil(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cambiar avatar (mock)'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          /// ---------- INPUTS ----------
          _input('Nombre', _nombreCtrl),
          _input('Apellido', _apellidoCtrl),
          _input(
            'Correo electrónico',
            _emailCtrl,
            keyboard: TextInputType.emailAddress,
          ),
          _input(
            'Teléfono',
            _telefonoCtrl,
            keyboard: TextInputType.phone,
          ),

          _datePicker(),
          _input('Ubicación', _ubicacionCtrl),
          _input('Biografía', _bioCtrl, maxLines: 3),

          const SizedBox(height: 32),

          /// ---------- BOTÓN ----------
          ElevatedButton(
            onPressed: _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Guardar cambios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTES UI ----------

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: _pickFecha,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          child: Text(
            _fechaNacimiento == null
                ? 'Selecciona una fecha'
                : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
            style: TextStyle(
              color: _fechaNacimiento == null
                  ? Colors.grey
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- ACTIONS ----------

  void _pickFecha() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  void _guardar() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados (mock)'),
      ),
    );
  }
}
