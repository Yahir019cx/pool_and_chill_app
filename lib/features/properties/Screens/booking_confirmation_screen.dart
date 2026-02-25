import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingCode;
  final String propertyName;
  final String datesLabel;
  final double totalPaid;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingCode,
    required this.propertyName,
    required this.datesLabel,
    required this.totalPaid,
  });

  String _formatMXN(double amount) {
    final fmt = NumberFormat('#,##0.00', 'es_MX');
    return '\$${fmt.format(amount)} MXN';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 48),

                  // Success icon
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: kDetailPrimary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 56,
                        color: kDetailPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      '¡Reserva confirmada!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kDetailDark,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Tu pago fue procesado exitosamente.',
                      style: TextStyle(
                        fontSize: 15,
                        color: kDetailGreyLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Booking code card
                  _buildCard(
                    child: Column(
                      children: [
                        const Text(
                          'Código de reserva',
                          style: TextStyle(
                            fontSize: 13,
                            color: kDetailGreyLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bookingCode,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: kDetailPrimary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Details card
                  _buildCard(
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.home_outlined,
                          'Propiedad',
                          propertyName,
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          Icons.calendar_today_outlined,
                          'Fechas',
                          datesLabel,
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          Icons.payments_outlined,
                          'Total pagado',
                          _formatMXN(totalPaid),
                          valueColor: kDetailDark,
                          valueBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email note
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kDetailPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 18, color: kDetailPrimary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Te enviamos un correo con el código QR de tu reserva. Preséntalo al llegar a la propiedad.',
                            style: TextStyle(
                              fontSize: 13,
                              color: kDetailPrimary.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding:
                  EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop all the way back to the main navigator root
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDetailPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kDetailGreyLight),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: kDetailGreyLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? kDetailDark,
                  fontWeight:
                      valueBold ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
