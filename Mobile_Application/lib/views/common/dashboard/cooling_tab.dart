import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';

class CoolingTab extends StatefulWidget {
  const CoolingTab({super.key});

  @override
  State<CoolingTab> createState() => _CoolingTabState();
}

class _CoolingTabState extends State<CoolingTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  void _syncAnimation(bool active) {
    if (active) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      if (_controller.value != 0) {
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatFullDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy • HH:mm:ss').format(dt);
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _historyChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                color: Colors.white.withOpacity(0.60),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoolingHistoryDialog(BuildContext context, DashboardViewModel vm) {
    final history = vm.coolingHistory;
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.15)),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 560),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyanAccent.withOpacity(0.10),
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.ac_unit_rounded,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Cooling History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                    child: Text(
                      "No cooling history recorded yet.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = history[index];

                      final statusColor = entry.status == "Completed"
                          ? Colors.greenAccent
                          : entry.status == "Running"
                          ? Colors.cyanAccent
                          : entry.status == "Recommended"
                          ? Colors.orangeAccent
                          : entry.status == "Stopped"
                          ? Colors.redAccent
                          : cs.primary;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.03),
                              statusColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Spacer(),
                                Text(
                                  _formatFullDateTime(entry.timestamp),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.62),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Cooling snapshot",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _detailPill(
                                  "Panel Temp",
                                  "${entry.panelTemperature.toStringAsFixed(1)}°C",
                                ),
                                _detailPill(
                                  "Cooling Gain",
                                  "${entry.temperatureDrop.toStringAsFixed(1)}°C",
                                ),
                                _detailPill("PCM", entry.pcmState),
                                _detailPill("Source", entry.source),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _thermalColor(DashboardViewModel vm) {
    if (vm.panelTemperatureC < vm.coolingTargetMinC) {
      return Colors.lightBlueAccent;
    }
    if (vm.panelTemperatureC <= vm.coolingTargetMaxC) {
      return Colors.greenAccent;
    }
    if (vm.panelTemperatureC <= vm.coolingMaxSafeC) {
      return Colors.orangeAccent;
    }
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    _syncAnimation(vm.coolingInProgress);

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "COOLING STATUS",
              trailing: Text(
                vm.coolingMode.toUpperCase(),
                style: TextStyle(
                  color: cs.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Column(
                children: [
                  McMetric(
                    label: "Mode",
                    value: vm.coolingMode,
                    unit: "",
                    icon: Icons.ac_unit_rounded,
                    accent: vm.coolingInProgress
                        ? Colors.cyanAccent
                        : const Color(0xFFFFC857),
                    hint: vm.coolingInProgress
                        ? "Cooling currently active"
                        : "Current cooling operating state",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Panel Temp",
                          value: vm.panelTemperatureC.toStringAsFixed(1),
                          unit: "°C",
                          icon: Icons.thermostat_rounded,
                          accent: _thermalColor(vm),
                          hint: vm.thermalBandLabel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "PCM State",
                          value: vm.pcmStateLabel,
                          unit: "",
                          icon: Icons.opacity_rounded,
                          accent: Colors.cyanAccent,
                          hint: "Phase change condition",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Cooling Gain",
                          value: vm.panelTemperatureDropC.toStringAsFixed(1),
                          unit: "°C",
                          icon: Icons.south_rounded,
                          accent: Colors.greenAccent,
                          hint: "Estimated temperature reduction",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Optimal Band",
                          value:
                          "${vm.coolingTargetMinC.toStringAsFixed(0)}-${vm.coolingTargetMaxC.toStringAsFixed(0)}",
                          unit: "°C",
                          icon: Icons.tune_rounded,
                          accent: const Color(0xFF7C4DFF),
                          hint: "Desired operating range",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "COOLING CONTROL",
              child: Column(
                children: [
                  DashboardToggleRow(
                    title: "Cooling Manual Mode",
                    subtitle: "Allow manual thermal intervention",
                    value: vm.coolingManualMode,
                    border: border,
                    onChanged: vm.setCoolingManualMode,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 260,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return _CoolingThermalAnimation(
                          progress: _controller.value,
                          active: vm.coolingInProgress,
                          panelTemperature: vm.panelTemperatureC,
                          pcmState: vm.pcmStateLabel,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Start Cooling Now",
                    subtitle: "Start PCM cooling cycle manually (UI-only now)",
                    icon: Icons.play_arrow_rounded,
                    border: border,
                    onTap: () {
                      if (!vm.coolingManualMode) {
                        _snack(context, "Enable Cooling Manual Mode first");
                        return;
                      }
                      vm.startCoolingNow();
                      _snack(context, "Cooling start simulated");
                    },
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Stop Cooling",
                    subtitle: "Abort current cooling cycle",
                    icon: Icons.stop_circle_rounded,
                    border: border,
                    onTap: () {
                      if (!vm.coolingManualMode) {
                        _snack(context, "Enable Cooling Manual Mode first");
                        return;
                      }
                      vm.stopCooling();
                      _snack(context, "Cooling stop simulated");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "COOLING HISTORY",
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showCoolingHistoryDialog(context, vm),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.03),
                        Colors.cyanAccent.withOpacity(0.03),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyanAccent.withOpacity(0.10),
                          border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "View cooling activity log",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vm.coolingHistory.isNotEmpty
                                  ? "Last update: ${_formatFullDateTime(vm.coolingHistory.first.timestamp)}"
                                  : "No cooling history available yet",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _historyChip(
                                  icon: Icons.thermostat_rounded,
                                  label:
                                  "Temp ${vm.panelTemperatureC.toStringAsFixed(1)}°C",
                                  color: _thermalColor(vm),
                                ),
                                _historyChip(
                                  icon: Icons.opacity_rounded,
                                  label: "PCM ${vm.pcmStateLabel}",
                                  color: Colors.cyanAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoolingThermalAnimation extends StatelessWidget {
  final double progress;
  final bool active;
  final double panelTemperature;
  final String pcmState;

  const _CoolingThermalAnimation({
    required this.progress,
    required this.active,
    required this.panelTemperature,
    required this.pcmState,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedPcm = pcmState == "Solid"
        ? 0.24
        : (pcmState == "Active" || pcmState == "Transition")
        ? 0.58
        : 0.88;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final panelWidth = math.min(width * 0.60, 255.0);
        final panelHeight = 150.0;

        return Center(
          child: SizedBox(
            width: width,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ThermalOrbitPainter(
                        progress: progress,
                        active: active,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  child: Transform.rotate(
                    angle: -0.13,
                    child: Container(
                      width: panelWidth,
                      height: panelHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: active
                              ? Colors.cyanAccent.withOpacity(0.28)
                              : Colors.orangeAccent.withOpacity(0.16),
                          width: 1.3,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: active
                              ? const [
                            Color(0xFF09162D),
                            Color(0xFF123562),
                            Color(0xFF0B1F3E),
                          ]
                              : const [
                            Color(0xFF3E121A),
                            Color(0xFF7A231A),
                            Color(0xFF241019),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: active
                                ? Colors.cyanAccent.withOpacity(0.12)
                                : Colors.redAccent.withOpacity(0.14),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _CoolingPanelPainter(
                                  progress: progress,
                                  active: active,
                                  panelTemperature: panelTemperature,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _CoolingCoreGlowPainter(
                                    progress: progress,
                                    active: active,
                                    panelTemperature: panelTemperature,
                                  ),
                                ),
                              ),
                            ),
                            if (active)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _CoolingFlowFieldPainter(
                                      progress: progress,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: _PanelShimmerPainter(
                                    progress: progress,
                                    active: active,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  child: Container(
                    width: 92,
                    height: 196,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.015),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.08),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _PcmTankPainter(
                                progress: progress,
                                fillLevel: normalizedPcm,
                                active: active,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _PcmGlassReflectionPainter(
                                  progress: progress,
                                  active: active,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                "PCM CORE",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.82),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.8,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (active)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _HeatTransferPainter(
                          progress: progress,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PanelShimmerPainter extends CustomPainter {
  final double progress;
  final bool active;

  const _PanelShimmerPainter({
    required this.progress,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerX = -size.width * 0.30 + (size.width * 1.6 * progress);

    final shimmerRect = Rect.fromLTWH(
      shimmerX,
      -20,
      size.width * 0.22,
      size.height + 40,
    );

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(active ? 0.06 : 0.04),
          Colors.cyanAccent.withOpacity(active ? 0.14 : 0.05),
          Colors.white.withOpacity(active ? 0.06 : 0.04),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(shimmerRect);

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(22),
      ),
    );

    canvas.translate(shimmerX, 0);
    canvas.rotate(-0.22);

    canvas.drawRect(
      Rect.fromLTWH(0, -30, size.width * 0.18, size.height + 60),
      shimmerPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PanelShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}

class _PcmGlassReflectionPainter extends CustomPainter {
  final double progress;
  final bool active;

  const _PcmGlassReflectionPainter({
    required this.progress,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Offset.zero & size;

    final leftGlass = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.20),
          Colors.white.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(
        Rect.fromLTWH(8, 8, size.width * 0.30, size.height - 16),
      );

    final rightGlass = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(size.width * 0.62, 12, size.width * 0.20, size.height - 24),
      );

    final glossY = 18 + math.sin(progress * math.pi * 2) * 3.0;

    final movingGloss = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(active ? 0.16 : 0.10),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromLTWH(16, glossY, size.width - 32, 18),
      );

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        outerRect,
        const Radius.circular(28),
      ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width * 0.22, size.height - 20),
        const Radius.circular(22),
      ),
      leftGlass,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.70, 16, size.width * 0.10, size.height - 32),
        const Radius.circular(18),
      ),
      rightGlass,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14, glossY, size.width - 28, 14),
        const Radius.circular(999),
      ),
      movingGloss,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PcmGlassReflectionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}

class _CoolingPanelPainter extends CustomPainter {
  final double progress;
  final bool active;
  final double panelTemperature;

  const _CoolingPanelPainter({
    required this.progress,
    required this.active,
    required this.panelTemperature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final dx = size.width * i / 5;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    for (int i = 1; i < 4; i++) {
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final innerRect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);

    final baseGlow = active
        ? Colors.cyanAccent.withOpacity(0.10)
        : (panelTemperature > 30
        ? Colors.redAccent.withOpacity(0.16)
        : Colors.orangeAccent.withOpacity(0.10));

    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(18)),
      Paint()..color = baseGlow,
    );

    final topSheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.transparent,
          Colors.cyanAccent.withOpacity(active ? 0.05 : 0.0),
        ],
      ).createShader(innerRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(18)),
      topSheen,
    );

    if (!active) {
      final heatPaint = Paint()..style = PaintingStyle.fill;

      for (int i = 0; i < 18; i++) {
        final x = 20 + (i * 17.0) % (size.width - 40);
        final y = 24 +
            ((i * 13.0 + math.sin(progress * math.pi * 2 + i) * 8) %
                (size.height - 48));
        final radius = 2.5 + (i % 3) * 1.4;

        heatPaint.color = (i % 2 == 0
            ? Colors.orangeAccent
            : Colors.redAccent)
            .withOpacity(0.18 + (i % 3) * 0.05);

        canvas.drawCircle(Offset(x, y), radius, heatPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CoolingPanelPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.panelTemperature != panelTemperature;
  }
}

class _HeatTransferPainter extends CustomPainter {
  final double progress;

  const _HeatTransferPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.36, size.height * 0.56);
    final end = Offset(size.width * 0.77, size.height * 0.47);

    Offset pointAt(double t, {double phase = 0.0, double amplitude = 1.0}) {
      final baseX = start.dx + (end.dx - start.dx) * t;
      final baseY = start.dy + (end.dy - start.dy) * t;

      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final length = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / length;
      final ny = dx / length;

      final spiral =
          math.sin((t * math.pi * 8) + (progress * math.pi * 2) + phase) *
              (8.0 * amplitude * (1 - (t - 0.5).abs() * 0.9));

      return Offset(
        baseX + nx * spiral,
        baseY + ny * spiral,
      );
    }

    final outerPath = Path()..moveTo(start.dx, start.dy);
    final innerPath = Path()..moveTo(start.dx, start.dy);
    final corePath = Path()..moveTo(start.dx, start.dy);

    for (int i = 1; i <= 42; i++) {
      final t = i / 42.0;
      final p1 = pointAt(t, phase: 0.0, amplitude: 1.0);
      final p2 = pointAt(t, phase: math.pi, amplitude: 0.72);
      final p3 = pointAt(t, phase: math.pi / 2, amplitude: 0.38);

      outerPath.lineTo(p1.dx, p1.dy);
      innerPath.lineTo(p2.dx, p2.dy);
      corePath.lineTo(p3.dx, p3.dy);
    }

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [
          Colors.orangeAccent.withOpacity(0.18),
          Colors.deepOrangeAccent.withOpacity(0.22),
          Colors.cyanAccent.withOpacity(0.18),
          Colors.cyanAccent.withOpacity(0.08),
        ],
      ).createShader(
        Rect.fromPoints(start, end),
      );

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [
          Colors.orangeAccent.withOpacity(0.32),
          Colors.white.withOpacity(0.18),
          Colors.cyanAccent.withOpacity(0.34),
        ],
      ).createShader(
        Rect.fromPoints(start, end),
      );

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.18),
          Colors.cyanAccent.withOpacity(0.55),
          Colors.white.withOpacity(0.14),
        ],
      ).createShader(
        Rect.fromPoints(start, end),
      );

    canvas.drawPath(
      outerPath,
      outerPaint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    canvas.drawPath(innerPath, innerPaint);
    canvas.drawPath(corePath, corePaint);

    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final t = ((progress + i * 0.032) % 1.0);

      final pA = pointAt(t, phase: 0.0, amplitude: 1.0);
      final pB = pointAt(t, phase: math.pi, amplitude: 0.72);
      final pC = pointAt(t, phase: math.pi / 2, amplitude: 0.38);

      final selected = i % 3 == 0
          ? pA
          : i % 3 == 1
          ? pB
          : pC;

      final radius = i % 3 == 0
          ? 3.0
          : i % 3 == 1
          ? 2.4
          : 1.8;

      particlePaint.color = Color.lerp(
        Colors.orangeAccent.withOpacity(0.85),
        Colors.cyanAccent.withOpacity(0.92),
        t,
      ) ??
          Colors.cyanAccent;

      canvas.drawCircle(selected, radius, particlePaint);

      canvas.drawCircle(
        selected,
        radius + 2.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = particlePaint.color.withOpacity(0.20),
      );
    }

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: end, radius: 24),
      );

    canvas.drawCircle(end, 24, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _HeatTransferPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _CoolingCoreGlowPainter extends CustomPainter {
  final double progress;
  final bool active;
  final double panelTemperature;

  const _CoolingCoreGlowPainter({
    required this.progress,
    required this.active,
    required this.panelTemperature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final center = Offset(size.width * 0.48, size.height * 0.52);

    final hotColor = panelTemperature > 30
        ? Colors.redAccent.withOpacity(0.18)
        : Colors.orangeAccent.withOpacity(0.12);

    final coolColor = Colors.cyanAccent.withOpacity(active ? 0.16 + pulse * 0.08 : 0.0);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          active ? coolColor : hotColor,
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: 72),
      );

    canvas.drawCircle(center, 72, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CoolingCoreGlowPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.panelTemperature != panelTemperature;
  }
}

class _CoolingFlowFieldPainter extends CustomPainter {
  final double progress;

  const _CoolingFlowFieldPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final streamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.cyanAccent.withOpacity(0.16);

    for (int j = 0; j < 4; j++) {
      final baseY = 30.0 + j * 28.0;
      final path = Path();
      path.moveTo(16, baseY);

      for (int i = 1; i <= 24; i++) {
        final t = i / 24;
        final x = 16 + (size.width - 32) * t;
        final y = baseY +
            math.sin((t * math.pi * 3) + progress * math.pi * 2 + j) * 6.0;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, streamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoolingFlowFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PcmTankPainter extends CustomPainter {
  final double progress;
  final double fillLevel;
  final bool active;

  const _PcmTankPainter({
    required this.progress,
    required this.fillLevel,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tankRect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);

    final fillTop = tankRect.bottom - tankRect.height * fillLevel;
    final liquidRect = Rect.fromLTWH(
      tankRect.left,
      fillTop,
      tankRect.width,
      tankRect.bottom - fillTop,
    );

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyanAccent.withOpacity(0.70),
          const Color(0xFF7C4DFF).withOpacity(0.58),
          Colors.white.withOpacity(0.20),
        ],
      ).createShader(liquidRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(liquidRect, const Radius.circular(18)),
      liquidPaint,
    );

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(active ? 0.20 : 0.10)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(liquidRect.left, fillTop + 6);

    for (int i = 0; i <= 20; i++) {
      final t = i / 20;
      final x = liquidRect.left + liquidRect.width * t;
      final y = fillTop +
          math.sin((t * math.pi * 2.5) + progress * math.pi * 2) * 4.5;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(liquidRect.right, liquidRect.bottom);
    wavePath.lineTo(liquidRect.left, liquidRect.bottom);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);

    final bubblePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final x = liquidRect.left + 10 + (i * 5.5) % (liquidRect.width - 20);
      final y = liquidRect.bottom -
          (((progress + i * 0.13) % 1.0) * liquidRect.height * 0.9);
      bubblePaint.color = Colors.white.withOpacity(0.14 + (i % 3) * 0.05);
      canvas.drawCircle(Offset(x, y), 2.0 + (i % 3) * 0.7, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PcmTankPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillLevel != fillLevel ||
        oldDelegate.active != active;
  }
}

class _ThermalOrbitPainter extends CustomPainter {
  final double progress;
  final bool active;

  const _ThermalOrbitPainter({
    required this.progress,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.48, size.height * 0.50);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.04);

    canvas.drawCircle(center, 76, ringPaint);
    canvas.drawCircle(center, 106, ringPaint);

    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (progress * math.pi * 2) + (i * (math.pi / 6));
      final radius = i.isEven ? 76.0 : 106.0;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius * 0.58;

      particlePaint.color = (active
          ? Colors.cyanAccent
          : Colors.orangeAccent)
          .withOpacity(0.10 + (i % 3) * 0.05);

      canvas.drawCircle(Offset(x, y), 2.2 + (i % 2) * 0.8, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThermalOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}