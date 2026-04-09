import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatisticsHeroCard(vm: vm),
            const SizedBox(height: 14),
            McPanel(
              title: "CONTRIBUTION",
              child: _ContributionDistributionCard(vm: vm),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "TRENDS",
              child: Column(
                children: [
                  _ExpandedTrendCard(
                    title: "Energy Output",
                    value: "${vm.energyTrendValues.isNotEmpty ? vm.energyTrendValues.last.toStringAsFixed(0) : '0'} Wh",
                    icon: Icons.bolt_rounded,
                    accent: const Color(0xFFFFC857),
                    values: vm.energyTrendValues,
                  ),
                  const SizedBox(height: 12),
                  _ExpandedTrendCard(
                    title: "Loss Estimate",
                    value: "${vm.lossTrendValues.isNotEmpty ? vm.lossTrendValues.last.toStringAsFixed(1) : '0'} %",
                    icon: Icons.warning_rounded,
                    accent: const Color(0xFF7C4DFF),
                    values: vm.lossTrendValues,
                  ),
                  const SizedBox(height: 12),
                  _ExpandedTrendCard(
                    title: "Panel Temperature",
                    value: "${vm.temperatureTrendValues.isNotEmpty ? vm.temperatureTrendValues.last.toStringAsFixed(1) : '0'} °C",
                    icon: Icons.thermostat_rounded,
                    accent: Colors.cyanAccent,
                    values: vm.temperatureTrendValues,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatisticsHeroCard extends StatelessWidget {
  final DashboardViewModel vm;

  const _StatisticsHeroCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.18),
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.015),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primary.withOpacity(0.12),
                  border: Border.all(color: cs.primary.withOpacity(0.28)),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "PERFORMANCE SUMMARY",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: "Gain",
                  value: "${vm.overallPerformanceGain.toStringAsFixed(1)}%",
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: "Net",
                  value: "${vm.netEnergyGainEstimate.toStringAsFixed(1)}%",
                  color: const Color(0xFFFFC857),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: "Health",
                  value: "${vm.systemEfficiencyScore.toStringAsFixed(0)}%",
                  color: Colors.cyanAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionDistributionCard extends StatelessWidget {
  final DashboardViewModel vm;

  const _ContributionDistributionCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;

        final chart = _CircularContributionChart(
          trackingPercent: vm.trackingContributionPercent,
          cleaningPercent: vm.cleaningContributionPercent,
          coolingPercent: vm.coolingContributionPercent,
          totalGain: vm.estimatedTotalImprovement,
        );

        final legend = Column(
          children: [
            _ContributionLegendTile(
              title: "Tracking",
              percent: vm.trackingContributionPercent,
              value: vm.trackingEfficiencyGain,
              icon: Icons.explore_rounded,
              accent: const Color(0xFFFFC857),
            ),
            const SizedBox(height: 10),
            _ContributionLegendTile(
              title: "Cleaning",
              percent: vm.cleaningContributionPercent,
              value: vm.cleaningEfficiencyRecovery,
              icon: Icons.cleaning_services_rounded,
              accent: const Color(0xFF7C4DFF),
            ),
            const SizedBox(height: 10),
            _ContributionLegendTile(
              title: "Cooling",
              percent: vm.coolingContributionPercent,
              value: vm.coolingEfficiencyRecovery,
              icon: Icons.ac_unit_rounded,
              accent: Colors.cyanAccent,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cs.primary.withOpacity(0.10),
                      border: Border.all(color: cs.primary.withOpacity(0.24)),
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      vm.performanceHeadline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 4, child: chart),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: legend),
            ],
          );
        }

        return Column(
          children: [
            chart,
            const SizedBox(height: 14),
            legend,
          ],
        );
      },
    );
  }
}

class _CircularContributionChart extends StatelessWidget {
  final double trackingPercent;
  final double cleaningPercent;
  final double coolingPercent;
  final double totalGain;

  const _CircularContributionChart({
    required this.trackingPercent,
    required this.cleaningPercent,
    required this.coolingPercent,
    required this.totalGain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: _ContributionRingPainter(
                  trackingPercent: trackingPercent,
                  cleaningPercent: cleaningPercent,
                  coolingPercent: coolingPercent,
                ),
              ),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B1220).withOpacity(0.92),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TOTAL",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${totalGain.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributionRingPainter extends CustomPainter {
  final double trackingPercent;
  final double cleaningPercent;
  final double coolingPercent;

  const _ContributionRingPainter({
    required this.trackingPercent,
    required this.cleaningPercent,
    required this.coolingPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = 18.0;
    final radius = (size.width / 2) - strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.07);

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);

    const gap = 0.08;
    final totalSweep = (math.pi * 2) - (gap * 3);

    final trackingSweep = totalSweep * (trackingPercent.clamp(0, 100) / 100);
    final cleaningSweep = totalSweep * (cleaningPercent.clamp(0, 100) / 100);
    final coolingSweep = totalSweep * (coolingPercent.clamp(0, 100) / 100);

    double start = -math.pi / 2;

    final trackingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFC857);

    canvas.drawArc(rect, start, trackingSweep, false, trackingPaint);

    start += trackingSweep + gap;

    final cleaningPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7C4DFF);

    canvas.drawArc(rect, start, cleaningSweep, false, cleaningPaint);

    start += cleaningSweep + gap;

    final coolingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.cyanAccent;

    canvas.drawArc(rect, start, coolingSweep, false, coolingPaint);
  }

  @override
  bool shouldRepaint(covariant _ContributionRingPainter oldDelegate) {
    return oldDelegate.trackingPercent != trackingPercent ||
        oldDelegate.cleaningPercent != cleaningPercent ||
        oldDelegate.coolingPercent != coolingPercent;
  }
}

