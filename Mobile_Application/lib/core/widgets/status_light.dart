import 'package:flutter/material.dart';

class StatusLight extends StatelessWidget {
  final Color color;
  final String label;

  const StatusLight({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.55), blurRadius: 10, spreadRadius: 1),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
