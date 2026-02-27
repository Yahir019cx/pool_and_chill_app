import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _TopChipType { success, error, warning, info }

class TopChip {
  static const _brandColor = Color(0xFF41838F);

  static void showSuccess(BuildContext context, String message) =>
      _show(context, message, _TopChipType.success);

  static void showError(BuildContext context, String message) =>
      _show(context, message, _TopChipType.error);

  static void showWarning(BuildContext context, String message) =>
      _show(context, message, _TopChipType.warning);

  static void showInfo(BuildContext context, String message) =>
      _show(context, message, _TopChipType.info);

  static void _show(BuildContext context, String message, _TopChipType type) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopChipOverlay(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  static Color _borderColor(_TopChipType type) {
    switch (type) {
      case _TopChipType.success:
        return _brandColor.withValues(alpha: 0.4);
      case _TopChipType.error:
        return Colors.red.shade200;
      case _TopChipType.warning:
        return Colors.orange.shade200;
      case _TopChipType.info:
        return Colors.blue.shade200;
    }
  }

  static Color _iconColor(_TopChipType type) {
    switch (type) {
      case _TopChipType.success:
        return _brandColor;
      case _TopChipType.error:
        return Colors.red.shade400;
      case _TopChipType.warning:
        return Colors.orange.shade400;
      case _TopChipType.info:
        return Colors.blue.shade400;
    }
  }

  static IconData _icon(_TopChipType type) {
    switch (type) {
      case _TopChipType.success:
        return Icons.check_circle_outline;
      case _TopChipType.error:
        return Icons.error_outline;
      case _TopChipType.warning:
        return Icons.warning_amber_rounded;
      case _TopChipType.info:
        return Icons.info_outline;
    }
  }
}

class _TopChipOverlay extends StatefulWidget {
  final String message;
  final _TopChipType type;
  final VoidCallback onDismiss;

  const _TopChipOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_TopChipOverlay> createState() => _TopChipOverlayState();
}

class _TopChipOverlayState extends State<_TopChipOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, 0.4, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8) +
                  EdgeInsets.only(top: topPadding > 0 ? 0 : 8),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () => _ctrl.reverse().then((_) => widget.onDismiss()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: TopChip._borderColor(widget.type),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          TopChip._icon(widget.type),
                          color: TopChip._iconColor(widget.type),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _ctrl.reverse().then((_) => widget.onDismiss()),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
