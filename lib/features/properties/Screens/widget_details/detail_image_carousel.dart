import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'detail_constants.dart';

class DetailImageCarousel extends StatelessWidget {
  final List<PropertyImageDetail> images;
  final PageController controller;
  final int currentIndex;
  final Widget overlayButtons;

  const DetailImageCarousel({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.overlayButtons,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: SizedBox(
        height: 240 + topPadding,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isEmpty)
              Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child:
                      Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                ),
              )
            else
              PageView.builder(
                controller: controller,
                itemCount: images.length,
                itemBuilder: (_, i) => CachedNetworkImage(
                  imageUrl: images[i].imageURL,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (_, _) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: kDetailPrimary, strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: Icon(Icons.image, color: Colors.grey)),
                  ),
                ),
              ),
            // Gradient top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topPadding + 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Overlay buttons (back, share, fav)
            overlayButtons,
            // Dot indicators
            if (images.length > 1)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: currentIndex == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DetailActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const DetailActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
        ),
      ),
    );
  }
}
