import 'dart:async';
import 'package:flutter/material.dart';

import 'detail_constants.dart';

class DetailSpecsSection extends StatefulWidget {
  final List<SpecItem> specs;

  const DetailSpecsSection({super.key, required this.specs});

  @override
  State<DetailSpecsSection> createState() => _DetailSpecsSectionState();
}

class _DetailSpecsSectionState extends State<DetailSpecsSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const int _itemsPerPage = 4;

  int get _pageCount => (widget.specs.length / _itemsPerPage).ceil();

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
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
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
    if (widget.specs.isEmpty) return const SizedBox.shrink();

    if (_pageCount <= 1) {
      return _buildPage(widget.specs);
    }

    return Column(
      children: [
        SizedBox(
          height: 24,
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
                  (start + _itemsPerPage).clamp(0, widget.specs.length);
              return _buildPage(widget.specs.sublist(start, end));
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildDots(),
      ],
    );
  }

  Widget _buildPage(List<SpecItem> items) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: items.asMap().entries.map((entry) {
        final spec = entry.value;
        final isLast = entry.key == items.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(spec.icon, size: 18, color: kDetailPrimary),
            const SizedBox(width: 5),
            Text(
              spec.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kDetailDark,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              spec.label,
              style: const TextStyle(fontSize: 13, color: kDetailGrey),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '·',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDots() {
    return Row(
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
            color: _currentPage == i ? kDetailPrimary : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
