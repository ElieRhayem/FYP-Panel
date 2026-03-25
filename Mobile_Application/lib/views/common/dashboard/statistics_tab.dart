import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final efficiencyScore = (100 - vm.estimatedLoss * 3).clamp(0, 100).toDouble();

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "PERFORMANCE SUMMARY",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Energy Today",
                          value: vm.energyTodayWh.toStringAsFixed(0),
                          unit: "Wh",
                          icon: Icons.bolt_rounded,
                          accent: cs.primary,
                          hint: "Current daily production",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Average Loss",
                          value: vm.estimatedLoss.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.trending_down_rounded,
                          accent: Colors.amberAccent,
                          hint: "Current estimated loss",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Average Soiling",
                          value: vm.soilingIndex.toStringAsFixed(1),
                          unit: "%",
                          icon: Icons.visibility_rounded,
                          accent: const Color(0xFF7C4DFF),
                          hint: "Current mock soiling average",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Cleaning Cycles",
                          value: vm.cleaningCycles.toString(),
                          unit: "",
                          icon: Icons.cleaning_services_rounded,
                          accent: Colors.cyanAccent,
                          hint: "Mock count for now",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "SYSTEM EFFICIENCY",
              child: McRadarScanner(
                healthScore: efficiencyScore,
                title: "EFFICIENCY SCORE",
                accent: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "ENERGY TREND",
              child: MiniBarChart(
                values: vm.energyWeekWh,
                label: "Last 7 days",
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "OPERATIONS",
              child: Column(
                children: [
                  KeyValueRow(
                    k: "Tracker uptime",
                    v: "${vm.trackerUptime.toStringAsFixed(0)}%",
                  ),
                  const SizedBox(height: 8),
                  KeyValueRow(
                    k: "Last cleaning",
                    v: vm.lastCleaningLabel,
                  ),
                  const SizedBox(height: 8),
                  KeyValueRow(
                    k: "Water usage",
                    v: "${vm.waterUsageLiters.toStringAsFixed(1)} L",
                  ),
                  const SizedBox(height: 8),
                  KeyValueRow(
                    k: "Manual overrides",
                    v: vm.manualOverridesCount.toString(),
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