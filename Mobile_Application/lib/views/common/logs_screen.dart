import 'package:flutter/material.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/widgets/grid_background.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      ("Cleaning started", "Loss exceeded 5%", "10:12"),
      ("Cleaning stopped", "Cycle complete", "10:15"),
      ("Tracker stowed", "Wind alert", "11:02"),
      ("Tracker resumed", "Weather OK", "11:30"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackground()),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              McPanel(
                title: "EVENT LOGS",
                child: Column(
                  children: logs.map((log) {
                    final (title, detail, time) = log;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              time,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}