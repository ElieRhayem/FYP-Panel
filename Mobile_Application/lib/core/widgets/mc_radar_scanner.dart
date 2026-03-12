import 'dart:math' as math;
import 'package:flutter/material.dart';

class McRadarScanner extends StatefulWidget {
  final double healthScore; // 0..100
  final String title;
  final Color accent;

  const McRadarScanner({
    super.key,
    required this.healthScore,
    this.title = "HEALTH SCANNER",
    this.accent = Colors.cyanAccent,
  });

  @override
  State<McRadarScanner> createState() => _McRadarScannerState();
}

class _McRadarScannerState extends State<McRadarScanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
          Text(widget.title, style: TextStyle(color: muted, letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _RadarPainter(
                  sweepT: _ctrl.value,
                  health: widget.healthScore,
                  accent: widget.accent,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${widget.healthScore.toStringAsFixed(0)}",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: widget.accent,
                        ),
                      ),
                      Text("HEALTH", style: TextStyle(color: muted, letterSpacing: 1.1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double sweepT; // 0..1
  final double health; // 0..100
  final Color accent;

  _RadarPainter({
    required this.sweepT,
    required this.health,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;

    // Background circle
    final bg = Paint()..color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(c, r, bg);

    // Rings
    final ring = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(c, r * (i / 3), ring);
    }

    // Cross lines
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), grid);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), grid);

    // Sweep
    final sweepAngle = sweepT * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withOpacity(0.0),
          accent.withOpacity(0.18),
          accent.withOpacity(0.0),
        ],
        stops: const [0.0, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    final sweepPath = Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(
        Rect.fromCircle(center: c, radius: r),
        sweepAngle - 0.30,
        0.60,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweepPaint);

    // "Targets" density depends on health: higher health -> fewer red-ish targets
    final rng = math.Random(42);
    final targetCount = 10;
    for (int i = 0; i < targetCount; i++) {
      final rr = rng.nextDouble() * r * 0.95;
      final aa = rng.nextDouble() * 2 * math.pi;
      final p = Offset(c.dx + rr * math.cos(aa), c.dy + rr * math.sin(aa));

      final badChance = (100 - health).clamp(0, 100) / 100.0;
      final isBad = rng.nextDouble() < badChance * 0.6;

      final dot = Paint()
        ..color = (isBad ? Colors.redAccent : accent).withOpacity(0.75);

      canvas.drawCircle(p, isBad ? 2.6 : 1.9, dot);
    }

    // Outer border glow
    final border = Paint()
      ..color = accent.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(c, r, border);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.sweepT != sweepT || oldDelegate.health != health;
}
