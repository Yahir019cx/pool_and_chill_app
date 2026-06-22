import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

/// Genera un [BitmapDescriptor] personalizado que muestra el precio de la propiedad.
///
/// Estados:
/// - [selected] = false → píldora blanca con texto oscuro
/// - [selected] = true  → píldora con color primario (#3CA2A2) y texto blanco
Future<BitmapDescriptor> buildPricePin(
  double price, {
  bool selected = false,
}) async {
  final label = '\$${NumberFormat('#,##0', 'es_MX').format(price)}';

  const paddingH = 14.0;
  const paddingV = 8.0;
  const fontSize = 13.0;
  const fontWeight = FontWeight.w700;

  // Mide el texto para determinar el ancho del pin.
  final textPainter = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: selected ? Colors.white : const Color(0xFF1A1A2E),
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();

  final pinW = textPainter.width + paddingH * 2;
  final pinH = textPainter.height + paddingV * 2;

  // Escala para pantallas de alta densidad.
  const scale = 2.0;
  final totalW = (pinW * scale).ceil();
  final totalH = (pinH * scale).ceil();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(scale, scale);

  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, pinW, pinH),
    const Radius.circular(20),
  );

  // Sombra sutil
  final shadowPath = Path()..addRRect(rect);
  canvas.drawShadow(shadowPath, Colors.black, selected ? 4 : 2, false);

  // Fondo de la píldora
  final bgPaint = Paint()
    ..color = selected ? const Color(0xFF3CA2A2) : Colors.white;
  canvas.drawRRect(rect, bgPaint);

  // Borde (solo en estado normal para dar definición)
  if (!selected) {
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // Texto del precio
  textPainter.paint(canvas, Offset(paddingH, paddingV));

  final picture = recorder.endRecording();
  final image = await picture.toImage(totalW, totalH);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.bytes(
    byteData!.buffer.asUint8List(),
    width: pinW,
    height: pinH,
  );
}
