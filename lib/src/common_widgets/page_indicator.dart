import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Page indicator dots widget
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = AppColors.indicatorActive,
    this.inactiveColor = AppColors.indicatorInactive,
    this.size = 8.0,
    this.spacing = 8.0,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
