import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EspacioHostCard extends StatefulWidget {
  final String nombre;
  final String ubicacion;
  final double precioPorDia;
  final double rating;
  final int totalReservas;
  final bool isActivo;
  final List<String> fotos;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final ValueChanged<bool>? onToggleStatus;

  const EspacioHostCard({
    super.key,
    required this.nombre,
    required this.ubicacion,
    required this.precioPorDia,
    this.rating = 0.0,
    this.totalReservas = 0,
    this.isActivo = true,
    this.fotos = const [],
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
  });

  @override
  State<EspacioHostCard> createState() => _EspacioHostCardState();
}

class _EspacioHostCardState extends State<EspacioHostCard> {
  static const _autoScrollDuration = Duration(seconds: 4);
  static const _pageAnimationDuration = Duration(milliseconds: 500);
  static const Color primary = Color(0xFF2D9D91);

  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  List<String> get _displayFotos =>
      widget.fotos.isEmpty
          ? ['placeholder']
          : widget.fotos;

  List<String> get _extendedFotos {
    if (_displayFotos.length <= 1) return _displayFotos;
    return [_displayFotos.last, ..._displayFotos, _displayFotos.first];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _displayFotos.length > 1 ? 1 : 0);
    if (_displayFotos.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (_) {
      if (!_pageController.hasClients) return;
      final nextPage = _pageController.page!.round() + 1;
      _pageController.animateToPage(
        nextPage,
        duration: _pageAnimationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _handlePageChanged(int index) async {
    if (_displayFotos.length <= 1) return;
    _startAutoScroll();

    final lastIndex = _displayFotos.length;
    setState(() {
      if (index == 0) {
        _currentIndex = lastIndex - 1;
      } else if (index == lastIndex + 1) {
        _currentIndex = 0;
      } else {
        _currentIndex = index - 1;
      }
    });

    await Future.delayed(_pageAnimationDuration);
    if (!mounted) return;

    if (index == 0) {
      _pageController.jumpToPage(lastIndex);
    } else if (index == lastIndex + 1) {
      _pageController.jumpToPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarousel(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: _displayFotos.length > 1
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: _extendedFotos.length,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (_, index) => _buildImage(_extendedFotos[index]),
                )
              : _buildImage(_displayFotos.first),
        ),

        // Status badge
        Positioned(
          top: 12,
          left: 12,
          child: _StatusBadge(
            isActivo: widget.isActivo,
            onToggle: widget.onToggleStatus,
          ),
        ),

        // Edit button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onEdit?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),

        // Page indicators
        if (_displayFotos.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _displayFotos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String url) {
    if (url == 'placeholder') {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.pool_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final precio = NumberFormat("#,##0", "es_MX").format(widget.precioPorDia);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.rating > 0) ...[
                const Icon(Icons.star_rounded, color: Color(0xFFE5A84B), size: 18),
                const SizedBox(width: 4),
                Text(
                  widget.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.ubicacion,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$$precio',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              Text(
                ' / día',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.totalReservas} reservas',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

class _StatusBadge extends StatelessWidget {
  final bool isActivo;
  final ValueChanged<bool>? onToggle;

  const _StatusBadge({
    required this.isActivo,
    this.onToggle,
  });

  static const Color primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle?.call(!isActivo);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActivo ? primary : Colors.grey.shade600,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActivo ? Colors.greenAccent.shade200 : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isActivo ? 'Activo' : 'Pausado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
