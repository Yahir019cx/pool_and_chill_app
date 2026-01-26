import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedIndex = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    try {
      await auth.login(
        email: email,
        password: password,
      );
      // 👉 NO navegamos aquí
      // main.dart decide qué pantalla mostrar
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),

          /// Header
          Container(
            height: height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 62, 131, 140),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(0, -55),
                  child: Image.asset(
                    'assets/images/logoLT.png',
                    width: 280,
                    height: 280,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -160),
                  child: Text(
                    "Relájate, disfruta, reserva.",
                    style: GoogleFonts.oleoScript(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Content
          Positioned(
            top: height * 0.27,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(70)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  /// Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 248, 248, 248),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(20),
                      borderColor: Colors.transparent,
                      selectedBorderColor: Colors.transparent,
                      fillColor: const Color.fromARGB(255, 62, 131, 140),
                      selectedColor: Colors.white,
                      color: Colors.black,
                      constraints: const BoxConstraints(
                        minHeight: 50,
                        minWidth: 120,
                      ),
                      isSelected: [
                        _selectedIndex == 0,
                        _selectedIndex == 1,
                      ],
                      onPressed: (index) {
                        setState(() => _selectedIndex = index);
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        }
                      },
                      children: [
                        Text(
                          'Log In',
                          style: GoogleFonts.lilitaOne(fontSize: 16),
                        ),
                        Text(
                          'Sign In',
                          style: GoogleFonts.lilitaOne(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  _buildInput(
                    controller: _emailController,
                    label: 'Correo electrónico',
                  ),

                  const SizedBox(height: 15),

                  _buildInput(
                    controller: _passwordController,
                    label: 'Contraseña',
                    obscure: true,
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 62, 131, 140),
                          width: 2,
                        ),
                      ),
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Log In',
                            style: GoogleFonts.lilitaOne(
                              fontSize: 16,
                              color:
                                  const Color.fromARGB(255, 62, 131, 140),
                            ),
                          ),
                  ),

                  const SizedBox(height: 60),

                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          color: Color.fromARGB(255, 62, 131, 140),
                          thickness: 2,
                          indent: 40,
                          endIndent: 10,
                        ),
                      ),
                      Text("o bien"),
                      Expanded(
                        child: Divider(
                          color: Color.fromARGB(255, 62, 131, 140),
                          thickness: 2,
                          indent: 10,
                          endIndent: 40,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _social(FontAwesomeIcons.facebook, Colors.blue),
                      const SizedBox(width: 15),
                      _social(FontAwesomeIcons.google, Colors.red),
                      const SizedBox(width: 15),
                      _social(FontAwesomeIcons.apple, Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.openSans(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 62, 131, 140),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 62, 131, 140),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _social(IconData icon, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.all(12),
      ),
      child: FaIcon(icon, color: color, size: 24),
    );
  }
}
