import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  double powerW = 120.0;
  double energyTodayWh = 540.0;
  double soilingIndex = 12.0;
  double estimatedLoss = 3.5;

  String trackerMode = "Auto";
  String cleaningMode = "Idle";
  String systemStatus = "OK";

  final List<double> sparklinePoints = [120, 125, 118, 132, 140, 136, 150, 148];
  final List<double> energyWeekWh = [420, 510, 480, 610, 590, 650, 700];
  final List<double> lossTrend = [1.2, 1.6, 2.0, 2.4, 3.1, 3.7, 4.2, 4.8];

  Timer? _timer;
  final _rng = math.Random();

  void startMockStream() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final delta = (_rng.nextDouble() * 14) - 7;
      powerW = (powerW + delta).clamp(70, 250);

      energyTodayWh = (energyTodayWh + _rng.nextDouble() * 4).clamp(0, 5000);

      soilingIndex = (soilingIndex + 0.25).clamp(0, 100);

      estimatedLoss = (soilingIndex * 0.25).clamp(0, 30);

      systemStatus = estimatedLoss >= 5 ? "Attention" : "OK";
      cleaningMode = estimatedLoss >= 5 ? "Recommended" : "Idle";

      sparklinePoints.add(powerW);
      if (sparklinePoints.length > 26) sparklinePoints.removeAt(0);

      lossTrend.add(estimatedLoss);
      if (lossTrend.length > 20) lossTrend.removeAt(0);

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}