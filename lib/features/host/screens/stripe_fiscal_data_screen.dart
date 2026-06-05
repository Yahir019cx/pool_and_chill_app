import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/stripe_service.dart';
import 'package:pool_and_chill_app/features/host/home_host.dart';
import 'package:pool_and_chill_app/features/host/screens/stripe_update_webview_screen.dart';

enum _AddressState { loading, loaded, notFound, error }

class StripeFiscalDataScreen extends ConsumerStatefulWidget {
  const StripeFiscalDataScreen({super.key});

  @override
  ConsumerState<StripeFiscalDataScreen> createState() =>
      _StripeFiscalDataScreenState();
}

class _StripeFiscalDataScreenState
    extends ConsumerState<StripeFiscalDataScreen> {
  static const Color _primary = Color(0xFF2D9D91);
  static const Color _dark = Color(0xFF1A1A2E);

  final _formKey = GlobalKey<FormState>();

  // Campos editables
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _rfcCtrl;
  late final TextEditingController _clabeCtrl;

  DateTime? _dob;
  bool _submitting = false;
  bool _infoExpanded = false;

  // Domicilio (pre-llenado y bloqueado desde la API)
  _AddressState _addressState = _AddressState.loading;
  FiscalAddress? _fiscalAddress;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;

    _nombreCtrl    = TextEditingController(text: profile?.firstName ?? '');
    _apellidosCtrl = TextEditingController(text: profile?.lastName ?? '');
    _telefonoCtrl  = TextEditingController(text: profile?.phoneNumber ?? '');
    _rfcCtrl       = TextEditingController();
    _clabeCtrl     = TextEditingController();

    _dob = profile?.dateOfBirth;

    // Carga el domicilio de la propiedad en el siguiente frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFiscalAddress());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _rfcCtrl.dispose();
    _clabeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CARGA DE DOMICILIO
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadFiscalAddress() async {
    setState(() => _addressState = _AddressState.loading);
    try {
      final service = ref.read(stripeServiceProvider);
      final address = await service.getFiscalAddress();
      if (!mounted) return;
      setState(() {
        _fiscalAddress = address;
        _addressState  = _AddressState.loaded;
      });
    } on FiscalAddressNotFoundException {
      if (!mounted) return;
      setState(() => _addressState = _AddressState.notFound);
    } catch (_) {
      if (!mounted) return;
      setState(() => _addressState = _AddressState.error);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERIFICACIÓN POST-ONBOARDING
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _verifyAndComplete() async {
    try {
      final service = ref.read(stripeServiceProvider);
      final status  = await service.getAccountStatus();
      if (!mounted) return;

      if (status.isReady) {
        await context.read<AuthProvider>().completeHostOnboarding();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeHostScreen()),
          (_) => false,
        );
      } else {
        TopChip.showInfo(
          context,
          'Cuenta en revisión. Stripe te avisará cuando esté activa.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      TopChip.showError(context, 'No se pudo verificar el estado de tu cuenta.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATE PICKER
  // ─────────────────────────────────────────────────────────────────────────

  void _showDobPicker() {
    DateTime temp = _dob ?? DateTime(1990, 1, 1);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fecha de nacimiento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _dark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _dob = temp);
                      Navigator.pop(ctx);
                    },
                    style: TextButton.styleFrom(foregroundColor: _primary),
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: temp,
                maximumDate: DateTime.now()
                    .subtract(const Duration(days: 365 * 18)),
                minimumDate: DateTime(1900),
                onDateTimeChanged: (dt) => setModal(() => temp = dt),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUBMIT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      TopChip.showError(context, 'Ingresa tu fecha de nacimiento');
      return;
    }
    if (_fiscalAddress == null) return; // no debería pasar

    setState(() => _submitting = true);
    try {
      final service = ref.read(stripeServiceProvider);
      final addr    = _fiscalAddress!;

      final dob = _dob!;
      final dobStr =
          '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

      final url = await service.setupConnectAccount(
        SetupAccountRequest(
          firstName:      _nombreCtrl.text.trim(),
          lastName:       _apellidosCtrl.text.trim(),
          dateOfBirth:    dobStr,
          phone:          _telefonoCtrl.text.trim(),
          rfc:            _rfcCtrl.text.trim().toUpperCase(),
          clabe:          _clabeCtrl.text.trim(),
          street:         addr.street,
          exteriorNumber: addr.exteriorNumber,
          interiorNumber: addr.interiorNumber,
          neighborhood:   addr.neighborhood,
          zipCode:        addr.zipCode,
          stateName:      addr.stateName,
          cityName:       addr.cityName,
        ),
      );

      if (!mounted) return;

      // Abre el onboarding en WebView dentro de la app
      final result = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(
          builder: (_) => StripeUpdateWebviewScreen(url: url),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        // Stripe confirmó → verificar con el backend
        await _verifyAndComplete();
      } else if (result == false) {
        // El link expiró (stripe/refresh)
        TopChip.showError(context, 'El enlace expiró. Intenta de nuevo.');
      }
      // result == null: usuario cerró el WebView → se queda en el formulario
    } catch (e) {
      if (!mounted) return;
      TopChip.showError(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  String get _dobDisplay {
    if (_dob == null) return '';
    return '${_dob!.day.toString().padLeft(2, '0')}/'
        '${_dob!.month.toString().padLeft(2, '0')}/'
        '${_dob!.year}';
  }

  bool get _canSubmit =>
      _addressState == _AddressState.loaded && !_submitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _dark,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header centrado ──────────────────────────────────
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Registro de Anfitrión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Completa tus datos para empezar a recibir pagos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Banner colapsable ────────────────────────────────
              _infoBanner(),
              const SizedBox(height: 28),

              // ── Sección 1: Datos personales ──────────────────────
              _sectionHeader('Datos personales'),
              const SizedBox(height: 14),
              _buildField(
                controller: _nombreCtrl,
                label: 'Nombre(s)',
                hint: 'Como aparece en tu INE',
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _apellidosCtrl,
                label: 'Apellidos',
                hint: 'Apellido paterno y materno',
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildTappableField(
                label: 'Fecha de nacimiento',
                value: _dobDisplay,
                placeholder: 'DD/MM/AAAA',
                icon: Icons.cake_outlined,
                onTap: _showDobPicker,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                hint: '10 dígitos sin espacios',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Campo requerido';
                  if (v.trim().length < 10) return 'Ingresa 10 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Sección 2: RFC y datos bancarios ─────────────────
              _sectionHeader('RFC y datos bancarios'),
              const SizedBox(height: 14),
              _buildField(
                controller: _rfcCtrl,
                label: 'RFC',
                hint: 'p. ej. GOHJ8710226T3',
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-zÑñ&0-9]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Campo requerido';
                  if (v.trim().length < 12) {
                    return 'RFC inválido (mín. 12 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _clabeCtrl,
                label: 'CLABE interbancaria',
                hint: '18 dígitos',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Campo requerido';
                  if (v.trim().length != 18) {
                    return 'La CLABE debe tener exactamente 18 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Sección 3: Domicilio del inmueble ────────────────
              _sectionHeader('Domicilio del inmueble'),
              const SizedBox(height: 4),
              Text(
                'Dirección registrada en tu propiedad',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 14),
              _buildAddressSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECCIÓN DOMICILIO
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAddressSection() {
    switch (_addressState) {
      case _AddressState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(
              color: _primary, strokeWidth: 3,
            ),
          ),
        );

      case _AddressState.notFound:
        return _addressBanner(
          icon: Icons.home_work_outlined,
          iconColor: Colors.orange.shade700,
          bgColor: Colors.orange.shade50,
          message:
              'Primero debes registrar tu propiedad para poder continuar con este paso.',
        );

      case _AddressState.error:
        return _addressBanner(
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red.shade600,
          bgColor: Colors.red.shade50,
          message: 'No se pudo cargar el domicilio. Verifica tu conexión.',
          trailing: TextButton(
            onPressed: _loadFiscalAddress,
            style: TextButton.styleFrom(foregroundColor: _primary),
            child: const Text('Reintentar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );

      case _AddressState.loaded:
        final a = _fiscalAddress!;
        return Column(
          children: [
            _buildLockedField(label: 'Calle, avenida o vía', value: a.street),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLockedField(
                      label: 'Núm. exterior', value: a.exteriorNumber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLockedField(
                    label: 'Núm. interior',
                    value: a.interiorNumber?.isNotEmpty == true
                        ? a.interiorNumber!
                        : '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLockedField(label: 'Colonia', value: a.neighborhood),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLockedField(
                      label: 'Código postal', value: a.zipCode),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLockedField(
                      label: 'Estado', value: a.stateName),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLockedField(
                label: 'Ciudad / Municipio', value: a.cityName),
          ],
        );
    }
  }

  Widget _addressBanner({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String message,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGETS HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _infoBanner() {
    return GestureDetector(
      onTap: () => setState(() => _infoExpanded = !_infoExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: _infoExpanded ? 14 : 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: _primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Por qué se piden estos datos?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: _infoExpanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'El SAT requiere estos datos para el reporte de servicios de hospedaje (Resolución Miscelánea Fiscal, Regla 3.11.12). Solo los usaremos con ese fin.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.45,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _infoExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _dark,
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(fontSize: 14.5, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle:
            TextStyle(color: Colors.grey.shade600, fontSize: 14),
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }

  /// Campo de solo lectura para el domicilio pre-llenado.
  Widget _buildLockedField({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500, height: 1),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14.5, color: _dark),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildTappableField({
    required String label,
    required String value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final hasValue = value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasValue ? value : placeholder,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: hasValue ? _dark : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _canSubmit ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _primary.withValues(alpha: 0.4),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  _addressState == _AddressState.notFound
                      ? 'Registra tu propiedad primero'
                      : 'Continuar',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
