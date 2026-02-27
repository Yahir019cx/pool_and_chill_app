import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'detail_constants.dart';

class DetailAmenitiesSection extends StatefulWidget {
  final List<AmenityItem> amenities;

  const DetailAmenitiesSection({super.key, required this.amenities});

  @override
  State<DetailAmenitiesSection> createState() => _DetailAmenitiesSectionState();
}

class _DetailAmenitiesSectionState extends State<DetailAmenitiesSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const int _itemsPerPage = 3;

  int get _pageCount => (widget.amenities.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_pageCount > 1) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % _pageCount;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.amenities.isEmpty) return const SizedBox.shrink();

    if (_pageCount <= 1) {
      return _buildChipRow(widget.amenities);
    }

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pageCount,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _startTimer();
            },
            itemBuilder: (_, page) {
              final start = page * _itemsPerPage;
              final end =
                  (start + _itemsPerPage).clamp(0, widget.amenities.length);
              return _buildChipRow(widget.amenities.sublist(start, end));
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pageCount,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentPage == i
                    ? kDetailPrimary
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipRow(List<AmenityItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.asMap().entries.map((entry) {
        final a = entry.value;
        return Flexible(
          child: Padding(
            padding: EdgeInsets.only(left: entry.key == 0 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: kDetailPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: kDetailPrimary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    iconForAmenity(a.icon, a.amenityCode),
                    size: 16,
                    color: kDetailPrimary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      a.amenityName ?? a.amenityCode ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kDetailDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
