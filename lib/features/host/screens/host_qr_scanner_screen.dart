import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';

class HostQrScannerScreen extends StatefulWidget {
  final HostBooking booking;

  const HostQrScannerScreen({super.key, required this.booking});

  @override
  State<HostQrScannerScreen> createState() => _HostQrScannerScreenState();
}

class _HostQrScannerScreenState extends State<HostQrScannerScreen> {
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

    setState(() {
      _scanned = true;
    });
    _controller.stop();
    _showResultSheet(barcode.rawValue!);
  }

  void _showResultSheet(String value) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        scannedValue: value,
        booking: widget.booking,
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _scanned = false;
          });
          _controller.start();
        },
        onDone: () {
          Navigator.pop(context); // sheet
          Navigator.pop(context); // scanner screen
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
                final torchOn =
                    value.torchState == TorchState.on;
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
          // Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay with cutout
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
            // Dark overlay with transparent cutout hole
            CustomPaint(
              size: Size(w, h),
              painter: _OverlayPainter(
                cutout: RRect.fromLTRBR(
                  left, top,
                  left + _cutoutSize, top + _cutoutSize,
                  const Radius.circular(16),
                ),
              ),
            ),

            // Top info banner
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

            // Cutout border + corner accents
            Positioned(
              left: left,
              top: top,
              child: SizedBox(
                width: _cutoutSize,
                height: _cutoutSize,
                child: CustomPaint(painter: _CornerPainter()),
              ),
            ),

            // Bottom hint
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

// ─── Overlay painter (dark mask with transparent hole) ────────────

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

    // top-left
    canvas.drawLine(
        const Offset(radius, 0), const Offset(radius + len, 0), paint);
    canvas.drawLine(
        const Offset(0, radius), const Offset(0, radius + len), paint);
    // top-right
    canvas.drawLine(Offset(size.width - radius, 0),
        Offset(size.width - radius - len, 0), paint);
    canvas.drawLine(Offset(size.width, radius),
        Offset(size.width, radius + len), paint);
    // bottom-left
    canvas.drawLine(Offset(radius, size.height),
        Offset(radius + len, size.height), paint);
    canvas.drawLine(Offset(0, size.height - radius),
        Offset(0, size.height - radius - len), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width - radius, size.height),
        Offset(size.width - radius - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - radius),
        Offset(size.width, size.height - radius - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Result Bottom Sheet ──────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  final String scannedValue;
  final HostBooking booking;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _ResultSheet({
    required this.scannedValue,
    required this.booking,
    required this.onRetry,
    required this.onDone,
  });

  static const _primary = Color(0xFF2D9D91);

  bool get _isMatch => scannedValue == booking.bookingCode ||
      scannedValue.contains(booking.bookingCode) ||
      scannedValue.contains(booking.bookingId);

  @override
  Widget build(BuildContext context) {
    final match = _isMatch;

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
              match
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
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
                ? 'El código del huésped coincide con la reserva ${booking.bookingCode}.'
                : 'El código escaneado no coincide con esta reserva. Verifica con el huésped.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Guest + booking info chip
          Container(
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
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
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
          ),
          const SizedBox(height: 24),

          // Actions
          if (!match)
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Escanear de nuevo',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
          if (!match) const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: match ? _primary : Colors.grey.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              match ? 'Confirmar entrada' : 'Cerrar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
