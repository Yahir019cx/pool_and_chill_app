import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final GuestBooking booking;

  const BookingDetailScreen({super.key, required this.booking});

  static const _brandColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Detalle de Reserva',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildQrCard(),
            const SizedBox(height: 16),
            _buildHint(),
            const SizedBox(height: 16),
            _buildHostCard(),
          ],
        ),
      ),
    );
  }

  // ─── Header card (code + property) ──────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Booking code chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              booking.bookingCode,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _brandColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            booking.propertyName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          if (booking.bookingDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildBookingDateRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingDateRow() {
    String label;
    try {
      final d = DateTime.parse(booking.bookingDate);
      label = DateFormat('d MMM yyyy', 'es_MX').format(d);
    } catch (_) {
      label = booking.bookingDate;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_note_outlined, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ─── QR code card ────────────────────────────────────────────────

  Widget _buildQrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
            child: QrImageView(
              data: booking.qrCodeData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black87,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hint banner ─────────────────────────────────────────────────

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _brandColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _brandColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: _brandColor,
            size: 30,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muestra este código al anfitrión',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _brandColor,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tu anfitrión lo escaneará para confirmar el inicio de tu renta. Asegúrate de tener buena iluminación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2D7A7A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Host card ───────────────────────────────────────────────────

  Widget _buildHostCard() {
    final host = booking.host;
    final initials = host.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _brandColor.withValues(alpha: 0.12),
                backgroundImage: (host.profileImageUrl != null &&
                        host.profileImageUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(host.profileImageUrl!)
                    : null,
                child: (host.profileImageUrl == null ||
                        host.profileImageUrl!.isEmpty)
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _brandColor,
                        ),
                      )
                    : null,
              ),
              if (host.isIdentityVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: _brandColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu anfitrión',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                host.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (host.isIdentityVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 12, color: _brandColor),
                      const SizedBox(width: 3),
                      Text(
                        'Identidad verificada',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
