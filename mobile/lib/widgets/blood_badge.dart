import 'package:flutter/material.dart';
import '../core/theme.dart';

class BloodBadge extends StatelessWidget {
  final String golongan;
  final double size;
  final bool isFilled;

  const BloodBadge({
    super.key,
    required this.golongan,
    this.size = 46.0,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isFilled ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(size / 3.5),
        border: Border.all(
          color: AppTheme.primary,
          width: 2,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          golongan,
          style: TextStyle(
            color: isFilled ? Colors.white : AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}
