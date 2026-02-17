import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  /// Abre el modal desde cualquier contexto.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ForgotPasswordModal(),
    );
  }

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  static const _brand = Color(0xFF45919B);
  static const _brandLight = Color(0xFFECF2F3);

  final _emailController = TextEditingController();
  bool _loading = false;
  _ModalView _view = _ModalView.form; // form | success | error

  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _view = _ModalView.error;
        _errorMessage = 'Ingresa tu correo electrónico';
      });
      return;
    }

    setState(() => _loading = true);

    try {
      await context.read<AuthProvider>().forgotPassword(email);
      if (!mounted) return;
      setState(() => _view = _ModalView.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _view = _ModalView.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetToForm() {
    setState(() {
      _view = _ModalView.form;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Content based on view
                if (_view == _ModalView.form) _buildForm(),
                if (_view == _ModalView.success) _buildSuccess(),
                if (_view == _ModalView.error) _buildError(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── FORM VIEW ────────────────────────────────────────────

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _brandLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded, color: _brand, size: 32),
        ),
        const SizedBox(height: 20),

        Text(
          '¿Olvidaste tu contraseña?',
          style: GoogleFonts.lilitaOne(
            fontSize: 22,
            color: _brand,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          'Ingresa tu correo electrónico y te enviaremos las instrucciones para restablecerla.',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),

        // Email input
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.openSans(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            floatingLabelStyle: GoogleFonts.openSans(
              color: _brand,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.email_outlined, color: _brand, size: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _brand, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Enviar instrucciones',
                    style: GoogleFonts.lilitaOne(fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 14),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Ya la recordé, volver',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: _brand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── SUCCESS VIEW ─────────────────────────────────────────

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: _brandLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: _brand,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          '¡Correo enviado!',
          style: GoogleFonts.lilitaOne(fontSize: 22, color: _brand),
        ),
        const SizedBox(height: 10),

        Text(
          'Si el email está registrado, recibirás un correo con las instrucciones para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Volver al inicio de sesión',
              style: GoogleFonts.lilitaOne(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── ERROR VIEW ───────────────────────────────────────────

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade400,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Algo salió mal',
          style: GoogleFonts.lilitaOne(
            fontSize: 22,
            color: Colors.red.shade400,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _resetToForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Intentar de nuevo',
              style: GoogleFonts.lilitaOne(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 14),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Ya la recordé, volver',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: _brand,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

enum _ModalView { form, success, error }
