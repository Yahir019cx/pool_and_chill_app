import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider_pkg;

import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/host_reservas_provider.dart';

import 'guest_review_screen.dart';
import 'host_qr_scanner_screen.dart';

enum _HostFilter { proximas, pasadas, canceladas }

class ReservasHostScreen extends ConsumerStatefulWidget {
  const ReservasHostScreen({super.key});

  @override
  ConsumerState<ReservasHostScreen> createState() => _ReservasHostScreenState();
}

class _ReservasHostScreenState extends ConsumerState<ReservasHostScreen> {
  _HostFilter _filter = _HostFilter.proximas;

  static const _primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      ref.read(hostReservasProvider.notifier).load();
    }
  }

  List<HostBooking> _filtered(List<HostBooking> bookings) => switch (_filter) {
        _HostFilter.proximas => bookings.where((b) => b.status.id == 2).toList(),
        _HostFilter.pasadas => bookings.where((b) => b.status.id == 4).toList(),
        _HostFilter.canceladas =>
          bookings.where((b) => b.status.id == 5 || b.status.id == 6).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostReservasProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Reservas',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _FilterToggle(
              current: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 4),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HostReservasState state) {
    if (state.isLoading && state.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
      );
    }

    if (state.error != null && state.bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No se pudieron cargar las reservas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Revisa tu conexión e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(foregroundColor: _primary),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered(state.bookings);

    if (filtered.isEmpty) return _buildEmptyFilter();

    return RefreshIndicator(
      color: _primary,
      onRefresh: () => ref.read(hostReservasProvider.notifier).load(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _HostReservaCard(
          booking: filtered[i],
          onTap: () => _handleTap(filtered[i]),
        ),
      ),
    );
  }

  void _handleTap(HostBooking booking) {
    if (booking.status.id == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HostQrScannerScreen(booking: booking)),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _DetailSheet(booking: booking),
      );
    }
  }

  Widget _buildEmptyFilter() {
    final (icon, title, subtitle) = switch (_filter) {
      _HostFilter.proximas => (
          Icons.event_note_outlined,
          'Sin reservas próximas',
          'Cuando recibas una reserva confirmada aparecerá aquí.',
        ),
      _HostFilter.pasadas => (
          Icons.history_rounded,
          'Sin reservas pasadas',
          'Aquí aparecerán tus reservas completadas.',
        ),
      _HostFilter.canceladas => (
          Icons.cancel_outlined,
          'Sin cancelaciones',
          '¡Todo en orden! No hay reservas canceladas.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Toggle ───────────────────────────────────────────────────────────

class _FilterToggle extends StatelessWidget {
  final _HostFilter current;
  final ValueChanged<_HostFilter> onChanged;

  const _FilterToggle({required this.current, required this.onChanged});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _tab('Próximas', _HostFilter.proximas),
            _tab('Pasadas', _HostFilter.pasadas),
            _tab('Canceladas', _HostFilter.canceladas),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, _HostFilter filter) {
    final isActive = current == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

String _initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .take(2)
    .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
    .join();

String _parseTime(String raw) {
  if (raw.isEmpty) return '';
  if (RegExp(r'^\d{2}:\d{2}').hasMatch(raw)) return raw.substring(0, 5);
  try {
    final dt = DateTime.parse(raw).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '';
  }
}

String _timeRange(String start, String end) {
  final s = _parseTime(start);
  if (s.isEmpty) return '';
  final e = _parseTime(end);
  return (e.isNotEmpty && e != '00:00') ? '$s – $e' : s;
}

String _fmtDate(String raw, {String pattern = 'd MMM yyyy'}) {
  if (raw.isEmpty) return '—';
  try {
    return DateFormat(pattern, 'es_MX').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

// ─── Card Image ───────────────────────────────────────────────────────────────

class _CardImage extends StatelessWidget {
  final String? imageUrl;
  final bool isToday;
  final bool showQr;
  final bool showReviewHint;

  const _CardImage({
    this.imageUrl,
    required this.isToday,
    required this.showQr,
    this.showReviewHint = false,
  });

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: (imageUrl?.isNotEmpty == true)
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _fallback(),
                    errorWidget: (_, _, _) => _fallback(),
                  )
                : _fallback(),
          ),
          if (isToday)
            Positioned(
              top: 12, left: 12,
              child: _Chip(label: 'Hoy', color: _primary),
            ),
          if (showQr)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, size: 16, color: _primary),
              ),
            ),
          if (showReviewHint)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Calificar huésped',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
        height: 150,
        color: Colors.grey.shade100,
        child: Icon(Icons.pool_outlined, color: Colors.grey.shade300, size: 40),
      );
}

