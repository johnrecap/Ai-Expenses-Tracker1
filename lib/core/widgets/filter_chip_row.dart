import 'package:flutter/material.dart';
import 'secondary_pill_button.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SecondaryPillButton(
            label: labels[index],
            isActive: index == selectedIndex,
            onPressed: () => onSelected(index),
          );
        },
      ),
    );
  }
}
