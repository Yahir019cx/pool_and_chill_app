import 'package:flutter/material.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/advanced_filters_button.dart';
import '../widgets/espacios_list_widget.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int? selectedFilterIndex;
  String? searchTerm;
  bool hasAdvancedFilters = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBarWidget(
          onChanged: (value) => setState(() => searchTerm = value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AdvancedFiltersButton(
            hasActiveFilters: hasAdvancedFilters || selectedFilterIndex != null,
            onClear: () {
              setState(() {
                selectedFilterIndex = null;
                searchTerm = null;
                hasAdvancedFilters = false;
              });
            },
          ),
        ),
        FilterChipsWidget(
          selectedIndex: selectedFilterIndex,
          onSelected: (index) => setState(() => selectedFilterIndex = index),
        ),
        const Expanded(
          child: EspaciosListWidget(),
        ),
      ],
    );
  }
}
