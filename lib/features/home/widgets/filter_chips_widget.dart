import 'package:flutter/material.dart';

class FilterChipsWidget extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  const FilterChipsWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const filters = [
    {'icon': Icons.cabin, 'label': 'Cabañas'},
    {'icon': Icons.pool, 'label': 'Albercas'},
    {'icon': Icons.park, 'label': 'Camping'},
    {'icon': Icons.trending_up, 'label': 'Populares'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filters[index]['icon'] as IconData,
                      size: 28,
                      color: isSelected
                          ? const Color(0xFF3CA2A2)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      filters[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        height: 2,
                        width: 24,
                        color: const Color(0xFF3CA2A2),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
