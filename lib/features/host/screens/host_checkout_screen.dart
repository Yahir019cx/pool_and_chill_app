import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

import 'guest_review_screen.dart';

class HostCheckOutScreen extends ConsumerStatefulWidget {
  final HostBooking booking;

  const HostCheckOutScreen({super.key, required this.booking});

  @override
  ConsumerState<HostCheckOutScreen> createState() =>
      _HostCheckOutScreenState();
}

class _HostCheckOutScreenState extends ConsumerState<HostCheckOutScreen> {
  static const _primary = Color(0xFF2D9D91);

  String? _condition; // 'good' | 'damaged'
  final _notesController = TextEditingController();
  bool _isLoading = false;
  CheckOutData? _successData;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _condition != null && !_isLoading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(bookingServiceProvider);
      final result = await service.checkOut(CheckOutRequest(
        bookingId: widget.booking.bookingId,
        propertyCondition: _condition!,
        hostNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ));
      setState(() {
        _isLoading = false;
        _successData = result.data;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Registrar salida',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: _successData != null ? _buildSuccess() : _buildForm(),
    );
  }

  // ─── Success state ─────────────────────────────────────────────

  Widget _buildSuccess() {
    final isDamaged = _successData!.propertyCondition == 'damaged';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _primary, size: 46),
            ),
            const SizedBox(height: 20),
            const Text(
              'Salida registrada',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              _successData!.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            if (isDamaged) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El pago está en espera hasta que se resuelva el reporte de daños.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade800,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GuestReviewScreen(booking: widget.booking),
                    ),
                  );
                  if (mounted) Navigator.pop(context, true);
                },
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Calificar huésped'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Ahora no',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Form ──────────────────────────────────────────────────────

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking info card
          _BookingInfoCard(booking: widget.booking),
          const SizedBox(height: 28),

          // Section: condition
          const Text(
            '¿Cómo quedó la propiedad?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona el estado en que encontraste el espacio.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),

          _ConditionCard(
            selected: _condition == 'good',
            icon: Icons.check_circle_outline_rounded,
            iconColor: _primary,
            title: 'Todo en orden',
            subtitle: 'La propiedad está limpia y sin daños.',
            onTap: () => setState(() => _condition = 'good'),
          ),
          const SizedBox(height: 10),
          _ConditionCard(
            selected: _condition == 'damaged',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.amber.shade700,
            title: 'Se reportan daños',
            subtitle: 'Hay daños o condiciones anormales.',
            onTap: () => setState(() => _condition = 'damaged'),
            selectedAccent: Colors.amber.shade600,
            selectedBorder: Colors.amber.shade300,
            selectedBackground: Colors.amber.shade50,
          ),

          // Section: notes (animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _condition == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),
                      Text(
                        _condition == 'damaged'
                            ? 'Describe los daños'
                            : 'Notas adicionales',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _condition == 'damaged'
                            ? 'Explica qué encontraste. Esto ayuda a resolver el reporte.'
                            : 'Opcional: deja un comentario sobre la estancia.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        maxLength: 1000,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _condition == 'damaged'
                              ? 'Ej. Cortina rota en habitación principal...'
                              : 'Ej. Todo en orden, huésped muy respetuoso...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          counterStyle: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _primary),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Error banner
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          fontSize: 13, color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Registrar salida'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking info card ────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final HostBooking booking;

  const _BookingInfoCard({required this.booking});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = booking.propertyImageUrl?.isNotEmpty == true;
    final ini = booking.guest.displayName.isNotEmpty
        ? booking.guest.displayName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasPhoto
                ? CachedNetworkImage(
                    imageUrl: booking.propertyImageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.propertyName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: _primary.withValues(alpha: 0.12),
                      child: Text(
                        ini,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        booking.guest.displayName,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.bookingCode,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.pool_outlined,
            color: Colors.grey.shade300, size: 28),
      );
}

// ─── Condition selection card ─────────────────────────────────────

class _ConditionCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? selectedAccent;
  final Color? selectedBorder;
  final Color? selectedBackground;

  static const _primary = Color(0xFF2D9D91);

  const _ConditionCard({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selectedAccent,
    this.selectedBorder,
    this.selectedBackground,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selectedAccent ?? _primary;
    final borderColor = selectedBorder ?? _primary;
    final bg = selectedBackground ?? _primary.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? borderColor : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? accent : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? accent : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
