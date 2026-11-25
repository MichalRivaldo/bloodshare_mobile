import 'package:flutter/material.dart';
import '../core/constants.dart';

class UrgencyBadge extends StatelessWidget {
  final String urgensi;

  const UrgencyBadge({super.key, required this.urgensi});

  @override
  Widget build(BuildContext context) {
    final label = kUrgensiLabel[urgensi] ?? urgensi;
    final colorVal = kUrgensiColor[urgensi] ?? 0xFF757575;
    final color = Color(colorVal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
