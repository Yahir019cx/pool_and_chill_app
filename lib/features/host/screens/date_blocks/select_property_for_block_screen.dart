import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pool_and_chill_app/data/models/property/my_property_model.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';

import 'date_block_calendar_screen.dart';

class SelectPropertyForBlockScreen extends StatelessWidget {
  const SelectPropertyForBlockScreen({super.key});

  static const _kPrimary = Color(0xFF2D9D91);
  static const _kDark = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final properties = auth.myProperties;
    final isLoading = auth.isLoadingProperties;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kDark,
        title: const Text(
          'Bloquear fechas',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _kPrimary))
          : properties.isEmpty
              ? _buildEmpty()
              : _buildList(context, properties),
    );
  }

  Widget _buildList(
      BuildContext context, List<MyPropertyModel> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            'Selecciona la propiedad',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            itemCount: properties.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => _PropertyCard(
              property: properties[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DateBlockCalendarScreen(
                    propertyId: properties[i].id,
                    propertyTitle: properties[i].title,
                    coverImageUrl: properties[i].coverImageUrl,
                    availableTypes: [
                      if (properties[i].hasPool) 'pool',
                      if (properties[i].hasCabin) 'cabin',
                      if (properties[i].hasCamping) 'camping',
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.villa_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No tienes propiedades publicadas',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Property card ────────────────────────────────────────────────────────────

class _PropertyCard extends StatelessWidget {
  final MyPropertyModel property;
  final VoidCallback onTap;

  const _PropertyCard({required this.property, required this.onTap});

  static const _kPrimary = Color(0xFF2D9D91);
  static const _kDark = Color(0xFF1A1A2E);

  static const _typeLabels = {
    'pool': 'Alberca',
    'cabin': 'Cabaña',
    'camping': 'Camping',
  };

  @override
  Widget build(BuildContext context) {
    final types = [
      if (property.hasPool) 'pool',
      if (property.hasCabin) 'cabin',
      if (property.hasCamping) 'camping',
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: property.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _kDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (property.locationDisplay.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              property.locationDisplay,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: types
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _kPrimary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _typeLabels[t] ?? t,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade100,
        child: Icon(Icons.villa_outlined,
            color: Colors.grey.shade300, size: 28),
      );
}
