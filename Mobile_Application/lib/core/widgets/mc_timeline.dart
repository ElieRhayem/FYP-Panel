import 'package:flutter/material.dart';

class McEvent {
  final DateTime time;
  final String title;
  final String details;
  final Color dot;

  const McEvent({
    required this.time,
    required this.title,
    required this.details,
    required this.dot,
  });
}

class McTimeline extends StatelessWidget {
  final String title;
  final List<McEvent> events;

  const McTimeline({
    super.key,
    this.title = "EVENT STREAM",
    required this.events,
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
          ...events.take(8).map((e) => _EventTile(e: e)).toList(),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final McEvent e;
  const _EventTile({required this.e});

  String _timeStr(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + vertical line
          Column(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: e.dot,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: e.dot.withOpacity(0.55), blurRadius: 10)],
                ),
              ),
              Container(
                width: 2,
                height: 36,
                color: Colors.white.withOpacity(0.07),
              ),
            ],
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    Text(_timeStr(e.time), style: TextStyle(color: muted, letterSpacing: 0.6)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(e.details, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
