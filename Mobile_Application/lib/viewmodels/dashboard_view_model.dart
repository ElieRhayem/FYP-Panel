import 'dart:async';
import 'package:flutter/material.dart';

enum SensorHealthState { working, warning, issue }

class DashboardSensorItem {
  final String name;
  final String category;
  final IconData icon;
  final SensorHealthState state;
  final String value;
  final String hint;

  const DashboardSensorItem({
    required this.name,
    required this.category,
    required this.icon,
    required this.state,
    required this.value,
    required this.hint,
  });
}

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
  double ldrTopLeft = 72.0;
  double ldrTopRight = 81.0;
  double ldrBottomLeft = 64.0;
  double ldrBottomRight = 69.0;

  double cornerTopLeftHeight = 50.0;
  double cornerTopRightHeight = 50.0;
  double cornerBottomLeftHeight = 50.0;
  double cornerBottomRightHeight = 50.0;

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

  // Added only for the Sensors Status tab mock UI
  bool sunSensorOnline = true;
  bool gyroOnline = true;
  bool motorDriverOnline = true;
  bool cameraOnline = true;
  bool voltageSensorOnline = true;
  bool currentSensorOnline = true;
  bool temperatureSensorOnline = true;
  bool waterPumpOnline = true;
  bool waterLevelOnline = true;
  bool nozzleValveOnline = true;

  double panelTemperatureC = 34.5;
  double voltageV = 18.7;
  double currentA = 4.6;

  Timer? _timer;

  void startMockStream() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _tickMockData();
    });
  }

  bool get canManualCornerControl => trackingManualMode && !safetyLock;

  String get manualCornerHint {
    if (!trackingManualMode) return "Enable manual mode to adjust panel corners";
    if (safetyLock) return "Safety lock enabled: corner movement blocked";
    return "Tap a corner to raise or lower its height";
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

    ldrTopLeft = 55 + (now % 25).toDouble();
    ldrTopRight = 60 + ((now + 4) % 25).toDouble();
    ldrBottomLeft = 50 + ((now + 8) % 25).toDouble();
    ldrBottomRight = 58 + ((now + 2) % 25).toDouble();

    // Mock sensor values/statuses for Sensors Status tab
    sunSensorOnline = now % 11 != 0;
    gyroOnline = now % 13 != 0;
    motorDriverOnline = now % 10 != 0;
    cameraOnline = now % 9 != 0;
    voltageSensorOnline = now % 12 != 0;
    currentSensorOnline = now % 14 != 0;
    temperatureSensorOnline = true;
    waterPumpOnline = !cleaningInProgress || now % 15 != 0;
    waterLevelOnline = now % 16 != 0;
    nozzleValveOnline = !safetyLock;
    panelTemperatureC = 33 + (now % 9).toDouble();
    voltageV = 18.2 + ((now % 6) * 0.25);
    currentA = 4.2 + ((now % 5) * 0.18);

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
    if (cleaningInProgress) return;
    cleaningInProgress = true;
    cleaningCycles++;
    manualOverridesCount++;
    waterUsageLiters += 0.2;
    lastCleaningLabel = "Running now";
    notifyListeners();
  }

  void stopCleaning() {
    if (!cleaningInProgress) return;
    cleaningInProgress = false;
    manualOverridesCount++;
    lastCleaningLabel = "Just now";
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

  double get avgIrradiance =>
      (ldrTopLeft + ldrTopRight + ldrBottomLeft + ldrBottomRight) / 4.0;

  String get brightestDirection {
    final top = (ldrTopLeft + ldrTopRight) / 2.0;
    final bottom = (ldrBottomLeft + ldrBottomRight) / 2.0;
    final left = (ldrTopLeft + ldrBottomLeft) / 2.0;
    final right = (ldrTopRight + ldrBottomRight) / 2.0;

    final values = {
      "TOP": top,
      "BOTTOM": bottom,
      "LEFT": left,
      "RIGHT": right,
    };

    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void raiseTopLeft() {
    if (!canManualCornerControl) return;
    cornerTopLeftHeight = (cornerTopLeftHeight + 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerTopLeft() {
    if (!canManualCornerControl) return;
    cornerTopLeftHeight = (cornerTopLeftHeight - 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseTopRight() {
    if (!canManualCornerControl) return;
    cornerTopRightHeight = (cornerTopRightHeight + 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerTopRight() {
    if (!canManualCornerControl) return;
    cornerTopRightHeight = (cornerTopRightHeight - 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseBottomLeft() {
    if (!canManualCornerControl) return;
    cornerBottomLeftHeight = (cornerBottomLeftHeight + 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerBottomLeft() {
    if (!canManualCornerControl) return;
    cornerBottomLeftHeight = (cornerBottomLeftHeight - 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseBottomRight() {
    if (!canManualCornerControl) return;
    cornerBottomRightHeight = (cornerBottomRightHeight + 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerBottomRight() {
    if (!canManualCornerControl) return;
    cornerBottomRightHeight = (cornerBottomRightHeight - 5).clamp(0, 100).toDouble();
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  List<DashboardSensorItem> get sensorsStatus {
    SensorHealthState fromOnline(bool online) {
      return online ? SensorHealthState.working : SensorHealthState.issue;
    }

    SensorHealthState tempState;
    if (!temperatureSensorOnline) {
      tempState = SensorHealthState.issue;
    } else if (panelTemperatureC >= 38) {
      tempState = SensorHealthState.warning;
    } else {
      tempState = SensorHealthState.working;
    }

    SensorHealthState ldrState;
    if (!sunSensorOnline) {
      ldrState = SensorHealthState.issue;
    } else if (avgIrradiance < 58) {
      ldrState = SensorHealthState.warning;
    } else {
      ldrState = SensorHealthState.working;
    }

    return [
      DashboardSensorItem(
        name: "Sun Sensor",
        category: "Tracking",
        icon: Icons.wb_sunny_outlined,
        state: ldrState,
        value: "${avgIrradiance.toStringAsFixed(0)}%",
        hint: sunSensorOnline ? "Irradiance reference OK" : "No response detected",
      ),
      DashboardSensorItem(
        name: "Wind Sensor",
        category: "Safety",
        icon: Icons.air_rounded,
        state: fromOnline(windSensorOnline),
        value: windSensorOnline ? "ONLINE" : "OFFLINE",
        hint: windSensorOnline ? "Safety constraint available" : "Fallback safe mode",
      ),
      DashboardSensorItem(
        name: "Gyro / IMU",
        category: "Tracking",
        icon: Icons.screen_rotation_alt_rounded,
        state: fromOnline(gyroOnline),
        value: gyroOnline ? "ONLINE" : "OFFLINE",
        hint: gyroOnline ? "Tilt stabilization OK" : "Orientation feedback lost",
      ),
      DashboardSensorItem(
        name: "Motor Driver Feedback",
        category: "Tracking",
        icon: Icons.settings_input_component_rounded,
        state: fromOnline(motorDriverOnline),
        value: motorDriverOnline ? "READY" : "FAULT",
        hint: motorDriverOnline ? "Actuator response stable" : "Driver issue detected",
      ),
      DashboardSensorItem(
        name: "Camera Module",
        category: "Cleaning",
        icon: Icons.videocam_outlined,
        state: fromOnline(cameraOnline),
        value: cameraOnline ? "ONLINE" : "OFFLINE",
        hint: cameraOnline ? "Soiling scan available" : "Image capture unavailable",
      ),
      DashboardSensorItem(
        name: "Voltage Sensor",
        category: "Electrical",
        icon: Icons.bolt_outlined,
        state: fromOnline(voltageSensorOnline),
        value: "${voltageV.toStringAsFixed(1)} V",
        hint: voltageSensorOnline ? "Voltage measurement stable" : "Signal unavailable",
      ),
      DashboardSensorItem(
        name: "Current Sensor",
        category: "Electrical",
        icon: Icons.electrical_services_outlined,
        state: fromOnline(currentSensorOnline),
        value: "${currentA.toStringAsFixed(1)} A",
        hint: currentSensorOnline ? "Current measurement stable" : "Signal unavailable",
      ),
      DashboardSensorItem(
        name: "Temperature Sensor",
        category: "Safety",
        icon: Icons.thermostat_rounded,
        state: tempState,
        value: "${panelTemperatureC.toStringAsFixed(1)} °C",
        hint: !temperatureSensorOnline
            ? "No reading available"
            : panelTemperatureC >= 38
            ? "Temperature elevated"
            : "Within safe operating range",
      ),
      DashboardSensorItem(
        name: "Water Pump",
        category: "Cleaning",
        icon: Icons.water_drop_outlined,
        state: fromOnline(waterPumpOnline),
        value: waterPumpOnline ? "READY" : "FAULT",
        hint: waterPumpOnline ? "Pump pressure stable" : "Pump not responding",
      ),
      DashboardSensorItem(
        name: "Water Level",
        category: "Cleaning",
        icon: Icons.opacity_rounded,
        state: fromOnline(waterLevelOnline),
        value: waterLevelOnline ? "NORMAL" : "UNKNOWN",
        hint: waterLevelOnline ? "Reservoir level readable" : "Level feedback unavailable",
      ),
      DashboardSensorItem(
        name: "Nozzle Valve",
        category: "Cleaning",
        icon: Icons.tune_rounded,
        state: nozzleValveOnline ? SensorHealthState.working : SensorHealthState.warning,
        value: nozzleValveOnline ? "READY" : "LOCKED",
        hint: nozzleValveOnline ? "Spray path available" : "Blocked by safety lock",
      ),
    ];
  }

  int get totalSensors => sensorsStatus.length;

  int get workingSensors =>
      sensorsStatus.where((s) => s.state == SensorHealthState.working).length;

  int get warningSensors =>
      sensorsStatus.where((s) => s.state == SensorHealthState.warning).length;

  int get issueSensors =>
      sensorsStatus.where((s) => s.state == SensorHealthState.issue).length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}