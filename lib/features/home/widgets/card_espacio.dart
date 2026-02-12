import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pool_and_chill_app/data/models/property/search_property_model.dart';

class EspacioCard extends StatefulWidget {
  final SearchPropertyModel property;
  final bool isFavorite;

  /// Callback al pulsar el corazón. Si es `null` el botón se oculta.
  final ValueChanged<String>? onFavoriteToggle;

  /// Callback al tocar la card (abrir detalle). Si es `null` la card no es clicable.
  final ValueChanged<String>? onTap;

  const EspacioCard({
    super.key,
    required this.property,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<EspacioCard> createState() => _EspacioCardState();
}

class _EspacioCardState extends State<EspacioCard> {
  static const _autoScrollDuration = Duration(seconds: 4);
  static const _pageAnimationDuration = Duration(milliseconds: 500);

  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  List<String> get _fotos => widget.property.imageUrls;

  List<String> get _extendedFotos {
    if (_fotos.isEmpty) return [];
    if (_fotos.length == 1) return _fotos;
    return [_fotos.last, ..._fotos, _fotos.first];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _fotos.length > 1 ? 1 : 0);
    if (_fotos.length > 1) _startAutoScroll();
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
    if (_fotos.length <= 1) return;
    _startAutoScroll();

    final lastIndex = _fotos.length;
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
    final precio =
        NumberFormat("#,##0", "es_MX").format(widget.property.priceFrom);

    final card = Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildCarousel(),
          _buildInfo(precio),
        ],
      ),
    );

    if (widget.onTap == null) return card;
    return GestureDetector(
      onTap: () => widget.onTap!(widget.property.propertyId),
      child: card,
    );
  }

  Widget _buildCarousel() {
    final fotos = _fotos;
    final extended = _extendedFotos;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: fotos.isEmpty
              ? Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: extended.length,
                  onPageChanged: _handlePageChanged,
                  itemBuilder: (_, index) {
                    return CachedNetworkImage(
                      imageUrl: extended[index],
                      fit: BoxFit.cover,
                      memCacheWidth: 600,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF3CA2A2),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Botón favorito
        if (widget.onFavoriteToggle != null)
          Positioned(
            top: 8,
            right: 8,
            child: _FavoriteButton(
              isFavorite: widget.isFavorite,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onFavoriteToggle!(widget.property.propertyId);
              },
            ),
          ),

        // Indicadores de página
        if (fotos.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 16 : 6,
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

  Widget _buildInfo(String precio) {
    final prop = widget.property;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.propertyName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (prop.location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    prop.location,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  "Desde \$$precio MXN",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E838C),
                  ),
                ),
                if (prop.tiposDisplay.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    prop.tiposDisplay,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  prop.rating == 'Nuevo' ? Icons.star_border : Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  prop.rating,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (prop.reviewCount > 0) ...[
                  Text(
                    ' (${prop.reviewCount})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón de favorito con animación ───────────────────────────────

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0);

    setState(() => _showTooltip = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Leemos el valor ACTUAL de isFavorite vía widget (que se actualiza
    // de forma optimista desde el provider).
    final isFav = widget.isFavorite;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tooltip lateral animado ("Guardado" / "Eliminado")
        AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          offset: _showTooltip ? Offset.zero : const Offset(0.5, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _showTooltip ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFav ? Colors.red.shade400 : Colors.grey.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isFav ? 'Guardado' : 'Eliminado',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Botón corazón
        GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFav),
                      color: isFav ? Colors.red : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
