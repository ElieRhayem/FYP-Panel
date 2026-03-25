import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/status_light.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_helpers.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final status = statusFromLoss(vm.estimatedLoss);
    final statusColor = statusColorFromStatus(status);

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "SYSTEM STATUS",
              trailing: StatusLight(color: statusColor, label: status),
              child: Row(
                children: [
                  Expanded(
                    child: BigReadout(
                      label: "POWER",
                      value: vm.powerW,
                      unit: "W",
                      accent: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BigReadout(
                      label: "LOSS",
                      value: vm.estimatedLoss,
                      unit: "%",
                      accent: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "OVERALL HEALTH",
              child: McRadarScanner(
                healthScore: vm.overallHealth,
                title: "SYSTEM HEALTH",
                accent: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, c) {
                final twoCols = c.maxWidth > 720;

                final left = Column(
                  children: [
                    McPanel(
                      title: "ENERGY",
                      child: Column(
                        children: [
                          McMetric(
                            label: "Energy Today",
                            value: vm.energyTodayWh.toStringAsFixed(0),
                            unit: "Wh",
                            icon: Icons.stacked_line_chart_rounded,
                            accent: cs.primary,
                            hint: "Accumulated production",
                          ),
                          const SizedBox(height: 10),
                          MiniBarChart(
                            values: vm.energyWeekWh,
                            label: "Last 7 days",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    McPanel(
                      title: "SOILING",
                      child: Column(
                        children: [
                          McMetric(
                            label: "Soiling Index",
                            value: vm.soilingIndex.toStringAsFixed(1),
                            unit: "%",
                            icon: Icons.visibility_rounded,
                            accent: const Color(0xFF7C4DFF),
                            hint: "From camera scan",
                          ),
                          const SizedBox(height: 10),
                          ThresholdLine(
                            title: "Cleaning rule",
                            text: vm.cleaningRecommended
                                ? "TRIGGER: loss > 5%  → cleaning justified"
                                : "HOLD: loss ≤ 5%  → no cleaning",
                            color: vm.cleaningRecommended
                                ? Colors.red
                                : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final right = Column(
                  children: [
                    McPanel(
                      title: "TRACKING SNAPSHOT",
                      child: Column(
                        children: [
                          McMetric(
                            label: "Mode",
                            value: vm.trackerMode,
                            unit: "",
                            icon: Icons.explore_rounded,
                            accent: const Color(0xFFFFC857),
                            hint: "Predictive logic later with weather",
                          ),
                          const SizedBox(height: 10),
                          KeyValueRow(
                            k: "Azimuth",
                            v: "${vm.azimuth.toStringAsFixed(0)}°",
                          ),
                          const SizedBox(height: 6),
                          KeyValueRow(
                            k: "Tilt",
                            v: "${vm.tilt.toStringAsFixed(0)}°",
                          ),
                          const SizedBox(height: 6),
                          KeyValueRow(
                            k: "Weather",
                            v: vm.weatherStatus,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    McPanel(
                      title: "EVENTS",
                      child: Column(
                        children: [
                          const EventRow(
                            dot: Colors.cyan,
                            title: "Live feed active",
                            time: "now",
                          ),
                          const SizedBox(height: 10),
                          EventRow(
                            dot: vm.cleaningRecommended
                                ? Colors.red
                                : Colors.green,
                            title: vm.cleaningRecommended
                                ? "Cleaning recommended"
                                : "System stable",
                            time: "2s",
                          ),
                          const SizedBox(height: 10),
                          EventRow(
                            dot: vm.windSensorOnline
                                ? const Color(0xFFFFC857)
                                : Colors.redAccent,
                            title: vm.windSensorOnline
                                ? "Tracker running"
                                : "Wind sensor issue",
                            time: "2s",
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                if (twoCols) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 14),
                      Expanded(child: right),
                    ],
                  );
                }

                return Column(
                  children: [
                    left,
                    const SizedBox(height: 14),
                    right,
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}