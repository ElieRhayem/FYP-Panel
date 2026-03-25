import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/mc_sensor_panel.dart';
import 'package:mobile_application/core/widgets/mc_timeline.dart';
import 'package:mobile_application/features/dashboard/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';

class TrackingTab extends StatelessWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

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
      const SensorStatus(
        name: "Wind sensor",
        online: false,
        strength: 0,
        hint: "Safety constraint",
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
        details: "Azimuth adjusted by +2°",
        dot: const Color(0xFFFFC857),
      ),
      McEvent(
        time: DateTime.now().subtract(const Duration(seconds: 16)),
        title: "Wind sensor offline",
        details: "Fallback safety mode enabled",
        dot: Colors.redAccent,
      ),
    ];

    final health = (100 - vm.estimatedLoss * 3).clamp(0, 100).toDouble();

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
                          value: "148",
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
                          value: "32",
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
                      healthScore: health,
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
          ],
        ),
      ],
    );
  }
}