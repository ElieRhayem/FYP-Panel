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

class TrackingHistoryEntry {
  final DateTime timestamp;
  final String timeLabel;
  final String mode;
  final double tilt;
  final double roll;
  final double avgIrradiance;
  final String brightestDirection;
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  TrackingHistoryEntry({
    required this.timestamp,
    required this.timeLabel,
    required this.mode,
    required this.tilt,
    required this.roll,
    required this.avgIrradiance,
    required this.brightestDirection,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });
}

class CleaningHistoryEntry {
  final DateTime timestamp;
  final String status;
  final double soilingIndex;
  final double estimatedLoss;
  final String action;
  final double waterUsedLiters;
  final String source;

  const CleaningHistoryEntry({
    required this.timestamp,
    required this.status,
    required this.soilingIndex,
    required this.estimatedLoss,
    required this.action,
    required this.waterUsedLiters,
    required this.source,
  });
}

class DashboardViewModel extends ChangeNotifier {
  double powerW = 842.0;
  double estimatedLoss = 4.8;
  double soilingIndex = 12.5;
  double energyTodayWh = 5230.0;
  List<double> energyWeekWh = [4200, 5100, 4800, 5600, 5900, 6100, 5230];

  String trackerMode = "AUTO";
  String cleaningMode = "AUTO";
  double tilt = 32.0;
  double roll = 0.0;
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
  bool trackingSafetyAlert = false;
  bool panelStowed = false;
  int cleaningCycles = 3;
  double trackerUptime = 96.0;
  double waterUsageLiters = 1.2;
  int manualOverridesCount = 2;
  String lastCleaningLabel = "Yesterday";

  String _formatLastCleaningDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(target).inDays;

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final time = "$hour:$minute";

    if (difference == 0) {
      return "Today • $time";
    }

