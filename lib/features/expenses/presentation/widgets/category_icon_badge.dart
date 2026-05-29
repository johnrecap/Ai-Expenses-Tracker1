import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';

class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    super.key,
    this.iconName = '',
    this.colorValue,
    this.size = 40,
  });

  final String iconName;
  final int? colorValue;
  final double size;

  static IconData _iconForName(String name) {
    switch (name) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'local_taxi':
      case 'transport':
        return Icons.local_taxi;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag;
      case 'home':
      case 'housing':
        return Icons.home;
      case 'movie':
      case 'entertainment':
        return Icons.movie_creation;
      case 'local_hospital':
      case 'healthcare':
      case 'health':
        return Icons.local_hospital;
      case 'school':
      case 'education':
        return Icons.school;
      case 'bolt':
      case 'utilities':
        return Icons.bolt;
      case 'flight':
      case 'travel':
        return Icons.flight;
      case 'personal_care':
        return Icons.face_3;
      default:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForName(iconName);
    final color = Color(colorValue ?? AppColors.surfaceContainerHigh.value);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color,
      ),
    );
  }
}
