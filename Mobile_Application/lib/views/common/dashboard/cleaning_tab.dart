import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';

class CleaningTab extends StatefulWidget {
  const CleaningTab({super.key});

  @override
  State<CleaningTab> createState() => _CleaningTabState();
}

class _CleaningTabState extends State<CleaningTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _washController;

  @override
  void initState() {
    super.initState();
    _washController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  void _syncAnimation(bool active) {
    if (active) {
      if (!_washController.isAnimating) {
        _washController.repeat();
      }
    } else {
      if (_washController.isAnimating) {
        _washController.stop();
      }
      if (_washController.value != 0) {
        _washController.reset();
      }
    }
  }

  @override
  void dispose() {
    _washController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;
    final cleaningManualActive = vm.cleaningMode == "MANUAL";
    _syncAnimation(vm.cleaningInProgress);

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "CLEANING STATUS",
              trailing: Text(
                vm.cleaningMode.toUpperCase(),
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
                    value: vm.cleaningMode,
                    unit: "",
                    icon: Icons.cleaning_services_rounded,
                    accent: cleaningManualActive
                        ? cs.primary
                        : const Color(0xFFFFC857),
                    hint: cleaningManualActive
                        ? "Manual cleaning override enabled"
                        : "Current cleaning operating state",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Soiling Index",
                          value: vm.soilingIndex.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.visibility_rounded,
                          accent: cleaningManualActive
                              ? cs.primary
                              : const Color(0xFF7C4DFF),
                          hint: vm.soilingIndex >= 20
                              ? "Heavy surface dust detected"
                              : vm.soilingIndex >= 10
                              ? "Moderate dust accumulation"
                              : "Panel surface mostly clean",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Estimated Loss",
                          value: vm.estimatedLoss.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.warning_rounded,
                          accent: cleaningManualActive
                              ? cs.primary
                              : (vm.cleaningRecommended ? Colors.redAccent : Colors.greenAccent),
                          hint: vm.cleaningRecommended
                              ? "Above threshold"
                              : "Below threshold",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "CLEANING CONTROL",
              child: Column(
                children: [
                  DashboardToggleRow(
                    title: "Cleaning Manual Mode",
                    subtitle: "Allow cleaning even if not recommended",
                    value: vm.forceCleaningReady,
                    border: border,
                    onChanged: vm.setForceCleaningReady,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _washController,
                      builder: (context, _) {
                        return _SolarPanelCleaningAnimation(
                          active: vm.cleaningInProgress,
                          progress: _washController.value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vm.cleaningInProgress
                        ? ""
                        : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Start Cleaning Now",
                    subtitle: "Start cleaning cycle manually (UI-only now)",
                    icon: Icons.play_arrow_rounded,
                    border: border,
                    onTap: () {
                      if (!vm.forceCleaningReady) {
                        _snack(context, "Enable Manual Cleaning first");
                        return;
                      }

                      vm.startCleaningNow();
                      _snack(context, "Cleaning start simulated");
                    },
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Stop Cleaning",
                    subtitle: "Abort current cleaning cycle",
                    icon: Icons.stop_circle_rounded,
                    border: border,
                    onTap: () {
                      if (!vm.forceCleaningReady) {
                        _snack(context, "Enable Manual Cleaning first");
                        return;
                      }

                      vm.stopCleaning();
                      _snack(context, "Cleaning stop simulated");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "CLEANING HISTORY",
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showCleaningHistoryDialog(context, vm),
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
                              "View cleaning activity log",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vm.cleaningHistory.isNotEmpty
                                  ? "Last update: ${_formatFullDateTime(vm.cleaningHistory.first.timestamp)}"
                                  : "No cleaning history available yet",
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
                                  icon: Icons.visibility_rounded,
                                  label: "Soiling ${vm.soilingIndex.toStringAsFixed(1)}%",
                                ),
                                _historyChip(
                                  icon: Icons.warning_rounded,
                                  label: "Loss ${vm.estimatedLoss.toStringAsFixed(1)}%",
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

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _formatFullDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy • HH:mm:ss').format(dt);
  }

  Widget _historyChip({
    required IconData icon,
    required String label,
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
          Icon(icon, size: 14, color: Colors.cyanAccent),
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

  void _showCleaningHistoryDialog(BuildContext context, DashboardViewModel vm) {
    showDialog(
      context: context,
      builder: (_) {
        final history = vm.cleaningHistory;

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
                        Icons.history_rounded,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Cleaning History",
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
                      "No cleaning history recorded yet.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final statusColor = entry.status == "Completed"
                          ? Colors.greenAccent
                          : entry.status == "Running"
                          ? Colors.cyanAccent
                          : entry.status == "Recommended"
                          ? Colors.orangeAccent
                          : Colors.redAccent;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                              "Cleaning snapshot",
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
                                _detailPill("Soiling", "${entry.soilingIndex.toStringAsFixed(1)}%"),
                                _detailPill("Loss", "${entry.estimatedLoss.toStringAsFixed(1)}%"),
                                _detailPill("Mode", entry.source),
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
}

class _SolarPanelCleaningAnimation extends StatelessWidget {
  final bool active;
  final double progress;

  const _SolarPanelCleaningAnimation({
    required this.active,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final panelWidth = math.min(width * 0.84, 370.0);
        final panelHeight = math.min(height * 0.62, 155.0);

        final carriageTravel = panelWidth - 70;
        final carriageX = 22 + carriageTravel * progress;
        final cleanedFraction = active ? (progress * 1.08).clamp(0.0, 1.0) : 0.0;
        final shineX = -panelWidth * 0.25 + (panelWidth * 1.5 * progress);
        final pulse = active ? (0.75 + 0.25 * math.sin(progress * math.pi * 2)) : 0.0;

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 12,
                child: Container(
                  width: panelWidth * 0.58,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyanAccent.withOpacity(0.0),
                        Colors.cyanAccent.withOpacity(0.16),
                        Colors.cyanAccent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: panelWidth,
                      height: panelHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.34),
                          width: 1.4,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF091327),
                            Color(0xFF142A55),
                            Color(0xFF0D1B38),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.38),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.08),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _SolarGridPainter(),
                              ),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _DustOverlayPainter(
                                  cleanedFraction: cleanedFraction,
                                  active: active,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.04),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (active)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _WaterSprayPainter(
                                      progress: progress,
                                      carriageX: carriageX,
                                    ),
                                  ),
                                ),
                              ),
                            if (active)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: _DripPainter(progress: progress),
                                  ),
                                ),
                              ),
                            Positioned(
                              left: shineX,
                              top: -20,
                              bottom: -20,
                              child: IgnorePointer(
                                child: Transform.rotate(
                                  angle: 0.22,
                                  child: Container(
                                    width: panelWidth * 0.16,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(active ? 0.13 : 0.05),
                                          Colors.cyanAccent.withOpacity(active ? 0.12 : 0.04),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      top: -18,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF7D8EAF).withOpacity(0.50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -28,
                      left: carriageX,
                      child: _CleaningCarriage(
                        active: active,
                        pulse: pulse,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: -8,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(panelWidth, panelHeight + 12),
                          painter: active
                              ? _NozzleBeamPainter(carriageX: carriageX, progress: progress)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (active)
                Positioned(
                  top: 2,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(0.20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyanAccent.withOpacity(0.85),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.45),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "WASH ACTIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CleaningCarriage extends StatelessWidget {
  final bool active;
  final double pulse;

  const _CleaningCarriage({
    required this.active,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFBCC8DE),
                Color(0xFF6E7F9F),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? Colors.cyanAccent.withOpacity(0.7 + 0.2 * pulse)
                    : Colors.white24,
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
            ),
          ),
        ),
        Container(
          width: 44,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.85),
                Colors.cyanAccent.withOpacity(0.75),
                Colors.white.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.18),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SolarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.17)
      ..strokeWidth = 1;

    const cols = 5;
    const rows = 4;

    for (int i = 1; i < cols; i++) {
      final dx = size.width * i / cols;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    for (int i = 1; i < rows; i++) {
      final dy = size.height * i / rows;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final cellPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellW + 6,
          r * cellH + 6,
          cellW - 12,
          cellH - 12,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          cellPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DustOverlayPainter extends CustomPainter {
  final double cleanedFraction;
  final bool active;

  const _DustOverlayPainter({
    required this.cleanedFraction,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dustPaint = Paint();

    final dirtyRect = Rect.fromLTWH(
      size.width * cleanedFraction,
      0,
      size.width * (1 - cleanedFraction),
      size.height,
    );

    if (dirtyRect.width > 0) {
      dustPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF826C54).withOpacity(0.24),
          const Color(0xFFB0916C).withOpacity(0.18),
          const Color(0xFF705B46).withOpacity(0.22),
        ],
      ).createShader(dirtyRect);

      canvas.drawRect(dirtyRect, dustPaint);
    }

    final spotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final x = (i * 29.0 + 16) % size.width;
      final y = (i * 19.0 + 12) % size.height;
      final radius = 2.5 + (i % 4) * 1.8;

      if (x < size.width * cleanedFraction && active) continue;

      spotPaint.color = const Color(0xFFC8AA82).withOpacity(0.16 + (i % 3) * 0.06);
      canvas.drawCircle(Offset(x, y), radius, spotPaint);
    }

    if (active) {
      final foamX = size.width * cleanedFraction;
      final foamPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.12),
            Colors.cyanAccent.withOpacity(0.12),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromLTWH(foamX - 22, 0, 44, size.height),
        );

      canvas.drawRect(
        Rect.fromLTWH(
          math.max(0, foamX - 18),
          0,
          36,
          size.height,
        ),
        foamPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustOverlayPainter oldDelegate) {
    return oldDelegate.cleanedFraction != cleanedFraction ||
        oldDelegate.active != active;
  }
}

class _NozzleBeamPainter extends CustomPainter {
  final double carriageX;
  final double progress;

  const _NozzleBeamPainter({
    required this.carriageX,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseX = carriageX + 22;

    final paint1 = Paint()
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = Colors.cyanAccent.withOpacity(0.24);

    final paint2 = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.22);

    final sway = math.sin(progress * math.pi * 2) * 2.5;

    for (int i = -2; i <= 2; i++) {
      final startX = baseX + i * 8;
      final endX = startX + sway + i * 1.5;
      canvas.drawLine(
        Offset(startX, 2),
        Offset(endX, size.height * 0.72),
        paint1,
      );
      canvas.drawLine(
        Offset(startX + 1.5, 6),
        Offset(endX + 2, size.height * 0.54),
        paint2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NozzleBeamPainter oldDelegate) {
    return oldDelegate.carriageX != carriageX ||
        oldDelegate.progress != progress;
  }
}

class _WaterSprayPainter extends CustomPainter {
  final double progress;
  final double carriageX;

  const _WaterSprayPainter({
    required this.progress,
    required this.carriageX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mistPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyanAccent.withOpacity(0.08);

    final splashPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.18);

    final centerX = carriageX + 22;

    for (int i = 0; i < 16; i++) {
      final dx = centerX - 30 + i * 4.0 + math.sin(progress * math.pi * 2 + i) * 2.0;
      final dy = 18 + (i % 5) * 18.0 + ((progress * 90 + i * 7) % 40);
      if (dx < 0 || dx > size.width || dy > size.height) continue;
      canvas.drawCircle(Offset(dx, dy), 2.2 + (i % 3) * 0.7, mistPaint);
    }

    for (int i = 0; i < 10; i++) {
      final dx = centerX - 18 + i * 4.0;
      final dy = size.height * 0.18 + ((progress * 120 + i * 9) % (size.height * 0.56));
      if (dx < 0 || dx > size.width || dy > size.height) continue;
      canvas.drawCircle(Offset(dx, dy), 1.4 + (i % 2), splashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterSprayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.carriageX != carriageX;
  }
}

class _DripPainter extends CustomPainter {
  final double progress;

  const _DripPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final dripPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    for (int i = 0; i < 9; i++) {
      final x = 22.0 + i * (size.width - 44) / 8;
      final phase = (progress + i * 0.09) % 1.0;
      final length = 8 + 10 * (0.5 + 0.5 * math.sin(phase * math.pi * 2));
      canvas.drawLine(
        Offset(x, size.height - 2),
        Offset(x, size.height - 2 + length),
        dripPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DripPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}