    if (difference == 1) {
      return "Yesterday • $time";
    }

    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return "${weekdays[dateTime.weekday - 1]} • $time";
  }

  String get lastCleaningDisplayLabel {
    final latestCleaningEntry = cleaningHistory.firstWhere(
          (entry) => entry.status == "Completed" || entry.status == "Running",
      orElse: () => CleaningHistoryEntry(
        timestamp: DateTime.now(),
        status: "Completed",
        soilingIndex: soilingIndex,
        estimatedLoss: estimatedLoss,
        action: "",
        waterUsedLiters: 0.0,
        source: "",
      ),
    );

    return _formatLastCleaningDate(latestCleaningEntry.timestamp);
  }

  void _addCleaningHistoryEntry({
    required String status,
    required String action,
    required double waterUsedLiters,
    required String source,
  }) {
    cleaningHistory.insert(
      0,
      CleaningHistoryEntry(
        timestamp: DateTime.now(),
        status: status,
        soilingIndex: soilingIndex,
        estimatedLoss: estimatedLoss,
        action: action,
        waterUsedLiters: waterUsedLiters,
        source: source,
      ),
    );

    if (cleaningHistory.length > 20) {
      cleaningHistory.removeLast();
    }
  }

  final List<TrackingHistoryEntry> trackingHistory = [
    TrackingHistoryEntry(
      timestamp: DateTime.now(),
      timeLabel: "Now",
      mode: "AUTO",
      tilt: 32,
      roll: 0,
      avgIrradiance: 71.5,
      brightestDirection: "C2",
      topLeft: 72,
      topRight: 81,
      bottomLeft: 64,
      bottomRight: 69,
    ),
    TrackingHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      timeLabel: "10 sec ago",
      mode: "AUTO",
      tilt: 31,
      roll: 0,
      avgIrradiance: 68.5,
      brightestDirection: "C2",
      topLeft: 70,
      topRight: 75,
      bottomLeft: 61,
      bottomRight: 68,
    ),
    TrackingHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
      timeLabel: "20 sec ago",
      mode: "SAFE",
      tilt: 30,
      roll: 0,
      avgIrradiance: 63.0,
      brightestDirection: "C2",
      topLeft: 60,
      topRight: 71,
      bottomLeft: 58,
      bottomRight: 63,
    ),
    TrackingHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      timeLabel: "30 sec ago",
      mode: "AUTO",
      tilt: 29,
      roll: 0,
      avgIrradiance: 61.8,
      brightestDirection: "C2",
      topLeft: 64,
      topRight: 66,
      bottomLeft: 57,
      bottomRight: 60,
    ),
    TrackingHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(seconds: 40)),
      timeLabel: "40 sec ago",
      mode: "MANUAL",
      tilt: 34,
      roll: 0,
      avgIrradiance: 73.2,
      brightestDirection: "C1",
      topLeft: 78,
      topRight: 71,
      bottomLeft: 74,
      bottomRight: 70,
    ),
  ];

  final List<CleaningHistoryEntry> cleaningHistory = [
    CleaningHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      status: "Completed",
      soilingIndex: 18.4,
      estimatedLoss: 6.1,
      action: "Manual cleaning cycle completed",
      waterUsedLiters: 0.2,
      source: "Manual",
    ),
    CleaningHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
      status: "Recommended",
      soilingIndex: 16.8,
      estimatedLoss: 5.3,
      action: "Cleaning recommended but not started",
      waterUsedLiters: 0.0,
      source: "System",
    ),
    CleaningHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: "Completed",
      soilingIndex: 21.2,
      estimatedLoss: 7.4,
      action: "Automatic cleaning cycle completed",
      waterUsedLiters: 0.3,
      source: "Automatic",
    ),
    CleaningHistoryEntry(
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      status: "Stopped",
      soilingIndex: 14.6,
      estimatedLoss: 4.9,
      action: "Cleaning cycle stopped by operator",
      waterUsedLiters: 0.1,
      source: "Manual",
    ),
  ];

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

  bool get canManualCornerControl =>
      trackingManualMode && !safetyLock && !trackingSafetyAlert;

  String get manualCornerHint {
    if (!trackingManualMode) return "Enable manual mode to adjust panel corners";
    if (safetyLock) return "Safety lock enabled: corner movement blocked";
    return "Tap a corner to raise or lower its height";
  }

  void _pushTrackingHistoryEntry() {
    trackingHistory.insert(
      0,
      TrackingHistoryEntry(
        timestamp: DateTime.now(),
        timeLabel: "Now",
        mode: trackerMode,
        tilt: tilt,
        roll: roll,
        avgIrradiance: avgIrradiance,
        brightestDirection: brightestDirection,
        topLeft: ldrTopLeft,
        topRight: ldrTopRight,
        bottomLeft: ldrBottomLeft,
        bottomRight: ldrBottomRight,
      ),
    );

    if (trackingHistory.length > 12) {
      trackingHistory.removeLast();
    }

    for (int i = 0; i < trackingHistory.length; i++) {
      if (i == 0) continue;
      final secondsAgo = i * 10;
      final old = trackingHistory[i];
      trackingHistory[i] = TrackingHistoryEntry(
        timestamp: old.timestamp,
        timeLabel: "$secondsAgo sec ago",
        mode: old.mode,
        tilt: old.tilt,
        roll: old.roll,
        avgIrradiance: old.avgIrradiance,
        brightestDirection: old.brightestDirection,
        topLeft: old.topLeft,
        topRight: old.topRight,
        bottomLeft: old.bottomLeft,
        bottomRight: old.bottomRight,
      );
    }
  }

  void _tickMockData() {
    final now = DateTime.now().second;

    powerW = 820 + (now % 9) * 12.0;
    estimatedLoss = 3.5 + (now % 6) * 0.6;
    soilingIndex = 10 + (now % 8) * 0.9;
    energyTodayWh += 4.0;

    if (panelStowed) {
      tilt = 34.0;
      roll = 0.0;
    } else {
      tilt = 30 + (now % 5).toDouble();
    }

    weatherStatus = (now % 2 == 0) ? "Clear" : "Partly Cloudy";
    windSensorOnline = now % 4 != 0;

    ldrTopLeft = 52 + ((now + 3) % 24).toDouble();
    ldrTopRight = 52 + ((now + 9) % 24).toDouble();
    ldrBottomLeft = 52 + ((now + 15) % 24).toDouble();
    ldrBottomRight = 52 + ((now + 21) % 24).toDouble();

    trackingSafetyAlert = !windSensorOnline || safetyLock;

    if (panelStowed) {
      trackerMode = "STOW";
    } else if (trackingSafetyAlert) {
      trackerMode = "SAFE";
    } else if (trackingManualMode) {
      trackerMode = "MANUAL";
    } else {
      trackerMode = "AUTO";
    }

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

    _pushTrackingHistoryEntry();
    notifyListeners();
  }

  double get overallHealth {
    if (totalSensors == 0) return 0;
    return ((workingSensors / totalSensors) * 100).toDouble();
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
    trackingSafetyAlert = !windSensorOnline || safetyLock;

    if (trackingManualMode) {
      panelStowed = false;
      trackerMode = trackingSafetyAlert ? "SAFE" : "MANUAL";
      manualOverridesCount++;
    } else {
      trackerMode = panelStowed
          ? "STOW"
          : (trackingSafetyAlert ? "SAFE" : "AUTO");
    }

    notifyListeners();
  }

  void setSafetyLock(bool value) {
    safetyLock = value;
    trackingSafetyAlert = !windSensorOnline || safetyLock;

    if (panelStowed) {
      trackerMode = "STOW";
    } else if (trackingSafetyAlert) {
      trackerMode = "SAFE";
    } else if (trackingManualMode) {
      trackerMode = "MANUAL";
    } else {
      trackerMode = "AUTO";
    }

    manualOverridesCount++;
    notifyListeners();
  }

  void setForceCleaningReady(bool value) {
    forceCleaningReady = value;

    if (!forceCleaningReady && cleaningInProgress) {
      cleaningInProgress = false;
      cleaningMode = "AUTO";
      lastCleaningLabel = "Just now";

      _addCleaningHistoryEntry(
        status: "Stopped",
        action: "Cleaning cycle stopped because force cleaning was disabled",
        waterUsedLiters: 0.0,
        source: "Manual",
      );
    } else {
      cleaningMode = forceCleaningReady ? "MANUAL" : "AUTO";
    }

    manualOverridesCount++;
    notifyListeners();
  }

  void startCleaningNow() {
    if (cleaningInProgress) return;
    cleaningInProgress = true;
    cleaningMode = "MANUAL";
    cleaningCycles++;
    manualOverridesCount++;
    waterUsageLiters += 0.2;
    lastCleaningLabel = "Running now";

    _addCleaningHistoryEntry(
      status: "Running",
      action: "Cleaning cycle started manually",
      waterUsedLiters: 0.2,
      source: "Manual",
    );

    notifyListeners();
  }

  void stopCleaning() {
    if (!cleaningInProgress) return;
    cleaningInProgress = false;
    cleaningMode = forceCleaningReady ? "MANUAL" : "AUTO";
    manualOverridesCount++;
    lastCleaningLabel = "Just now";

    _addCleaningHistoryEntry(
      status: "Stopped",
      action: "Cleaning cycle stopped by operator",
      waterUsedLiters: 0.0,
      source: "Manual",
    );

    notifyListeners();
  }

  void stowPanel() {
    panelStowed = true;
    trackingManualMode = false;
    tilt = 34.0;
    roll = 0.0;
    trackerMode = "STOW";
    manualOverridesCount++;
    notifyListeners();
  }

  void returnToAutoTracking() {
    trackingManualMode = false;
    panelStowed = false;
    trackingSafetyAlert = !windSensorOnline || safetyLock;

    trackerMode = trackingSafetyAlert ? "SAFE" : "AUTO";

    manualOverridesCount++;
    notifyListeners();
  }

  double get avgIrradiance =>
      (ldrTopLeft + ldrTopRight + ldrBottomLeft + ldrBottomRight) / 4.0;

  String get brightestDirection {
    final values = {
      "C1": ldrTopLeft,
      "C2": ldrTopRight,
      "C3": ldrBottomLeft,
      "C4": ldrBottomRight,
    };

    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void raiseTopLeft() {
    if (!canManualCornerControl) return;
    cornerTopLeftHeight = (cornerTopLeftHeight + 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerTopLeft() {
    if (!canManualCornerControl) return;
    cornerTopLeftHeight = (cornerTopLeftHeight - 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseTopRight() {
    if (!canManualCornerControl) return;
    cornerTopRightHeight = (cornerTopRightHeight + 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerTopRight() {
    if (!canManualCornerControl) return;
    cornerTopRightHeight = (cornerTopRightHeight - 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseBottomLeft() {
    if (!canManualCornerControl) return;
    cornerBottomLeftHeight = (cornerBottomLeftHeight + 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerBottomLeft() {
    if (!canManualCornerControl) return;
    cornerBottomLeftHeight = (cornerBottomLeftHeight - 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void raiseBottomRight() {
    if (!canManualCornerControl) return;
    cornerBottomRightHeight = (cornerBottomRightHeight + 5).clamp(0, 100).toDouble();
    panelStowed = false;
    trackerMode = "MANUAL";
    manualOverridesCount++;
    notifyListeners();
  }

  void lowerBottomRight() {
    if (!canManualCornerControl) return;
    cornerBottomRightHeight = (cornerBottomRightHeight - 5).clamp(0, 100).toDouble();
    panelStowed = false;
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