import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

class HostEditImagesTab extends StatelessWidget {
  final List<PropertyImageDetail> images;
  final String? deletingImageId;
  final bool adding;
  final VoidCallback onAddImage;
  final void Function(PropertyImageDetail) onDeleteImage;

  const HostEditImagesTab({
    super.key,
    required this.images,
    required this.deletingImageId,
    required this.adding,
    required this.onAddImage,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad),
      child: Column(
        children: [
          Expanded(
            child: images.isEmpty
                ? Center(
                    child: Text(
                      'No hay imágenes',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (ctx, i) => _imageCell(context, images[i]),
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: adding ? null : onAddImage,
              icon: adding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kDetailPrimary),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(adding ? 'Subiendo...' : 'Agregar imagen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kDetailPrimary,
                side: const BorderSide(color: kDetailPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageCell(BuildContext context, PropertyImageDetail image) {
    final isDeleting = deletingImageId == image.idPropertyImage;
    final canDelete = images.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: image.imageURL,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            errorWidget: (ctx, url, err) => Container(
              color: Colors.grey.shade200,
              child:
                  const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
        if (image.isPrimary)
          const Positioned(
            top: 4,
            left: 4,
            child: Icon(Icons.star_rounded,
                color: Color(0xFFE5A84B), size: 18),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: isDeleting
                ? null
                : () {
                    if (!canDelete) {
                      TopChip.showError(
                        context,
                        'No puedes eliminar la última imagen de la propiedad',
                      );
                    } else {
                      onDeleteImage(image);
                    }
                  },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: (!canDelete || isDeleting)
                    ? Colors.grey.shade400
                    : Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
        if (isDeleting)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
