import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Gender types for the indicator
enum Gender { male, female }

/// Non-interactive gender indicator icon
class GenderIndicator extends StatelessWidget {
  final Gender gender;
  final double size;

  const GenderIndicator({super.key, this.gender = Gender.male, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.overlayLight,
      ),
      child: Icon(
        gender == Gender.male ? Icons.male_rounded : Icons.female_rounded,
        color: AppColors.iconActive,
        size: size,
      ),
    );
  }
}
