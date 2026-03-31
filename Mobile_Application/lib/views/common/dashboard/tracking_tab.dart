import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';

class TrackingTab extends StatelessWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "TRACKING STATUS",
              trailing: Text(
                vm.trackerMode.toUpperCase(),
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
                    value: vm.trackerMode,
                    unit: "",
                    icon: Icons.explore_rounded,
                    accent: const Color(0xFFFFC857),
                    hint: "Auto mode aligns the panel continuously",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Azimuth",
                          value: vm.azimuth.toStringAsFixed(0),
                          unit: "°",
                          icon: Icons.navigation_rounded,
                          accent: cs.primary,
                          hint: "Horizontal direction",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Tilt",
                          value: vm.tilt.toStringAsFixed(0),
                          unit: "°",
                          icon: Icons.change_circle_outlined,
                          accent: const Color(0xFF7C4DFF),
                          hint: "Vertical angle",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "IRRADIANCE MAP",
              trailing: Text(
                vm.brightestDirection,
                style: TextStyle(
                  color: cs.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Column(
                children: [
                  IrradianceSurface3D(
                    topLeft: vm.ldrTopLeft,
                    topRight: vm.ldrTopRight,
                    bottomLeft: vm.ldrBottomLeft,
                    bottomRight: vm.ldrBottomRight,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Avg Irradiance",
                          value: vm.avgIrradiance.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.wb_sunny_outlined,
                          accent: const Color(0xFFFFC857),
                          hint: "Average across 4 LDR sensors",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Brightest Side",
                          value: vm.brightestDirection,
                          unit: "",
                          icon: Icons.ads_click_rounded,
                          accent: cs.primary,
                          hint: "Suggested direction for correction",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "TRACKING CONTROL",
              child: Column(
                children: [
                  DashboardToggleRow(
                    title: "Tracking Manual Mode",
                    subtitle: "Override automatic sun tracking",
                    value: vm.trackingManualMode,
                    border: border,
                    onChanged: vm.setTrackingManualMode,
                  ),
                  const SizedBox(height: 12),
                  DashboardToggleRow(
                    title: "Safety Lock",
                    subtitle: "Disable tracker movement when enabled",
                    value: vm.safetyLock,
                    border: border,
                    onChanged: vm.setSafetyLock,
                  ),
                  const SizedBox(height: 12),
                  _ManualCornerControlCard(vm: vm, border: border),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Stow Panel",
                    subtitle: "Move panel to safe position (UI-only now)",
                    icon: Icons.shield_rounded,
                    border: border,
                    onTap: () {
                      vm.stowPanel();
                      _snack(context, "Stow command simulated");
                    },
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
                    title: "Return to Auto Tracking",
                    subtitle: "Resume predictive tracking logic",
                    icon: Icons.explore_rounded,
                    border: border,
                    onTap: () {
                      vm.returnToAutoTracking();
                      _snack(context, "Auto tracking restored");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "TRACKING HISTORY",
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showTrackingHistoryDialog(context, vm),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.03),
                        cs.primary.withOpacity(0.03),
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
                          color: cs.primary.withOpacity(0.10),
                          border: Border.all(
                            color: cs.primary.withOpacity(0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.track_changes_rounded,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "View tracking activity log",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vm.trackingHistory.isNotEmpty
                                  ? "Last update: ${vm.trackingHistory.first.timeLabel}"
                                  : "No tracking history available yet",
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
                                  icon: Icons.format_list_bulleted_rounded,
                                  label: "${vm.trackingHistory.length} entries",
                                  color: cs.primary,
                                ),
                                _historyChip(
                                  icon: Icons.navigation_rounded,
                                  label: "Az ${vm.azimuth.toStringAsFixed(0)}°",
                                  color: cs.primary,
                                ),
                                _historyChip(
                                  icon: Icons.change_circle_outlined,
                                  label: "Tilt ${vm.tilt.toStringAsFixed(0)}°",
                                  color: const Color(0xFF7C4DFF),
                                ),
                                _historyChip(
                                  icon: Icons.wb_sunny_outlined,
                                  label: "${vm.avgIrradiance.toStringAsFixed(1)}%",
                                  color: const Color(0xFFFFC857),
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

  void _showTrackingHistoryDialog(
      BuildContext context,
      DashboardViewModel vm,
      ) {
    final cs = Theme.of(context).colorScheme;
    final history = vm.trackingHistory;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.primary.withOpacity(0.15)),
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
                        color: cs.primary.withOpacity(0.10),
                        border: Border.all(
                          color: cs.primary.withOpacity(0.22),
                        ),
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Tracking History",
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
                const SizedBox(height: 8),
                Text(
                  "Full activity log for tracking updates, mode changes, orientation values, and irradiance readings.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                    child: Text(
                      "No tracking history recorded yet.",
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

                      final modeColor = entry.mode == "AUTO"
                          ? Colors.greenAccent
                          : entry.mode == "MANUAL"
                          ? Colors.orangeAccent
                          : entry.mode == "SAFE"
                          ? Colors.redAccent
                          : cs.primary;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.03),
                              modeColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: modeColor.withOpacity(0.12),
                                    border: Border.all(
                                      color: modeColor.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Text(
                                    entry.mode.toUpperCase(),
                                    style: TextStyle(
                                      color: modeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  entry.timeLabel,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.62),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Orientation and irradiance snapshot",
                              style: const TextStyle(
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
                                _detailPill("Azimuth", "${entry.azimuth.toStringAsFixed(0)}°"),
                                _detailPill("Tilt", "${entry.tilt.toStringAsFixed(0)}°"),
                                _detailPill("Avg Irradiance", "${entry.avgIrradiance.toStringAsFixed(1)}%"),
                                _detailPill("Brightest", entry.brightestDirection),
                                _detailPill("TL", "${entry.topLeft.toStringAsFixed(0)}%"),
                                _detailPill("TR", "${entry.topRight.toStringAsFixed(0)}%"),
                                _detailPill("BL", "${entry.bottomLeft.toStringAsFixed(0)}%"),
                                _detailPill("BR", "${entry.bottomRight.toStringAsFixed(0)}%"),
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
}

class _ManualCornerControlCard extends StatelessWidget {
  final DashboardViewModel vm;
  final Color border;

  const _ManualCornerControlCard({
    required this.vm,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CORNER HEIGHT CONTROL",
            style: TextStyle(
              color: cs.primary,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vm.manualCornerHint,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CornerControlTile(
                            title: "TOP LEFT",
                            value: vm.cornerTopLeftHeight,
                            enabled: vm.canManualCornerControl,
                            onUp: vm.raiseTopLeft,
                            onDown: vm.lowerTopLeft,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CornerControlTile(
                            title: "TOP RIGHT",
                            value: vm.cornerTopRightHeight,
                            enabled: vm.canManualCornerControl,
                            onUp: vm.raiseTopRight,
                            onDown: vm.lowerTopRight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _CornerControlTile(
                            title: "BOTTOM LEFT",
                            value: vm.cornerBottomLeftHeight,
                            enabled: vm.canManualCornerControl,
                            onUp: vm.raiseBottomLeft,
                            onDown: vm.lowerBottomLeft,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CornerControlTile(
                            title: "BOTTOM RIGHT",
                            value: vm.cornerBottomRightHeight,
                            enabled: vm.canManualCornerControl,
                            onUp: vm.raiseBottomRight,
                            onDown: vm.lowerBottomRight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CornerControlTile extends StatelessWidget {
  final String title;
  final double value;
  final bool enabled;
  final VoidCallback onUp;
  final VoidCallback onDown;

  const _CornerControlTile({
    required this.title,
    required this.value,
    required this.enabled,
    required this.onUp,
    required this.onDown,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        color: Colors.black.withOpacity(0.16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          _CornerArrowButton(
            icon: Icons.keyboard_arrow_up_rounded,
            enabled: enabled,
            onTap: onUp,
          ),
          const SizedBox(height: 8),
          Text(
            "${value.toStringAsFixed(0)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "HEIGHT",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          _CornerArrowButton(
            icon: Icons.keyboard_arrow_down_rounded,
            enabled: enabled,
            onTap: onDown,
          ),
        ],
      ),
    );
  }
}

class _CornerArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CornerArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled ? cs.primary.withOpacity(0.35) : Colors.white10,
          ),
          color: enabled
              ? cs.primary.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
        ),
        child: Icon(
          icon,
          color: enabled ? cs.primary : Colors.white38,
          size: 28,
        ),
      ),
    );
  }
}

class IrradianceSurface3D extends StatelessWidget {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  const IrradianceSurface3D({
    super.key,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.35,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0A0F1E),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _IrradianceSurfacePainter(
                  topLeft: topLeft,
                  topRight: topRight,
                  bottomLeft: bottomLeft,
                  bottomRight: bottomRight,
                ),
              ),
            ),
            const Positioned(
              top: 6,
              left: 10,
              child: Text(
                "TOP",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Positioned(
              bottom: 6,
              left: 10,
              child: Text(
                "BOTTOM",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Positioned(
              top: 6,
              right: 10,
              child: Text(
                "RIGHT",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Positioned(
              top: 6,
              left: 52,
              child: Text(
                "LEFT",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 28,
              child: _cornerBadge("TL", topLeft),
            ),
            Positioned(
              right: 18,
              top: 28,
              child: _cornerBadge("TR", topRight),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              child: _cornerBadge("BL", bottomLeft),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: _cornerBadge("BR", bottomRight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerBadge(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        "$label  ${value.toStringAsFixed(0)}%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _IrradianceSurfacePainter extends CustomPainter {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  _IrradianceSurfacePainter({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  Color _irradianceColor(double value) {
    if (value < 35) return const Color(0xFF1E3A8A); // blue
    if (value < 55) return const Color(0xFF06B6D4); // cyan
    if (value < 75) return const Color(0xFFFACC15); // yellow
    return const Color(0xFFEF4444); // red
  }

  double _height(double value) {
    return value / 100.0;
  }

  Offset _project(double x, double y, double z, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.78;
    final scale = math.min(size.width, size.height) * 0.34;

    final px = centerX + (x - y) * scale;
    final py = baseY - (x + y) * scale * 0.48 - z * 110;

    return Offset(px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final t = i / 5.0;

      final a = _project(0, t, 0, size);
      final b = _project(1, t, 0, size);
      final c = _project(t, 0, 0, size);
      final d = _project(t, 1, 0, size);

      canvas.drawLine(a, b, gridPaint);
      canvas.drawLine(c, d, gridPaint);
    }

    final pTL = _project(0, 0, _height(topLeft), size);
    final pTR = _project(1, 0, _height(topRight), size);
    final pBL = _project(0, 1, _height(bottomLeft), size);
    final pBR = _project(1, 1, _height(bottomRight), size);

    final baseTL = _project(0, 0, 0, size);
    final baseTR = _project(1, 0, 0, size);
    final baseBL = _project(0, 1, 0, size);
    final baseBR = _project(1, 1, 0, size);

    final avg = (topLeft + topRight + bottomLeft + bottomRight) / 4.0;
    final avgColor = _irradianceColor(avg);

    final surfacePath = Path()
      ..moveTo(pTL.dx, pTL.dy)
      ..lineTo(pTR.dx, pTR.dy)
      ..lineTo(pBR.dx, pBR.dy)
      ..lineTo(pBL.dx, pBL.dy)
      ..close();

    final surfacePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.2, size.height * 0.15),
        Offset(size.width * 0.8, size.height * 0.9),
        [
          _irradianceColor(topLeft).withOpacity(0.95),
          _irradianceColor(topRight).withOpacity(0.95),
          _irradianceColor(bottomRight).withOpacity(0.95),
          _irradianceColor(bottomLeft).withOpacity(0.95),
        ],
        const [0.0, 0.32, 0.68, 1.0],
      );

    canvas.drawShadow(surfacePath, avgColor.withOpacity(0.45), 18, false);
    canvas.drawPath(surfacePath, surfacePaint);

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.22);

    canvas.drawPath(surfacePath, edgePaint);

    final wallPaint = Paint()
      ..color = avgColor.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final leftWall = Path()
      ..moveTo(baseTL.dx, baseTL.dy)
      ..lineTo(pTL.dx, pTL.dy)
      ..lineTo(pBL.dx, pBL.dy)
      ..lineTo(baseBL.dx, baseBL.dy)
      ..close();

    final rightWall = Path()
      ..moveTo(baseTR.dx, baseTR.dy)
      ..lineTo(pTR.dx, pTR.dy)
      ..lineTo(pBR.dx, pBR.dy)
      ..lineTo(baseBR.dx, baseBR.dy)
      ..close();

    final frontWall = Path()
      ..moveTo(baseBL.dx, baseBL.dy)
      ..lineTo(pBL.dx, pBL.dy)
      ..lineTo(pBR.dx, pBR.dy)
      ..lineTo(baseBR.dx, baseBR.dy)
      ..close();

    canvas.drawPath(leftWall, wallPaint);
    canvas.drawPath(rightWall, wallPaint);
    canvas.drawPath(frontWall, wallPaint);

    final pointPaint = Paint()..style = PaintingStyle.fill;

    void drawPoint(Offset p, double value) {
      final color = _irradianceColor(value);
      pointPaint.color = color;
      canvas.drawCircle(p, 7, pointPaint);
      canvas.drawCircle(
        p,
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color.withOpacity(0.45),
      );
    }

    drawPoint(pTL, topLeft);
    drawPoint(pTR, topRight);
    drawPoint(pBL, bottomLeft);
    drawPoint(pBR, bottomRight);
  }

  @override
  bool shouldRepaint(covariant _IrradianceSurfacePainter oldDelegate) {
    return oldDelegate.topLeft != topLeft ||
        oldDelegate.topRight != topRight ||
        oldDelegate.bottomLeft != bottomLeft ||
        oldDelegate.bottomRight != bottomRight;
  }
}