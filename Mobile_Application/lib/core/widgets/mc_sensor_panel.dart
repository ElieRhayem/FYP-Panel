import 'package:flutter/material.dart';

class SensorStatus {
  final String name;
  final bool online;
  final int strength; // 0..4
  final String hint;

  const SensorStatus({
    required this.name,
    required this.online,
    required this.strength,
    required this.hint,
  });
}

class McSensorPanel extends StatelessWidget {
  final String title;
  final List<SensorStatus> sensors;

  const McSensorPanel({
    super.key,
    this.title = "SENSORS",
    required this.sensors,
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
          Text(title, style: TextStyle(color: muted, letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 10),
          ...sensors.map((s) => _SensorRow(s: s)).toList(),
        ],
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  final SensorStatus s;
  const _SensorRow({required this.s});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;
    final dot = s.online ? Colors.greenAccent : Colors.redAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Online dot
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: dot.withOpacity(0.55), blurRadius: 10)],
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(s.hint, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),

          // Signal bars
          _SignalBars(level: s.online ? s.strength : 0),
          const SizedBox(width: 6),
          Text(
            s.online ? "ON" : "OFF",
            style: TextStyle(color: muted, letterSpacing: 1.2, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int level; // 0..4
  const _SignalBars({required this.level});

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(4, (i) => i < level);
    return Row(
      children: bars.map((on) {
        final color = on ? Colors.greenAccent : Colors.white.withOpacity(0.15);
        return Container(
          margin: const EdgeInsets.only(left: 3),
          width: 5,
          height: 8 + (bars.indexOf(on) * 3).toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}
