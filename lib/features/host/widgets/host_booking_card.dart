import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/features/host/screens/host_qr_scanner_screen.dart';

class HostBookingCard extends StatelessWidget {
  final HostBooking booking;

  const HostBookingCard({super.key, required this.booking});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final guest = booking.guest;
    final initials = _initials(guest.displayName);
    final timeLabel = _buildTimeLabel();
    final dateLabel = _buildDateLabel();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HostQrScannerScreen(booking: booking),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Guest avatar
            _buildAvatar(guest, initials),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Hoy badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          guest.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (booking.isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Hoy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Property name
                  Text(
                    booking.propertyName,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Date + time
                  Row(
                    children: [
                      if (!booking.isToday && dateLabel.isNotEmpty) ...[
                        Icon(
                          Icons.event_note_outlined,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (timeLabel.isNotEmpty) ...[
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // QR scanner icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: _primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(HostBookingGuest guest, String initials) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _primary.withValues(alpha: 0.1),
          backgroundImage:
              (guest.profileImageUrl != null && guest.profileImageUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(guest.profileImageUrl!)
                  : null,
          child: (guest.profileImageUrl == null || guest.profileImageUrl!.isEmpty)
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                )
              : null,
        ),
        if (guest.rating.totalReviews > 0)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 9, color: Color(0xFFE5A84B)),
                  const SizedBox(width: 1),
                  Text(
                    guest.rating.average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
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

  String _buildTimeLabel() {
    final start = _parseTime(booking.bookingStartTime);
    if (start.isEmpty) return '';
    final end = _parseTime(booking.bookingEndTime);
    final showEnd = end.isNotEmpty && end != '00:00';
    return showEnd ? '$start – $end' : start;
  }

  String _buildDateLabel() {
    final raw = booking.bookingDate.isNotEmpty
        ? booking.bookingDate
        : booking.checkInDate;
    if (raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw);
      return DateFormat('d MMM', 'es_MX').format(d);
    } catch (_) {
      return raw;
    }
  }

  static String _parseTime(String raw) {
    if (raw.isEmpty) return '';
    // Acepta "H:mm", "HH:mm", "HH:mm:ss", etc.
    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(raw)) {
      return raw.substring(0, raw.length >= 5 ? 5 : raw.length);
    }
    // ISO timestamp fallback (e.g. "1970-01-01T10:00:00.000Z")
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
