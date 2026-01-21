import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EspacioCard extends StatefulWidget {
  final bool initialFavorite;

  const EspacioCard({
    super.key,
    this.initialFavorite = false,
  });

  @override
  State<EspacioCard> createState() => _EspacioCardState();
}

class _EspacioCardState extends State<EspacioCard> {
  static const _autoScrollDuration = Duration(seconds: 4);
  static const _pageAnimationDuration = Duration(milliseconds: 500);

  late final PageController _pageController;
  Timer? _autoScrollTimer;

  late bool _esFavorito;
  int _currentIndex = 0;

  final List<String> _fotos = [
    'https://picsum.photos/600/400?1',
    'https://picsum.photos/600/400?2',
    'https://picsum.photos/600/400?3',
  ];

  final String _titulo = 'Espacio Premium';
  final String _tipos = 'Alberca, Jardín, Terraza';
  final int _precioPorDia = 2500;

  List<String> get _extendedFotos {
    return [_fotos.last, ..._fotos, _fotos.first];
  }

  @override
  void initState() {
    super.initState();
    _esFavorito = widget.initialFavorite;
    _pageController = PageController(initialPage: 1);
    _startAutoScroll();
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
    final precio = NumberFormat("#,##0", "es_MX").format(_precioPorDia);

    return Card(
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
  }

  Widget _buildCarousel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _extendedFotos.length,
            onPageChanged: _handlePageChanged,
            itemBuilder: (_, index) {
              return Image.network(
                _extendedFotos[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              );
            },
          ),
        ),

        // Favorite button with tooltip
        Positioned(
          top: 8,
          right: 8,
          child: _FavoriteButton(
            isFavorite: _esFavorito,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _esFavorito = !_esFavorito);
            },
          ),
        ),

        // Page indicators
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _fotos.length,
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
                  _titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\$$precio MXN",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E838C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tipos,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.star_border,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

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
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showTooltip = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.isFavorite;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated tooltip
        AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _showTooltip ? Offset.zero : const Offset(0.5, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
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

        // Heart button
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
