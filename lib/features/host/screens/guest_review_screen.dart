import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class GuestReviewScreen extends ConsumerStatefulWidget {
  final HostBooking booking;

  const GuestReviewScreen({super.key, required this.booking});

  @override
  ConsumerState<GuestReviewScreen> createState() => _GuestReviewScreenState();
}

class _GuestReviewScreenState extends ConsumerState<GuestReviewScreen> {
  static const _primary = Color(0xFF2D9D91);

  double _overallRating = 5.0;
  double _cleanlinessRating = 5.0;
  double _communicationRating = 5.0;
  double _respectRulesRating = 5.0;
  bool _wouldHostAgain = true;
  bool _isSubmitting = false;

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(bookingServiceProvider);
      final request = GuestReviewRequest(
        bookingId: widget.booking.bookingId,
        rating: _overallRating,
        cleanlinessRating: _cleanlinessRating,
        communicationRating: _communicationRating,
        respectRulesRating: _respectRulesRating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        wouldHostAgain: _wouldHostAgain,
      );

      await service.reviewGuest(request);

      if (!mounted) return;
      TopChip.showSuccess(context, 'Calificación enviada. ¡Gracias!');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg =
          e.toString().replaceAll('Exception: ', '').trim().isNotEmpty
              ? e.toString().replaceAll('Exception: ', '')
              : 'Ocurrió un error al enviar tu calificación';
      TopChip.showError(context, msg);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final guest = widget.booking.guest;
    final initials = _initials(guest.displayName);
    final hasPhoto = guest.profileImageUrl?.isNotEmpty == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Calificar huésped',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _primary.withValues(alpha: 0.1),
                  backgroundImage: hasPhoto
                      ? CachedNetworkImageProvider(guest.profileImageUrl!)
                      : null,
                  child: !hasPhoto
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comparte cómo fue tu experiencia con el huesped',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paso 1 · Calificación general',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB700),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'de 5',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _overallRating,
                  min: 1,
                  max: 5,
                  divisions: 8,
                  label: _overallRating.toStringAsFixed(1),
                  activeColor: _primary,
                  inactiveColor: _primary.withValues(alpha: 0.14),
                  onChanged: (v) {
                    setState(() {
                      _overallRating = v;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paso 2 · Detalles de la estancia',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSubRatingRow(
                  title: 'Limpieza',
                  value: _cleanlinessRating,
                  onChanged: (v) {
                    setState(() => _cleanlinessRating = v);
                  },
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Comunicación',
                  value: _communicationRating,
                  onChanged: (v) {
                    setState(() => _communicationRating = v);
                  },
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Respeto a las reglas',
                  value: _respectRulesRating,
                  onChanged: (v) {
                    setState(() => _respectRulesRating = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paso 3 · Comentario (opcional)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        '¿Algo que te gustaría destacar sobre este huésped?',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 1.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Volverías a hospedar a este huésped?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Esta respuesta nos ayuda a mantener segura a la comunidad.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: _wouldHostAgain,
                  activeColor: Colors.white,
                  activeTrackColor: _primary,
                  onChanged: (v) {
                    setState(() => _wouldHostAgain = v);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: bottomPad + 80),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Enviar calificación'),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSubRatingRow({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 8,
          label: value.toStringAsFixed(1),
          activeColor: _primary,
          inactiveColor: _primary.withValues(alpha: 0.14),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _initials(String name) {
    return name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }
}