// ─── Chip badge ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }
}

// ─── Guest Row ────────────────────────────────────────────────────────────────

class _GuestRow extends StatelessWidget {
  final HostBookingGuest guest;
  final double radius;

  const _GuestRow({required this.guest, this.radius = 18});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final ini = _initials(guest.displayName);
    final hasPhoto = guest.profileImageUrl?.isNotEmpty == true;

    return Row(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: _primary.withValues(alpha: 0.12),
          backgroundImage: hasPhoto ? CachedNetworkImageProvider(guest.profileImageUrl!) : null,
          child: !hasPhoto
              ? Text(ini, style: TextStyle(fontSize: radius * 0.65, fontWeight: FontWeight.w700, color: _primary))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guest.displayName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              if (guest.rating.totalReviews > 0)
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB700)),
                    const SizedBox(width: 2),
                    Text(
                      '${guest.rating.average.toStringAsFixed(1)} (${guest.rating.totalReviews})',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }
}

// ─── Host Reserva Card ───────────────────────────────────────────────────────

class _HostReservaCard extends StatelessWidget {
  final HostBooking booking;
  final VoidCallback onTap;

  const _HostReservaCard({required this.booking, required this.onTap});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final isProxima = booking.status.id == 2;
    final isPasada = booking.status.id == 4;
    final isCancelada = booking.status.id == 5 || booking.status.id == 6;
    final dateRaw = booking.bookingDate.isNotEmpty ? booking.bookingDate : booking.checkInDate;
    final timeRange = _timeRange(booking.bookingStartTime, booking.bookingEndTime);
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(
              imageUrl: booking.propertyImageUrl,
              isToday: booking.isToday,
              showQr: isProxima,
              showReviewHint: isPasada,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.propertyName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.event_note_outlined, size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(_fmtDate(dateRaw), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      if (timeRange.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            timeRange,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isProxima && !isCancelada && booking.payout.hostPayout > 0) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Text('Ganancia:', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(width: 6),
                      Text('${fmt.format(booking.payout.hostPayout)} MXN',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _primary)),
                    ]),
                  ],
                  if (isCancelada) ...[
                    const SizedBox(height: 6),
                    _Chip(label: 'Cancelada', color: Colors.red.shade400),
                  ],
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _GuestRow(guest: booking.guest),
                  if (isProxima) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HostQrScannerScreen(booking: booking),
                          ),
                        ),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        label: const Text('Escanear QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────

class _DetailSheet extends StatelessWidget {
  final HostBooking booking;

  const _DetailSheet({required this.booking});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final isPasada = booking.status.id == 4;
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 0);
    final dateRaw = booking.bookingDate.isNotEmpty ? booking.bookingDate : booking.checkInDate;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            // Property image
            if (booking.propertyImageUrl?.isNotEmpty == true) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: booking.propertyImageUrl!,
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.propertyName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _GuestRow(guest: booking.guest, radius: 22),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Código', value: booking.bookingCode),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Fecha', value: _fmtDate(dateRaw)),
                  const SizedBox(height: 8),
                  _DetailRow(label: 'Horario', value: _timeRange(booking.bookingStartTime, booking.bookingEndTime)),
                  if (booking.payout.hostPayout > 0) ...[
                    const SizedBox(height: 8),
                    _DetailRow(label: 'Ganancia', value: '${fmt.format(booking.payout.hostPayout)} MXN', valueColor: _primary),
                  ],
                  const SizedBox(height: 24),
                  if (isPasada)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GuestReviewScreen(booking: booking),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_rounded, size: 18),
                        label: const Text('Calificar huésped'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
