import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/auth/widgets/register_header.dart';
import 'package:pool_and_chill_app/features/auth/widgets/auth_input.dart';
import 'package:pool_and_chill_app/features/auth/widgets/legal_checkbox.dart';
import 'package:pool_and_chill_app/features/auth/widgets/auth_snackbar.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/terminos_screen.dart';
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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _selectedGender;
  String? _selectedDateOfBirth;

  static const _brandColor = Color(0xFF41838F);

  static const _genderOptions = [
    {'value': 1, 'label': 'Masculino'},
    {'value': 2, 'label': 'Femenino'},
    {'value': 3, 'label': 'Otro'},
    {'value': 4, 'label': 'Prefiero no decir'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _brandColor),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formatted =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _birthDateController.text = formatted;
        _selectedDateOfBirth = formatted;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted || !_privacyAccepted) {
      AuthSnackbar.showWarning(context, 'Debes aceptar los términos y la política de privacidad');
      return;
    }

    final auth = context.read<AuthProvider>();

    try {
      await auth.register(
        email: _emailController.text.trim(),
        firstName: _nameController.text.trim(),
        lastName: _surnameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        dateOfBirth: _selectedDateOfBirth,
        gender: _selectedGender,
      );

      if (!mounted) return;

      AuthSnackbar.showSuccess(context, 'Verifica tu email para poder iniciar sesión');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');
      AuthSnackbar.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RegisterHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    AuthInput(
                      controller: _emailController,
                      hint: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'El correo es requerido';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nombre y Apellido
                    Row(
                      children: [
                        Expanded(
                          child: AuthInput(
                            controller: _nameController,
                            hint: 'Nombre(s)',
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requerido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AuthInput(
                            controller: _surnameController,
                            hint: 'Apellidos',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Requerido';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Teléfono
                    AuthInput(
                      controller: _phoneController,
                      hint: 'Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'El teléfono es requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Contraseña
                    AuthInput(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'La contraseña es requerida';
                        if (v.length < 8) return 'Mínimo 8 caracteres';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Incluye al menos una mayúscula';
                        if (!RegExp(r'[a-z]').hasMatch(v)) return 'Incluye al menos una minúscula';
                        if (!RegExp(r'[0-9]').hasMatch(v)) return 'Incluye al menos un número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Confirmar contraseña
                    AuthInput(
                      controller: _confirmPasswordController,
                      hint: 'Confirmar contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                        if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Fecha de nacimiento y Género
                    Row(
                      children: [
                        Expanded(
                          child: AuthInput(
                            controller: _birthDateController,
                            hint: 'Nacimiento',
                            prefixIcon: Icons.cake_outlined,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _selectedGender,
                            isExpanded: true,
                            style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87),
                            decoration: AuthInput.decoration(hint: 'Género'),
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
                            items: _genderOptions
                                .map((g) => DropdownMenuItem<int>(
                                      value: g['value'] as int,
                                      child: Text(g['label'] as String),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedGender = v),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Checkboxes legales
                    LegalCheckbox(
                      value: _termsAccepted,
                      prefix: "Acepto los",
                      highlight: "Términos y Condiciones",
                      legalContent: TerminosCondicionesScreen.terminosServicio,
                      onChanged: (v) => setState(() => _termsAccepted = v),
                    ),
                    const SizedBox(height: 4),
                    LegalCheckbox(
                      value: _privacyAccepted,
                      prefix: "Acepto la",
                      highlight: "Política de Privacidad",
                      legalContent: TerminosCondicionesScreen.politicaPrivacidad,
                      onChanged: (v) => setState(() => _privacyAccepted = v),
                    ),

                    const SizedBox(height: 28),

                    // Botón crear cuenta
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading || !_termsAccepted || !_privacyAccepted
                            ? null
                            : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 69, 145, 155),
                          disabledBackgroundColor: const Color.fromARGB(255, 196, 196, 196),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Crear cuenta',
                                style: GoogleFonts.lilitaOne(
                                  fontSize: 18,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Link a login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey.shade600),
                            children: [
                              const TextSpan(text: '¿Ya tienes cuenta? '),
                              TextSpan(
                                text: 'Inicia sesión',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  color: _brandColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
