import 'package:flutter/material.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';

class OverridesTab extends StatelessWidget {
  const OverridesTab({super.key});

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
                  ToggleRow(
                    title: "Tracking Manual Mode",
                    subtitle: "Override auto tracking decisions",
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  ToggleRow(
                    title: "Force Cleaning Ready",
                    subtitle: "Allow cleaning even if not recommended",
                    border: border,
                  ),
                  const SizedBox(height: 12),
                  ToggleRow(
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
                  CommandButtonCard(
                    title: "Send RESET",
                    subtitle: "Reset controller state (UI-only now)",
                    icon: Icons.restart_alt_rounded,
                    border: border,
                    onTap: () => _snack(
                      context,
                      "Later: send reset to Firebase → Raspberry Pi",
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommandButtonCard(
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