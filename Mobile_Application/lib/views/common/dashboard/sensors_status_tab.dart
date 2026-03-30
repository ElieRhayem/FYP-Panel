import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';

enum SensorFilterType { all, working, warning, issues }

class SensorsStatusTab extends StatefulWidget {
  const SensorsStatusTab({super.key});

  @override
  State<SensorsStatusTab> createState() => _SensorsStatusTabState();
}

class _SensorsStatusTabState extends State<SensorsStatusTab> {
  SensorFilterType _filter = SensorFilterType.all;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    final sensors = vm.sensorsStatus.where((sensor) {
      switch (_filter) {
        case SensorFilterType.working:
          return sensor.state == SensorHealthState.working;
        case SensorFilterType.warning:
          return sensor.state == SensorHealthState.warning;
        case SensorFilterType.issues:
          return sensor.state == SensorHealthState.issue;
        case SensorFilterType.all:
          return true;
      }
    }).toList();

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "SENSORS OVERVIEW",
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Total",
                          value: vm.totalSensors.toString(),
                          unit: "",
                          icon: Icons.sensors_rounded,
                          accent: cs.primary,
                          hint: "Registered in mock dashboard",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Working",
                          value: vm.workingSensors.toString(),
                          unit: "",
                          icon: Icons.check_circle_rounded,
                          accent: Colors.greenAccent,
                          hint: "Healthy sensors",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Warnings",
                          value: vm.warningSensors.toString(),
                          unit: "",
                          icon: Icons.warning_amber_rounded,
                          accent: Colors.amberAccent,
                          hint: "Need attention",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "Issues",
                          value: vm.issueSensors.toString(),
                          unit: "",
                          icon: Icons.error_rounded,
                          accent: Colors.redAccent,
                          hint: "Fault/offline states",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "FILTER",
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip(context, "All", SensorFilterType.all),
                  _buildFilterChip(context, "Working", SensorFilterType.working),
                  _buildFilterChip(context, "Warnings", SensorFilterType.warning),
                  _buildFilterChip(context, "Issues", SensorFilterType.issues),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "SENSOR LIST",
              trailing: Text(
                "${sensors.length} shown",
                style: TextStyle(
                  color: cs.primary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < sensors.length; i++) ...[
                    _SensorStatusCard(
                      sensor: sensors[i],
                      border: border,
                    ),
                    if (i != sensors.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      BuildContext context,
      String label,
      SensorFilterType value,
      ) {
    final cs = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
      selectedColor: cs.primary.withOpacity(0.18),
      backgroundColor: Colors.white.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _filter == value
              ? cs.primary.withOpacity(0.45)
              : Colors.white10,
        ),
      ),
      labelStyle: TextStyle(
        color: _filter == value ? cs.primary : Colors.white70,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SensorStatusCard extends StatelessWidget {
  final DashboardSensorItem sensor;
  final Color border;

  const _SensorStatusCard({
    required this.sensor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(sensor.state);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: statusColor.withOpacity(0.12),
              border: Border.all(color: statusColor.withOpacity(0.32)),
            ),
            child: Icon(
              sensor.icon,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sensor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _StatusBadge(
                      label: _statusText(sensor.state),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sensor.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sensor.value,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sensor.hint,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(SensorHealthState state) {
    switch (state) {
      case SensorHealthState.working:
        return Colors.greenAccent;
      case SensorHealthState.warning:
        return Colors.amberAccent;
      case SensorHealthState.issue:
        return Colors.redAccent;
    }
  }

  String _statusText(SensorHealthState state) {
    switch (state) {
      case SensorHealthState.working:
        return "WORKING";
      case SensorHealthState.warning:
        return "WARNING";
      case SensorHealthState.issue:
        return "ISSUE";
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.10),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}