import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/mc_sensor_panel.dart';
import 'package:mobile_application/core/widgets/mc_timeline.dart';
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

    final sensors = [
      const SensorStatus(
        name: "Sun sensor",
        online: true,
        strength: 4,
        hint: "Direction reference",
      ),
      const SensorStatus(
        name: "Gyro/IMU",
        online: true,
        strength: 3,
        hint: "Tilt stabilization",
      ),
      const SensorStatus(
        name: "Motor driver",
        online: true,
        strength: 3,
        hint: "Actuator feedback",
      ),
      SensorStatus(
        name: "Wind sensor",
        online: vm.windSensorOnline,
        strength: vm.windSensorOnline ? 3 : 0,
        hint: vm.windSensorOnline ? "Safety constraint OK" : "Safety constraint",
      ),
    ];

    final events = [
      McEvent(
        time: DateTime.now(),
        title: "Tracking loop running",
        details: "Control signal stable",
        dot: Colors.cyanAccent,
      ),
      McEvent(
        time: DateTime.now().subtract(const Duration(seconds: 8)),
        title: "Orientation updated",
        details: "Azimuth ${vm.azimuth.toStringAsFixed(0)}° / Tilt ${vm.tilt.toStringAsFixed(0)}°",
        dot: const Color(0xFFFFC857),
      ),
      McEvent(
        time: DateTime.now().subtract(const Duration(seconds: 16)),
        title: vm.windSensorOnline ? "Wind sensor online" : "Wind sensor offline",
        details: vm.windSensorOnline
            ? "Tracker operating normally"
            : "Fallback safety mode enabled",
        dot: vm.windSensorOnline ? Colors.greenAccent : Colors.redAccent,
      ),
    ];

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
              title: "HEALTH",
              child: Row(
                children: [
                  Expanded(
                    child: McRadarScanner(
                      healthScore: vm.trackerHealth,
                      title: "TRACKER HEALTH",
                      accent: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: McSensorPanel(
                      title: "SENSOR ONLINE",
                      sensors: sensors,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "EVENT STREAM",
              child: McTimeline(events: events),
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
}