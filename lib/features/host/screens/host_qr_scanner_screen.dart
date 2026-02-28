import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/booking_service.dart';

class HostQrScannerScreen extends ConsumerStatefulWidget {
  final HostBooking booking;

  const HostQrScannerScreen({super.key, required this.booking});

  @override
  ConsumerState<HostQrScannerScreen> createState() =>
      _HostQrScannerScreenState();
}

class _HostQrScannerScreenState extends ConsumerState<HostQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _scanned = true);
    _controller.stop();
    _showResultSheet(barcode.rawValue!);
  }

  void _showResultSheet(String value) {
    final service = ref.read(bookingServiceProvider);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        scannedValue: value,
        booking: widget.booking,
        service: service,
        onRetry: () {
          Navigator.pop(context);
          setState(() => _scanned = false);
          _controller.start();
        },
        // true = check-in registered, false = cancelled/mismatch
        onDone: (bool checkInSuccess) {
          Navigator.pop(context); // sheet
          Navigator.pop(context, checkInSuccess); // scanner screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Escanear QR del huésped',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, value, _) {
                final torchOn = value.torchState == TorchState.on;
                return Icon(
                  torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: torchOn ? Colors.amber : Colors.white,
                );
              },
            ),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _ScannerOverlay(
            guestName: widget.booking.guest.displayName,
            propertyName: widget.booking.propertyName,
          ),
        ],
      ),
    );
  }
}

// ─── Scanner Overlay ──────────────────────────────────────────────

class _ScannerOverlay extends StatelessWidget {
  final String guestName;
  final String propertyName;

  const _ScannerOverlay({
    required this.guestName,
    required this.propertyName,
  });

  static const _cutoutSize = 240.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final left = (w - _cutoutSize) / 2;
        final top = (h - _cutoutSize) / 2;

        return Stack(
          children: [
            CustomPaint(
              size: Size(w, h),
              painter: _OverlayPainter(
                cutout: RRect.fromLTRBR(
                  left,
                  top,
                  left + _cutoutSize,
                  top + _cutoutSize,
                  const Radius.circular(16),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.black.withValues(alpha: 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      propertyName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: SizedBox(
                width: _cutoutSize,
                height: _cutoutSize,
                child: CustomPaint(painter: _CornerPainter()),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                color: Colors.black.withValues(alpha: 0.6),
                child: const Text(
                  'Apunta la cámara al código QR del huésped',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Overlay painter ──────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final RRect cutout;
  const _OverlayPainter({required this.cutout});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x99000000);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => old.cutout != cutout;
}

// ─── Corner accent painter ────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    const stroke = 4.0;
    const radius = 16.0;
    final paint = Paint()
      ..color = const Color(0xFF2D9D91)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        const Offset(radius, 0), const Offset(radius + len, 0), paint);
    canvas.drawLine(
        const Offset(0, radius), const Offset(0, radius + len), paint);
    canvas.drawLine(Offset(size.width - radius, 0),
        Offset(size.width - radius - len, 0), paint);
    canvas.drawLine(Offset(size.width, radius),
        Offset(size.width, radius + len), paint);
    canvas.drawLine(Offset(radius, size.height),
        Offset(radius + len, size.height), paint);
    canvas.drawLine(Offset(0, size.height - radius),
        Offset(0, size.height - radius - len), paint);
    canvas.drawLine(Offset(size.width - radius, size.height),
        Offset(size.width - radius - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - radius),
        Offset(size.width, size.height - radius - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Result Bottom Sheet ──────────────────────────────────────────

enum _SheetStatus { idle, loading, success, error }

class _ResultSheet extends StatefulWidget {
  final String scannedValue;
  final HostBooking booking;
  final BookingService service;
  final VoidCallback onRetry;
  final void Function(bool) onDone;

  const _ResultSheet({
    required this.scannedValue,
    required this.booking,
    required this.service,
    required this.onRetry,
    required this.onDone,
  });

  @override
  State<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<_ResultSheet> {
  static const _primary = Color(0xFF2D9D91);

  _SheetStatus _status = _SheetStatus.idle;
  String? _errorMessage;
  CheckInData? _checkInData;

  bool get _isMatch =>
      widget.scannedValue == widget.booking.bookingCode ||
      widget.scannedValue.contains(widget.booking.bookingCode) ||
      widget.scannedValue.contains(widget.booking.bookingId);

  /// El QR contiene: [BookingCode][ID_Booking][3 sep][64 chars = hash].
  /// El backend espera exactamente esos últimos 64 caracteres en minúsculas.
  String _extractQrHash(String qrContent) {
    final s = qrContent.trim();
    if (s.length < 64) return s.toLowerCase();
    return s.substring(s.length - 64).toLowerCase();
  }

  Future<void> _confirmCheckIn() async {
    setState(() {
      _status = _SheetStatus.loading;
      _errorMessage = null;
    });
    try {
      final result = await widget.service.checkIn(CheckInRequest(
        bookingCode: widget.booking.bookingCode,
        bookingId: widget.booking.bookingId,
        qrHash: _extractQrHash(widget.scannedValue),
      ));
      setState(() {
        _status = _SheetStatus.success;
        _checkInData = result.data;
      });
    } catch (e) {
      setState(() {
        _status = _SheetStatus.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          if (_status == _SheetStatus.success)
            _buildSuccess()
          else
            _buildScanResult(),
        ],
      ),
    );
  }

  Widget _buildScanResult() {
    final match = _isMatch;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: match
                ? _primary.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            match ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: match ? _primary : Colors.red,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),

        Text(
          match ? 'QR verificado' : 'QR no coincide',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: match ? Colors.black87 : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          match
              ? 'El código del huésped coincide con la reserva ${widget.booking.bookingCode}.'
              : 'El código escaneado no coincide con esta reserva. Verifica con el huésped.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),

        // API error banner
        if (_status == _SheetStatus.error && _errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
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

        const SizedBox(height: 28),

        // Guest + booking info chip
        _BookingInfoChip(booking: widget.booking),

        const SizedBox(height: 24),

        // Actions
        if (_status == _SheetStatus.error) ...[
          ElevatedButton(
            onPressed: _confirmCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: widget.onRetry,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Escanear de nuevo',
              style: TextStyle(
                  color: _primary, fontWeight: FontWeight.w600),
            ),
          ),
        ] else ...[
          if (!match) ...[
            OutlinedButton(
              onPressed: widget.onRetry,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Escanear de nuevo',
                style: TextStyle(
                    color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton(
            onPressed: _status == _SheetStatus.loading
                ? null
                : match
                    ? _confirmCheckIn
                    : () => widget.onDone(false),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  match ? _primary : Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _status == _SheetStatus.loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    match ? 'Confirmar entrada' : 'Cerrar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.login_rounded, color: _primary, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Check-in registrado',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          _checkInData?.message.isNotEmpty == true
              ? _checkInData!.message
              : '¡Bienvenido al espacio!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 28),
        _BookingInfoChip(booking: widget.booking),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => widget.onDone(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text(
            'Listo',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// ─── Booking info chip (shared between scan result and success) ───

class _BookingInfoChip extends StatelessWidget {
  final HostBooking booking;

  const _BookingInfoChip({required this.booking});

  static const _primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded,
              size: 18, color: _primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.guest.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  booking.propertyName,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.bookingCode,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
