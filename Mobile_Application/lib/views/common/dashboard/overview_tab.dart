import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/status_light.dart';
import 'package:mobile_application/features/dashboard/dashboard_view_model.dart';
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
                            text: vm.estimatedLoss >= 5
                                ? "TRIGGER: loss > 5%  → cleaning justified"
                                : "HOLD: loss ≤ 5%  → no cleaning",
                            color: vm.estimatedLoss >= 5
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
                      title: "TRACKING",
                      child: Column(
                        children: const [
                          McMetric(
                            label: "Mode",
                            value: "AUTO",
                            unit: "",
                            icon: Icons.explore_rounded,
                            accent: Color(0xFFFFC857),
                            hint: "Predictive logic later with weather",
                          ),
                          SizedBox(height: 10),
                          KeyValueRow(k: "Azimuth", v: "148° (mock)"),
                          SizedBox(height: 6),
                          KeyValueRow(k: "Tilt", v: "32° (mock)"),
                          SizedBox(height: 6),
                          KeyValueRow(k: "Weather", v: "Clear (mock)"),
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
                            dot: vm.estimatedLoss >= 5
                                ? Colors.red
                                : Colors.green,
                            title: vm.estimatedLoss >= 5
                                ? "Cleaning recommended"
                                : "System stable",
                            time: "2s",
                          ),
                          const SizedBox(height: 10),
                          const EventRow(
                            dot: Color(0xFFFFC857),
                            title: "Tracker running",
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
            const SizedBox(height: 16),
            McPanel(
              title: "CONTROL",
              child: Row(
                children: [
                  Expanded(
                    child: ControlButton(
                      icon: Icons.tune_rounded,
                      label: "Open Control Center",
                      onTap: () => _openControlCenter(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openControlCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: McPanel(
            title: "CONTROL CENTER",
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommandTile(
                  icon: Icons.cleaning_services_rounded,
                  title: "Force cleaning",
                  subtitle: "Start cleaning immediately",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                CommandTile(
                  icon: Icons.stop_circle_rounded,
                  title: "Stop cleaning",
                  subtitle: "Abort cleaning cycle",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                CommandTile(
                  icon: Icons.explore_rounded,
                  title: "Tracking Auto / Manual",
                  subtitle: "Switch tracking mode",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                CommandTile(
                  icon: Icons.restart_alt_rounded,
                  title: "Reset system",
                  subtitle: "Restart controller state",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}