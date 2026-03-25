import 'dart:math' as math;
import 'package:flutter/material.dart';

class BigReadout extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color accent;

  const BigReadout({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: muted, letterSpacing: 1.4)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 140,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.5),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.35), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThresholdLine extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const ThresholdLine({
    super.key,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: muted,
                    letterSpacing: 0.8,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  final String k;
  final String v;

  const KeyValueRow({
    super.key,
    required this.k,
    required this.v,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;
    return Row(
      children: [
        Expanded(
          child: Text(
            k.toUpperCase(),
            style: TextStyle(color: muted, letterSpacing: 0.8, fontSize: 12),
          ),
        ),
        Text(v, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class EventRow extends StatelessWidget {
  final Color dot;
  final String title;
  final String time;

  const EventRow({
    super.key,
    required this.dot,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: dot.withOpacity(0.6), blurRadius: 10)],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(time, style: TextStyle(color: muted)),
      ],
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class CommandTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CommandTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final String label;

  const MiniBarChart({
    super.key,
    required this.values,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: muted, letterSpacing: 0.8, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: CustomPaint(
              painter: _BarsPainter(values),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> values;
  _BarsPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.reduce(math.max);
    final barPaint = Paint()..color = Colors.cyanAccent.withOpacity(0.75);
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.08);

    const gap = 6.0;
    final w = (size.width - gap * (values.length - 1)) / values.length;

    canvas.drawRect(Rect.fromLTWH(0, size.height - 1, size.width, 1), bgPaint);

    for (int i = 0; i < values.length; i++) {
      final h = (values[i] / (maxV == 0 ? 1 : maxV)) * (size.height - 6);
      final x = i * (w + gap);
      final y = size.height - h;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.values != values;
}

class ToggleRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color border;

  const ToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.border,
  });

  @override
  State<ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<ToggleRow> {
  bool v = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: v,
        onChanged: (x) => setState(() => v = x),
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(widget.subtitle),
      ),
    );
  }
}

class CommandButtonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color border;
  final VoidCallback onTap;

  const CommandButtonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class DashboardToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Color border;
  final ValueChanged<bool> onChanged;

  const DashboardToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.border,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}