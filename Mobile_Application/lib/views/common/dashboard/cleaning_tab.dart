import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/mc_sensor_panel.dart';
import 'package:mobile_application/core/widgets/mc_timeline.dart';
import 'package:mobile_application/features/dashboard/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';

class CleaningTab extends StatelessWidget {
  const CleaningTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final cleaningRecommended = vm.estimatedLoss >= 5;

    final sensors = [
      const SensorStatus(
        name: "Water pump",
        online: true,
        strength: 4,
        hint: "Pressure stable",
      ),
      const SensorStatus(
        name: "Water level",
        online: true,
        strength: 3,
        hint: "Tank status OK",
      ),
      const SensorStatus(
        name: "Nozzle valve",
        online: true,
        strength: 3,
        hint: "Actuator ready",
      ),
      const SensorStatus(
        name: "Temp safety",
        online: true,
        strength: 2,
        hint: "Within limits",
      ),
    ];

    final events = [
      McEvent(
        time: DateTime.now(),
        title: "Cleaning logic evaluated",
        details: cleaningRecommended ? "Recommended (loss > 5%)" : "Not required",
        dot: cleaningRecommended ? Colors.redAccent : Colors.greenAccent,
      ),
      McEvent(
        time: DateTime.now().subtract(const Duration(seconds: 10)),
        title: "Soiling scan complete",
        details: "Index updated from camera module",
        dot: const Color(0xFF7C4DFF),
      ),
      McEvent(
        time: DateTime.now().subtract(const Duration(seconds: 18)),
        title: "Pump ready",
        details: "Standby state",
        dot: Colors.cyanAccent,
      ),
    ];

    final cleaningHealth = (cleaningRecommended ? 78 : 92).toDouble();

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "CLEANING DECISION",
              trailing: Text(
                cleaningRecommended ? "RECOMMENDED" : "HOLD",
                style: TextStyle(
                  color: cleaningRecommended ? Colors.redAccent : Colors.greenAccent,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Soiling Index",
                          value: vm.soilingIndex.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.visibility_rounded,
                          accent: const Color(0xFF7C4DFF),
                          hint: "From camera scan",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Estimated Loss",
                          value: vm.estimatedLoss.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.warning_rounded,
                          accent: cleaningRecommended
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          hint: cleaningRecommended
                              ? "Above threshold"
                              : "Below threshold",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  McMetric(
                    label: "Action",
                    value: cleaningRecommended ? "Start cleaning cycle" : "Do nothing",
                    unit: "",
                    icon: Icons.cleaning_services_rounded,
                    accent: cs.primary,
                    hint: "Later this becomes a real command to Raspberry Pi",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "SYSTEM READINESS",
              child: Row(
                children: [
                  Expanded(
                    child: McRadarScanner(
                      healthScore: cleaningHealth,
                      title: "CLEANING HEALTH",
                      accent: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: McSensorPanel(
                      title: "ACTUATORS",
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