class _ContributionLegendTile extends StatelessWidget {
  final String title;
  final double percent;
  final double value;
  final IconData icon;
  final Color accent;

  const _ContributionLegendTile({
    required this.title,
    required this.percent,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withOpacity(0.10),
              border: Border.all(color: accent.withOpacity(0.24)),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${percent.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${value.toStringAsFixed(1)}%",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.60),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandedTrendCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final List<double> values;

  const _ExpandedTrendCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.values,
  });

  String _unitFromTitle() {
    switch (title) {
      case "Energy Output":
        return "Wh";
      case "Loss Estimate":
        return "%";
      case "Panel Temperature":
        return "°C";
      default:
        return "";
    }
  }

  String _xLabel(int index, int total) {
    if (total <= 1) {
      switch (title) {
        case "Energy Output":
          return "Today";
        case "Loss Estimate":
          return "C1";
        case "Panel Temperature":
          return "T1";
        default:
          return "Now";
      }
    }

    switch (title) {
      case "Energy Output":
        if (total == 7) {
          const labels = ["D1", "D2", "D3", "D4", "D5", "D6", "Today"];
          return labels[index];
        }
        return index == total - 1 ? "Today" : "D${index + 1}";

      case "Loss Estimate":
        return "C${index + 1}";

      case "Panel Temperature":
        return "T${index + 1}";

      default:
        if (index == 0) return "Start";
        if (index == total - 1) return "Now";
        if (index == total ~/ 2) return "Mid";
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? [0.0] : values;
    final minValue = safeValues.reduce(math.min);
    final maxValue = safeValues.reduce(math.max);
    final latest = safeValues.last;
    final unit = _unitFromTitle();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: accent.withOpacity(0.10),
                  border: Border.all(color: accent.withOpacity(0.24)),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TrendMiniInfo(
                  label: "Min",
                  value: "${minValue.toStringAsFixed(title == "Energy Output" ? 0 : 1)} $unit",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TrendMiniInfo(
                  label: "Max",
                  value: "${maxValue.toStringAsFixed(title == "Energy Output" ? 0 : 1)} $unit",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TrendMiniInfo(
                  label: "Latest",
                  value: "${latest.toStringAsFixed(title == "Energy Output" ? 0 : 1)} $unit",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: _ExpandedSparkline(
              values: safeValues,
              accent: accent,
              unit: unit,
              xLabelBuilder: _xLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendMiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _TrendMiniInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedSparkline extends StatelessWidget {
  final List<double> values;
  final Color accent;
  final String unit;
  final String Function(int index, int total) xLabelBuilder;

  const _ExpandedSparkline({
    required this.values,
    required this.accent,
    required this.unit,
    required this.xLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ExpandedSparklinePainter(
        values: values,
        accent: accent,
        unit: unit,
        xLabelBuilder: xLabelBuilder,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ExpandedSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color accent;
  final String unit;
  final String Function(int index, int total) xLabelBuilder;

  const _ExpandedSparklinePainter({
    required this.values,
    required this.accent,
    required this.unit,
    required this.xLabelBuilder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final safeValues = values.isEmpty ? [0.0] : values;
    final minValue = safeValues.reduce(math.min);
    final maxValue = safeValues.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.001 ? 1.0 : (maxValue - minValue);

    const leftPad = 44.0;
    const rightPad = 14.0;
    const topPad = 14.0;
    const bottomPad = 34.0;

    final chartRect = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..strokeWidth = 1.2;

    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.58),
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
    );

    // Horizontal grid + Y labels
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * i / 4;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );

      final value = maxValue - (range * i / 4);
      final text = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(unit == "Wh" ? 0 : 1),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      text.paint(
        canvas,
        Offset(chartRect.left - text.width - 8, y - text.height / 2),
      );
    }

    // Axis lines
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );

    Offset pointFor(int index) {
      final x = safeValues.length == 1
          ? chartRect.center.dx
          : chartRect.left +
          chartRect.width * index / (safeValues.length - 1);

      final normalized = (safeValues[index] - minValue) / range;
      final y = chartRect.bottom - normalized * chartRect.height;
      return Offset(x, y);
    }

    final linePath = Path();
    final fillPath = Path();

    final first = pointFor(0);
    linePath.moveTo(first.dx, first.dy);
    fillPath.moveTo(first.dx, chartRect.bottom);
    fillPath.lineTo(first.dx, first.dy);

    for (int i = 1; i < safeValues.length; i++) {
      final p = pointFor(i);
      linePath.lineTo(p.dx, p.dy);
      fillPath.lineTo(p.dx, p.dy);
    }

    final last = pointFor(safeValues.length - 1);
    fillPath.lineTo(last.dx, chartRect.bottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withOpacity(0.22),
          accent.withOpacity(0.03),
        ],
      ).createShader(chartRect);

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Points + X labels
    for (int i = 0; i < safeValues.length; i++) {
      final p = pointFor(i);

      canvas.drawCircle(
        p,
        4.5,
        Paint()..color = accent,
      );

      canvas.drawCircle(
        p,
        9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = accent.withOpacity(0.22),
      );

      final xLabel = xLabelBuilder(i, safeValues.length);
      if (xLabel.isNotEmpty) {
        final text = TextPainter(
          text: TextSpan(
            text: xLabel,
            style: labelStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        text.paint(
          canvas,
          Offset(
            p.dx - text.width / 2,
            chartRect.bottom + 8,
          ),
        );
      }
    }

    // Small Y axis title
    final yAxisText = TextPainter(
      text: TextSpan(
        text: unit,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    yAxisText.paint(canvas, Offset(6, chartRect.top - 2));
  }

  @override
  bool shouldRepaint(covariant _ExpandedSparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.accent != accent ||
        oldDelegate.unit != unit;
  }
}