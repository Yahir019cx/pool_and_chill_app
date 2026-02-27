import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'guest_host_review_screen.dart';

/// Pantalla 1 del flujo de calificación: el guest califica la propiedad.
/// Al enviar, llama POST /booking/property/review y navega a [GuestHostReviewScreen].
class GuestPropertyReviewScreen extends ConsumerStatefulWidget {
  final GuestBooking booking;

  const GuestPropertyReviewScreen({super.key, required this.booking});

  @override
  ConsumerState<GuestPropertyReviewScreen> createState() =>
      _GuestPropertyReviewScreenState();
}

class _GuestPropertyReviewScreenState
    extends ConsumerState<GuestPropertyReviewScreen> {
  static const _primary = Color(0xFF3CA2A2);

  double _overallRating = 3.0;
  double _cleanlinessRating = 3.0;
  double _accuracyRating = 3.0;
  double _communicationRating = 3.0;
  double _locationRating = 3.0;
  double _valueRating = 3.0;
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
      final request = PropertyReviewRequest(
        bookingId: widget.booking.bookingId,
        overallRating: _overallRating,
        cleanlinessRating: _cleanlinessRating,
        accuracyRating: _accuracyRating,
        communicationRating: _communicationRating,
        locationRating: _locationRating,
        valueRating: _valueRating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      await service.submitPropertyReview(request);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => GuestHostReviewScreen(booking: widget.booking),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '').trim().isNotEmpty
          ? e.toString().replaceAll('Exception: ', '')
          : 'No se pudo enviar la calificación. Intenta de nuevo.';
      TopChip.showError(context, msg);
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Calificar propiedad',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.propertyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '¿Cómo fue tu experiencia en esta propiedad?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
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
                  'Calificación general',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'General',
                  value: _overallRating,
                  onChanged: (v) => setState(() => _overallRating = v),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Limpieza',
                  value: _cleanlinessRating,
                  onChanged: (v) => setState(() => _cleanlinessRating = v),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Fidelidad al anuncio',
                  value: _accuracyRating,
                  onChanged: (v) => setState(() => _accuracyRating = v),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Comunicación',
                  value: _communicationRating,
                  onChanged: (v) => setState(() => _communicationRating = v),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Ubicación',
                  value: _locationRating,
                  onChanged: (v) => setState(() => _locationRating = v),
                ),
                const SizedBox(height: 10),
                _buildSubRatingRow(
                  title: 'Relación calidad-precio',
                  value: _valueRating,
                  onChanged: (v) => setState(() => _valueRating = v),
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
                  'Comentario (opcional)',
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
                  maxLength: 2000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos más sobre tu estancia...',
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
                : const Text('Siguiente: calificar anfitrión'),
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
}
