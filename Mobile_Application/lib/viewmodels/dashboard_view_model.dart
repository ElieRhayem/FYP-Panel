import 'dart:async';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  double powerW = 842.0;
  double estimatedLoss = 4.8;
  double soilingIndex = 12.5;
  double energyTodayWh = 5230.0;
  List<double> energyWeekWh = [4200, 5100, 4800, 5600, 5900, 6100, 5230];

  String trackerMode = "AUTO";
  double azimuth = 148.0;
  double tilt = 32.0;
  String weatherStatus = "Clear";

  bool windSensorOnline = false;
  bool cleaningInProgress = false;
  bool forceCleaningReady = false;
  bool trackingManualMode = false;
  bool safetyLock = false;

  int cleaningCycles = 3;
  double trackerUptime = 96.0;
  double waterUsageLiters = 1.2;
  int manualOverridesCount = 2;
  String lastCleaningLabel = "Yesterday";

  Timer? _timer;

  void startMockStream() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _tickMockData();
    });
  }

  void _tickMockData() {
    final now = DateTime.now().second;

    powerW = 820 + (now % 9) * 12.0;
    estimatedLoss = 3.5 + (now % 6) * 0.6;
    soilingIndex = 10 + (now % 8) * 0.9;
    energyTodayWh += 4.0;

    azimuth = 145 + (now % 8).toDouble();
    tilt = 30 + (now % 5).toDouble();

    if (trackingManualMode) {
      trackerMode = "MANUAL";
    } else if (!windSensorOnline) {
      trackerMode = "SAFE";
    } else {
      trackerMode = "AUTO";
    }

    weatherStatus = (now % 2 == 0) ? "Clear" : "Partly Cloudy";
    windSensorOnline = now % 4 != 0;

    notifyListeners();
  }

  double get overallHealth {
    double score = 100 - estimatedLoss * 4;

    if (estimatedLoss >= 5) score -= 8;
    if (!windSensorOnline) score -= 10;
    if (cleaningInProgress) score -= 4;

    return score.clamp(0, 100).toDouble();
  }

  double get trackerHealth {
    double score = 100 - estimatedLoss * 3;
    if (!windSensorOnline) score -= 15;
    if (safetyLock) score -= 5;
    return score.clamp(0, 100).toDouble();
  }

  double get cleaningHealth {
    double score = estimatedLoss >= 5 ? 78 : 92;
    if (forceCleaningReady) score -= 4;
    if (cleaningInProgress) score -= 6;
    return score.clamp(0, 100).toDouble();
  }

  bool get cleaningRecommended => estimatedLoss >= 5;

  String get cleaningAction =>
      cleaningRecommended ? "Start cleaning cycle" : "Do nothing";

  void setTrackingManualMode(bool value) {
    trackingManualMode = value;
    if (trackingManualMode) {
      trackerMode = "MANUAL";
      manualOverridesCount++;
    } else {
      trackerMode = windSensorOnline ? "AUTO" : "SAFE";
    }
    notifyListeners();
  }

  void setSafetyLock(bool value) {
    safetyLock = value;
    manualOverridesCount++;
    notifyListeners();
  }

  void setForceCleaningReady(bool value) {
    forceCleaningReady = value;
    manualOverridesCount++;
    notifyListeners();
  }

  void startCleaningNow() {
    cleaningInProgress = true;
    cleaningCycles++;
    manualOverridesCount++;
    notifyListeners();
  }

  void stopCleaning() {
    cleaningInProgress = false;
    manualOverridesCount++;
    notifyListeners();
  }

  void stowPanel() {
    trackerMode = "STOW";
    manualOverridesCount++;
    notifyListeners();
  }

  void returnToAutoTracking() {
    trackingManualMode = false;
    trackerMode = windSensorOnline ? "AUTO" : "SAFE";
    manualOverridesCount++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}