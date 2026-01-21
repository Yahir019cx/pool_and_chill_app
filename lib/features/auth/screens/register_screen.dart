import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _surnameController.text.isNotEmpty &&
      _birthDateController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _termsAccepted &&
      _privacyAccepted;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Nombre Completo"),
                    _textField("Nombre(s)", _nameController),

                    _sectionTitle("Apellidos"),
                    _textField("Apellidos", _surnameController),

                    _sectionTitle("Fecha de nacimiento"),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _textField(
                          "AAAA-MM-DD",
                          _birthDateController,
                        ),
                      ),
                    ),

                    _sectionTitle("Correo electrónico"),
                    _textField("Correo electrónico", _emailController),

                    _sectionTitle("Contraseña"),
                    _textField(
                      "Contraseña",
                      _passwordController,
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    _checkbox(
                      context,
                      value: _termsAccepted,
                      label: "Acepto los Términos y Condiciones",
                      onChanged: (v) => setState(() => _termsAccepted = v),
                      content: _termsText(),
                    ),

                    _checkbox(
                      context,
                      value: _privacyAccepted,
                      label: "Acepto la Política de Privacidad",
                      onChanged: (v) => setState(() => _privacyAccepted = v),
                      content: _privacyText(),
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        onPressed: _isFormValid
                            ? () {
                                debugPrint("Submit register form");
                              }
                            : null,
                        child: const Text("Aceptar y continuar"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "¿Ya tienes cuenta? Inicia sesión",
                          style: GoogleFonts.openSans(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI helpers ----------------

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 5),
        child: Text(
          text,
          style: GoogleFonts.openSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _textField(
    String hint,
    TextEditingController controller, {
    bool obscureText = false,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          enabledBorder: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      );

  Widget _checkbox(
    BuildContext context, {
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
    required String content,
  }) =>
      Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
          ),
          GestureDetector(
            onTap: () => _showLegalDialog(context, label, content),
            child: Text(
              label,
              style: GoogleFonts.openSans(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );

  void _showLegalDialog(
      BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  // ---------------- Legal texts ----------------

  String _termsText() => "Términos y condiciones...";
  String _privacyText() => "Aviso de privacidad...";
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF41838F),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          "Terminar Registro",
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
