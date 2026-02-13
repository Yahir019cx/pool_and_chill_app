import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'detail_constants.dart';

class DetailRulesSection extends StatelessWidget {
  final List<PropertyRule> rules;

  const DetailRulesSection({super.key, required this.rules});

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const SizedBox.shrink();

    final sorted = List<PropertyRule>.from(rules)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: kDetailGreyLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.ruleText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: kDetailGrey,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
