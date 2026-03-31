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
            _SensorsHeroCard(
              total: vm.totalSensors,
              working: vm.workingSensors,
              warnings: vm.warningSensors,
              issues: vm.issueSensors,
            ),
            const SizedBox(height: 14),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select which sensors to display",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildFilterChip(context, "All", SensorFilterType.all),
                      _buildFilterChip(
                          context, "Working", SensorFilterType.working),
                      _buildFilterChip(
                          context, "Warnings", SensorFilterType.warning),
                      _buildFilterChip(
                          context, "Issues", SensorFilterType.issues),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "SENSOR LIST",
              trailing: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.primary.withOpacity(0.10),
                  border: Border.all(color: cs.primary.withOpacity(0.24)),
                ),
                child: Text(
                  "${sensors.length} shown",
                  style: TextStyle(
                    color: cs.primary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
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
    final selected = _filter == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: selected
            ? [
          BoxShadow(
            color: cs.primary.withOpacity(0.16),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ]
            : null,
      ),
      child: ChoiceChip(
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label),
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
        selectedColor: cs.primary.withOpacity(0.18),
        backgroundColor: Colors.white.withOpacity(0.035),
        side: BorderSide(
          color: selected ? cs.primary.withOpacity(0.46) : Colors.white10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelStyle: TextStyle(
          color: selected ? cs.primary : Colors.white70,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SensorsHeroCard extends StatelessWidget {
  final int total;
  final int working;
  final int warnings;
  final int issues;

  const _SensorsHeroCard({
    required this.total,
    required this.working,
    required this.warnings,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    final double healthRatio = total == 0 ? 0 : working / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.18),
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.015),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primary.withOpacity(0.12),
                  border: Border.all(color: cs.primary.withOpacity(0.28)),
                ),
                child: Icon(
                  Icons.sensors,
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SENSOR NETWORK STATUS",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Live health summary of all embedded monitoring sensors",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.68),
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: healthRatio.clamp(0, 1),
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                healthRatio >= 0.8
                    ? Colors.greenAccent
                    : healthRatio >= 0.5
                    ? Colors.amberAccent
                    : Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  "${(healthRatio * 100).toStringAsFixed(0)}% operational",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Text(
                "$working / $total healthy",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStatusPill(
                  icon: Icons.check_circle_rounded,
                  label: "Working",
                  value: "$working",
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatusPill(
                  icon: Icons.warning_amber_rounded,
                  label: "Warnings",
                  value: "$warnings",
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatusPill(
                  icon: Icons.error_rounded,
                  label: "Issues",
                  value: "$issues",
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatusPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.06),
            Colors.white.withOpacity(0.025),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor.withOpacity(0.18),
                  statusColor.withOpacity(0.06),
                ],
              ),
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
                          fontSize: 15.5,
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
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.04),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: statusColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sensor.value,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  sensor.hint,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                    fontSize: 12.5,
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