import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';

class BookingCard extends StatelessWidget {
  final GuestBooking booking;
  final VoidCallback? onTap;

  const BookingCard({super.key, required this.booking, this.onTap});

  static const _brandColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    final isTappable = booking.status.id == 2 && onTap != null;

    return GestureDetector(
      onTap: isTappable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  // ─── Image header ───────────────────────────────────────────────

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          if (booking.propertyImageUrl != null && booking.propertyImageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: booking.propertyImageUrl!,
              height: 175,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) => _imageFallback(),
              errorWidget: (_, _, _) => _imageFallback(),
            )
          else
            _imageFallback(),
          // Gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Status badge
          Positioned(
            top: 12,
            left: 12,
            child: _StatusBadge(statusId: booking.status.id),
          ),
          // Arrow hint for tappable cards
          if (booking.status.id == 2)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 16,
                  color: _brandColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 175,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(Icons.pool_outlined, size: 52, color: Colors.grey.shade300),
    );
  }

  // ─── Content body ───────────────────────────────────────────────

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property name
          Text(
            booking.propertyName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Dates row + rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDates()),
              const SizedBox(width: 8),
              _buildRating(),
            ],
          ),
          const SizedBox(height: 12),
          // Price
          _buildPrice(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1),
          ),
          // Host
          _buildHost(),
        ],
      ),
    );
  }

  /// Parsea un campo de hora que puede venir como "HH:mm:ss" o como
  /// ISO timestamp "1970-01-01T10:00:00.000Z". Devuelve "HH:mm".
  static String _parseTime(String raw) {
    if (raw.isEmpty) return '';
    // Formato simple "HH:mm(:ss)" — empieza con dígitos y ":"
    if (RegExp(r'^\d{1,2}:\d{2}').hasMatch(raw)) {
      return raw.substring(0, raw.length >= 5 ? 5 : raw.length);
    }
    // ISO timestamp (e.g. "1970-01-01T10:00:00.000Z")
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildDates() {
    final fmt = DateFormat('d MMM yyyy', 'es_MX');
    List<Widget> rows = [];

    if (booking.bookingType == 'hourly') {
      // Para rentas por hora checkInDate puede venir NULL → usar bookingDate
      final rawDate = booking.bookingDate.isNotEmpty
          ? booking.bookingDate
          : booking.checkInDate;
      String dateStr;
      try {
        dateStr = rawDate.isNotEmpty ? fmt.format(DateTime.parse(rawDate)) : '';
      } catch (_) {
        dateStr = rawDate;
      }
      if (dateStr.isNotEmpty) {
        rows.add(_dateRow(Icons.event_note_outlined, dateStr));
      }
      final start = _parseTime(booking.bookingStartTime);
      final end = _parseTime(booking.bookingEndTime);
      // Mostrar horas solo si start tiene valor y end no es medianoche vacía
      final showEnd = end.isNotEmpty && end != '00:00';
      if (start.isNotEmpty) {
        rows.add(const SizedBox(height: 4));
        rows.add(_dateRow(
          Icons.access_time_outlined,
          showEnd ? '$start – $end' : start,
        ));
      }
    } else {
      String checkIn, checkOut;
      try {
        checkIn = fmt.format(DateTime.parse(booking.checkInDate));
        checkOut = fmt.format(DateTime.parse(booking.checkOutDate));
      } catch (_) {
        checkIn = booking.checkInDate;
        checkOut = booking.checkOutDate;
      }
      rows.add(_dateRow(Icons.login_outlined, checkIn));
      rows.add(const SizedBox(height: 4));
      rows.add(_dateRow(Icons.logout_outlined, checkOut));
      if (booking.numberOfNights > 0) {
        rows.add(const SizedBox(height: 4));
        rows.add(_dateRow(
          Icons.nights_stay_outlined,
          '${booking.numberOfNights} ${booking.numberOfNights == 1 ? 'noche' : 'noches'}',
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _dateRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRating() {
    final hasRating = booking.propertyRating.average > 0;
    if (!hasRating) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3CA2A2).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Nueva',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _brandColor,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB700)),
            const SizedBox(width: 2),
            Text(
              booking.propertyRating.average.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          '${booking.propertyRating.totalReviews} reseñas',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    final fmt = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total pagado',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          '${fmt.format(booking.totalGuestPayment)} MXN',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _brandColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHost() {
    final host = booking.host;
    final initials = host.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFF3CA2A2).withValues(alpha: 0.12),
              backgroundImage:
                  host.profileImageUrl != null && host.profileImageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(host.profileImageUrl!)
                      : null,
              child: (host.profileImageUrl == null || host.profileImageUrl!.isEmpty)
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 13,
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
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: _brandColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anfitrión',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                host.displayName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (booking.status.id == 2)
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: Colors.grey.shade400,
          ),
      ],
    );
  }
}

// ─── Status Badge ───────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final int statusId;
  const _StatusBadge({required this.statusId});

  @override
  Widget build(BuildContext context) {
    final (label, bg) = switch (statusId) {
      2 => ('Próxima', const Color(0xFF3CA2A2)),
      4 => ('Pasada', Colors.grey.shade600),
      5 || 6 => ('Cancelada', Colors.red.shade400),
      _ => ('Sin estado', Colors.grey.shade400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
