import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/features/properties/Screens/booking_confirmation_screen.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

class BookingReviewScreen extends StatefulWidget {
  final CreateBookingResponse bookingResponse;
  final String propertyName;

  /// Fechas formateadas para mostrar en el resumen.
  final String datesLabel;

  const BookingReviewScreen({
    super.key,
    required this.bookingResponse,
    required this.propertyName,
    required this.datesLabel,
  });

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  bool _isPaying = false;

  BookingPricing get _pricing => widget.bookingResponse.data.pricing;

  String _formatMXN(double amount) {
    final fmt = NumberFormat('#,##0.00', 'es_MX');
    return '\$${fmt.format(amount)} MXN';
  }

  Future<void> _pay() async {
    setState(() => _isPaying = true);
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              widget.bookingResponse.data.payment.clientSecret,
          merchantDisplayName: 'Pool & Chill',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingCode: widget.bookingResponse.data.booking.bookingCode,
            propertyName: widget.propertyName,
            datesLabel: widget.datesLabel,
            totalPaid: _pricing.totalGuestPayment,
          ),
        ),
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      final msg = e.error.localizedMessage ??
          e.error.message ??
          'El pago fue cancelado';
      TopChip.showError(context, msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      TopChip.showError(context, 'Ocurrió un error al procesar el pago');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kDetailDark,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Resumen de reserva',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDetailDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Property + dates card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.propertyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kDetailDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.event_note_outlined,
                        size: 16, color: kDetailGreyLight),
                    const SizedBox(width: 6),
                    Text(
                      widget.datesLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kDetailGreyLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pricing breakdown card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desglose de precio',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kDetailDark,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPricingRow(
                  'Precio base',
                  _formatMXN(_pricing.basePrice),
                ),
                const SizedBox(height: 10),
                _buildPricingRow(
                  'Cargo por servicio (5%)',
                  _formatMXN(_pricing.guestServiceFee),
                ),
                const SizedBox(height: 10),
                _buildPricingRow(
                  'IVA (16%)',
                  _formatMXN(_pricing.totalIVA),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1),
                ),
                _buildPricingRow(
                  'Total a pagar',
                  _formatMXN(_pricing.totalGuestPayment),
                  isBold: true,
                  valueColor: kDetailPrimary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Per-day breakdown (collapsed if only 1 day)
          if (_pricing.breakdown.length > 1)
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Desglose por noche',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kDetailDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._pricing.breakdown.map((item) {
                    final dt = DateTime.parse(item.date);
                    final label =
                        DateFormat('EEE d MMM', 'es_MX').format(dt);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPricingRow(
                        label,
                        _formatMXN(item.price),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Info note
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kDetailPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: kDetailPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tras el pago exitoso recibirás un correo con el código QR de tu reserva.',
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

          SizedBox(height: bottomPad + 100),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isPaying ? null : _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDetailPrimary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isPaying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Confirmar y pagar ${_formatMXN(_pricing.totalGuestPayment)}',
                  ),
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

  Widget _buildPricingRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final weight = isBold ? FontWeight.w700 : FontWeight.w400;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isBold ? kDetailDark : kDetailGreyLight,
            fontWeight: weight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? kDetailDark,
            fontWeight: weight,
          ),
        ),
      ],
    );
  }
}
