import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/mc_sensor_panel.dart';
import 'package:mobile_application/core/widgets/mc_timeline.dart';
import 'package:mobile_application/core/widgets/status_light.dart';
import 'package:mobile_application/features/dashboard/dashboard_view_model.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';
import 'package:mobile_application/widgets/grid_background.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  int _currentIndex = 0;

  Future<void> _signOut(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/logIn/');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: const Center(
            child: Text(
              "Logout",
              style: TextStyle(
                color: AppTheme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.border),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppTheme.text),
                      ),
                    ),
                  ),
                  Container(
                    height: 36,
                    width: 1,
                    color: AppTheme.border,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut(context);
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  String get _title {
    switch (_currentIndex) {
      case 0:
        return "Mission Control";
      case 1:
        return "Tracking";
      case 2:
        return "Cleaning";
      case 3:
        return "Overrides";
      default:
        return "Mission Control";
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OverviewTab(),
      const _TrackingTab(),
      const _CleaningTab(),
      const _OverridesTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/logs/'),
              icon: const Icon(Icons.receipt_long_rounded),
              tooltip: "Logs",
            ),
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Sign Out",
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        elevation: 0,
        selectedIndex: _currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
            selectedIcon: Icon(Icons.cleaning_services),
            label: 'Cleaning',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Overrides',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final status = _statusFromLoss(vm.estimatedLoss);
    final statusColor = _statusColor(status);

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
                    child: _BigReadout(
                      label: "POWER",
                      value: vm.powerW,
                      unit: "W",
                      accent: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigReadout(
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
                          _MiniBarChart(
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
                          _ThresholdLine(
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
                          const _KeyValueRow(k: "Azimuth", v: "148° (mock)"),
                          const SizedBox(height: 6),
                          const _KeyValueRow(k: "Tilt", v: "32° (mock)"),
                          const SizedBox(height: 6),
                          const _KeyValueRow(k: "Weather", v: "Clear (mock)"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    McPanel(
                      title: "EVENTS",
                      child: Column(
                        children: [
                          const _EventRow(
                            dot: Colors.cyan,
                            title: "Live feed active",
                            time: "now",
                          ),
                          const SizedBox(height: 10),
                          _EventRow(
                            dot: vm.estimatedLoss >= 5
                                ? Colors.red
                                : Colors.green,
                            title: vm.estimatedLoss >= 5
                                ? "Cleaning recommended"
                                : "System stable",
                            time: "2s",
                          ),
                          const SizedBox(height: 10),
                          const _EventRow(
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
                    child: _ControlButton(
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
                _CommandTile(
                  icon: Icons.cleaning_services_rounded,
                  title: "Force cleaning",
                  subtitle: "Start cleaning immediately",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                _CommandTile(
                  icon: Icons.stop_circle_rounded,
                  title: "Stop cleaning",
                  subtitle: "Abort cleaning cycle",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                _CommandTile(
                  icon: Icons.explore_rounded,
                  title: "Tracking Auto / Manual",
                  subtitle: "Switch tracking mode",
                  onTap: () => _snack(context, "Later: write command to Firebase"),
                ),
                _CommandTile(
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

class _TrackingTab extends StatelessWidget {
  const _TrackingTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final sensors = [
      const SensorStatus(name: "Sun sensor", online: true, strength: 4, hint: "Direction reference"),
      const SensorStatus(name: "Gyro/IMU", online: true, strength: 3, hint: "Tilt stabilization"),
      const SensorStatus(name: "Motor driver", online: true, strength: 3, hint: "Actuator feedback"),
      const SensorStatus(name: "Wind sensor", online: false, strength: 0, hint: "Safety constraint"),
    ];

    final events = [
      McEvent(time: DateTime.now(), title: "Tracking loop running", details: "Control signal stable", dot: Colors.cyanAccent),
      McEvent(time: DateTime.now().subtract(const Duration(seconds: 8)), title: "Orientation updated", details: "Azimuth adjusted by +2°", dot: const Color(0xFFFFC857)),
      McEvent(time: DateTime.now().subtract(const Duration(seconds: 16)), title: "Wind sensor offline", details: "Fallback safety mode enabled", dot: Colors.redAccent),
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

class _CleaningTab extends StatelessWidget {
  const _CleaningTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final cleaningRecommended = vm.estimatedLoss >= 5;

    final sensors = [
      const SensorStatus(name: "Water pump", online: true, strength: 4, hint: "Pressure stable"),
      const SensorStatus(name: "Water level", online: true, strength: 3, hint: "Tank status OK"),
      const SensorStatus(name: "Nozzle valve", online: true, strength: 3, hint: "Actuator ready"),
      const SensorStatus(name: "Temp safety", online: true, strength: 2, hint: "Within limits"),
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
                          accent: cleaningRecommended ? Colors.redAccent : Colors.greenAccent,
                          hint: cleaningRecommended ? "Above threshold" : "Below threshold",
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

class _OverridesTab extends StatelessWidget {
  const _OverridesTab();

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            McPanel(
              title: "MANUAL OVERRIDES",
              child: Column(
                children: [
                  _ToggleRow(
                    title: "Tracking Manual Mode",
                    subtitle: "Override auto tracking decisions",
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    title: "Force Cleaning Ready",
                    subtitle: "Allow cleaning even if not recommended",
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    title: "Safety Lock",
                    subtitle: "Disable actuators when enabled",
                    border: border,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "COMMANDS",
              child: Column(
                children: [
                  _CommandButtonCard(
                    title: "Send RESET",
                    subtitle: "Reset controller state (UI-only now)",
                    icon: Icons.restart_alt_rounded,
                    border: border,
                    onTap: () => _snack(context, "Later: send reset to Firebase → Raspberry Pi"),
                  ),
                  const SizedBox(height: 12),
                  _CommandButtonCard(
                    title: "Send STOP ALL",
                    subtitle: "Emergency stop (UI-only now)",
                    icon: Icons.stop_circle_rounded,
                    border: border,
                    onTap: () => _snack(context, "Later: send emergency stop"),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _BigReadout extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color accent;

  const _BigReadout({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: muted, letterSpacing: 1.4)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 140,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.5),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.35), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdLine extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const _ThresholdLine({
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: muted,
                    letterSpacing: 0.8,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String k;
  final String v;

  const _KeyValueRow({required this.k, required this.v});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;
    return Row(
      children: [
        Expanded(
          child: Text(
            k.toUpperCase(),
            style: TextStyle(color: muted, letterSpacing: 0.8, fontSize: 12),
          ),
        ),
        Text(v, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final Color dot;
  final String title;
  final String time;

  const _EventRow({
    required this.dot,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: dot,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: dot.withOpacity(0.6), blurRadius: 10)],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(time, style: TextStyle(color: muted)),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerTheme.color ?? Colors.white24;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CommandTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final List<double> values;
  final String label;

  const _MiniBarChart({
    required this.values,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.labelMedium?.color ?? Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: muted, letterSpacing: 0.8, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: CustomPaint(
              painter: _BarsPainter(values),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> values;
  _BarsPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxV = values.reduce(math.max);
    final barPaint = Paint()..color = Colors.cyanAccent.withOpacity(0.75);
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.08);

    const gap = 6.0;
    final w = (size.width - gap * (values.length - 1)) / values.length;

    canvas.drawRect(Rect.fromLTWH(0, size.height - 1, size.width, 1), bgPaint);

    for (int i = 0; i < values.length; i++) {
      final h = (values[i] / (maxV == 0 ? 1 : maxV)) * (size.height - 6);
      final x = i * (w + gap);
      final y = size.height - h;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _ToggleRow extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color border;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.border,
  });

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  bool v = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: v,
        onChanged: (x) => setState(() => v = x),
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(widget.subtitle),
      ),
    );
  }
}

class _CommandButtonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color border;
  final VoidCallback onTap;

  const _CommandButtonCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

String _statusFromLoss(double loss) {
  if (loss >= 8) return "CRITICAL";
  if (loss >= 5) return "ATTENTION";
  return "OK";
}

Color _statusColor(String status) {
  switch (status) {
    case "OK":
      return Colors.greenAccent;
    case "ATTENTION":
      return Colors.amberAccent;
    default:
      return Colors.redAccent;
  }
}