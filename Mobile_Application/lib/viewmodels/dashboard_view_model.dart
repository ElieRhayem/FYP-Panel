import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class CoolingHistoryEntry {
  final DateTime timestamp;
  final String status;
  final double panelTemperature;
  final double temperatureDrop;
  final String pcmState;
  final String action;
  final String source;

  const CoolingHistoryEntry({
    required this.timestamp,
    required this.status,
    required this.panelTemperature,
    required this.temperatureDrop,
    required this.pcmState,
    required this.action,
    required this.source,
  });
}

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({this.systemId = 'system_001'});

  final String systemId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _liveStatusSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sensorsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _trackingHistorySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cleaningHistorySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _coolingHistorySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _energyHistorySub;

  bool _initialized = false;

  DocumentReference<Map<String, dynamic>> get _systemRef =>
      _firestore.collection('system').doc(systemId);

  DocumentReference<Map<String, dynamic>> get _liveStatusRef =>
      _systemRef.collection('live_status').doc('current');

  DocumentReference<Map<String, dynamic>> get _sensorsRef =>
      _systemRef.collection('sensors').doc('current');

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _systemRef.collection('settings').doc('current');

  CollectionReference<Map<String, dynamic>> get _trackingHistoryRef =>
      _systemRef.collection('tracking_history');

  CollectionReference<Map<String, dynamic>> get _cleaningHistoryRef =>
      _systemRef.collection('cleaning_history');

  CollectionReference<Map<String, dynamic>> get _coolingHistoryRef =>
      _systemRef.collection('cooling_history');

  CollectionReference<Map<String, dynamic>> get _energyHistoryRef =>
      _systemRef.collection('energy_history');

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _listenToLiveStatus();
    _listenToSensors();
    _listenToTrackingHistory();
    _listenToCleaningHistory();
    _listenToCoolingHistory();
    _listenToEnergyHistory();
  }

  double powerW = 0.0;
  double estimatedLoss = 0.0;
  double soilingIndex = 0.0;
  double energyTodayWh = 0.0;
  List<double> energyWeekWh = [];

  String trackerMode = "AUTO";
  String cleaningMode = "AUTO";
  double tilt = 0.0;
  double roll = 0.0;
  String weatherStatus = "Unknown";
  double ldrTopLeft = 0.0;
  double ldrTopRight = 0.0;
  double ldrBottomLeft = 0.0;
  double ldrBottomRight = 0.0;

  double cornerTopLeftHeight = 0.0;
  double cornerTopRightHeight = 0.0;
  double cornerBottomLeftHeight = 0.0;
  double cornerBottomRightHeight = 0.0;

  bool windSensorOnline = true;
  bool cleaningInProgress = false;
  bool forceCleaningReady = false;
  bool trackingManualMode = false;
  bool safetyLock = false;
  bool trackingSafetyAlert = false;
  bool panelStowed = false;
  int cleaningCycles = 0;
  double trackerUptime = 0.0;
  double waterUsageLiters = 0.0;
  int manualOverridesCount = 0;
  String lastCleaningLabel = "";

  String coolingMode = "AUTO";
  bool coolingManualMode = false;
  bool coolingInProgress = false;

  double ambientTemperatureC = 0.0;
  double panelTemperatureDropC = 0.0;
  double coolingTargetMinC = 15.0;
  double coolingTargetMaxC = 25.0;
  double coolingMaxSafeC = 30.0;
  double pcmTemperatureC = 0.0;

  bool pcmModuleOnline = true;
  bool pcmTemperatureOnline = true;
  bool thermalControllerOnline = true;

  bool get coolingRecommended => panelTemperatureC > coolingTargetMaxC;

  double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    return fallback;
  }

  String _asString(dynamic value, [String fallback = ""]) {
    if (value is String) return value;
    return fallback;
  }

  List<double> _asDoubleList(dynamic value) {
    if (value is List) {
      return value.map((e) => _asDouble(e)).toList();
    }
    return [];
  }

  Future<void> _updateLiveStatus(Map<String, dynamic> data) async {
    await _liveStatusRef.set({
      ...data,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _listenToLiveStatus() {
    _liveStatusSub = _liveStatusRef.snapshots().listen((snapshot) {
      print("LIVE STATUS PATH: ${_liveStatusRef.path}");
      print("LIVE STATUS EXISTS: ${snapshot.exists}");
      print("LIVE STATUS DATA: ${snapshot.data()}");

      final data = snapshot.data();
      if (data == null) return;

      powerW = _asDouble(data['powerW']);
      estimatedLoss = _asDouble(data['estimatedLoss']);
      soilingIndex = _asDouble(data['soilingIndex']);
      energyTodayWh = _asDouble(data['energyTodayWh']);
      energyWeekWh = _asDoubleList(data['energyWeekWh']);

      trackerMode = _asString(data['trackerMode'], 'AUTO');
      cleaningMode = _asString(data['cleaningMode'], 'AUTO');
      coolingMode = _asString(data['coolingMode'], 'AUTO');

      tilt = _asDouble(data['tilt']);
      roll = _asDouble(data['roll']);
      weatherStatus = _asString(data['weatherStatus'], 'Unknown');

      ldrTopLeft = _asDouble(data['ldrTopLeft']);
      ldrTopRight = _asDouble(data['ldrTopRight']);
      ldrBottomLeft = _asDouble(data['ldrBottomLeft']);
      ldrBottomRight = _asDouble(data['ldrBottomRight']);

      cornerTopLeftHeight = _asDouble(data['cornerTopLeftHeight']);
      cornerTopRightHeight = _asDouble(data['cornerTopRightHeight']);
      cornerBottomLeftHeight = _asDouble(data['cornerBottomLeftHeight']);
      cornerBottomRightHeight = _asDouble(data['cornerBottomRightHeight']);

      panelStowed = _asBool(data['panelStowed']);
      trackingManualMode = _asBool(data['trackingManualMode']);
      coolingManualMode = _asBool(data['coolingManualMode']);
      forceCleaningReady = _asBool(data['forceCleaningReady']);
      safetyLock = _asBool(data['safetyLock']);
      trackingSafetyAlert = _asBool(data['trackingSafetyAlert']);

      cleaningInProgress = _asBool(data['cleaningInProgress']);
      coolingInProgress = _asBool(data['coolingInProgress']);

      cleaningCycles = _asInt(data['cleaningCycles']);
      trackerUptime = _asDouble(data['trackerUptime']);
      waterUsageLiters = _asDouble(data['waterUsageLiters']);
      manualOverridesCount = _asInt(data['manualOverridesCount']);
      lastCleaningLabel = _asString(data['lastCleaningLabel'], '');

      ambientTemperatureC = _asDouble(data['ambientTemperatureC']);
      panelTemperatureC = _asDouble(data['panelTemperatureC']);
      panelTemperatureDropC = _asDouble(data['panelTemperatureDropC']);
      pcmTemperatureC = _asDouble(data['pcmTemperatureC']);

      coolingTargetMinC = _asDouble(data['coolingTargetMinC'], fallback: 15.0);
      coolingTargetMaxC = _asDouble(data['coolingTargetMaxC'], fallback: 25.0);
      coolingMaxSafeC = _asDouble(data['coolingMaxSafeC'], fallback: 30.0);

      notifyListeners();
    });
  }

  void _listenToSensors() {
    _sensorsSub = _sensorsRef.snapshots().listen((snapshot) {
      print("SENSORS PATH: ${_sensorsRef.path}");
      print("SENSORS EXISTS: ${snapshot.exists}");
      print("SENSORS DATA: ${snapshot.data()}");

      final data = snapshot.data();
      if (data == null) return;

      sunSensorOnline = _asBool(data['sunSensorOnline']);
      windSensorOnline = _asBool(data['windSensorOnline']);
      gyroOnline = _asBool(data['gyroOnline']);
      motorDriverOnline = _asBool(data['motorDriverOnline']);
      cameraOnline = _asBool(data['cameraOnline']);
      voltageSensorOnline = _asBool(data['voltageSensorOnline']);
      currentSensorOnline = _asBool(data['currentSensorOnline']);
      temperatureSensorOnline = _asBool(data['temperatureSensorOnline']);
      waterPumpOnline = _asBool(data['waterPumpOnline']);
      waterLevelOnline = _asBool(data['waterLevelOnline']);
      nozzleValveOnline = _asBool(data['nozzleValveOnline']);
      pcmModuleOnline = _asBool(data['pcmModuleOnline']);
      pcmTemperatureOnline = _asBool(data['pcmTemperatureOnline']);
      thermalControllerOnline = _asBool(data['thermalControllerOnline']);

      voltageV = _asDouble(data['voltageV']);
      currentA = _asDouble(data['currentA']);
      panelTemperatureC = _asDouble(data['panelTemperatureC'], fallback: panelTemperatureC);

      notifyListeners();
    });
  }

  void _listenToTrackingHistory() {
    _trackingHistorySub = _trackingHistoryRef
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      print("TRACKING HISTORY COUNT: ${snapshot.docs.length}");

      trackingHistory
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final d = doc.data();
          final ts = d['timestamp'] as Timestamp?;
          return TrackingHistoryEntry(
            timestamp: ts?.toDate() ?? DateTime.now(),
            timeLabel: "",
            mode: _asString(d['mode'], 'AUTO'),
            tilt: _asDouble(d['tilt']),
            roll: _asDouble(d['roll']),
            avgIrradiance: _asDouble(d['avgIrradiance']),
            brightestDirection: _asString(d['brightestDirection'], 'C1'),
            topLeft: _asDouble(d['topLeft']),
            topRight: _asDouble(d['topRight']),
            bottomLeft: _asDouble(d['bottomLeft']),
            bottomRight: _asDouble(d['bottomRight']),
          );
        }));

      notifyListeners();
    });
  }

  void _listenToCleaningHistory() {
    _cleaningHistorySub = _cleaningHistoryRef
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      print("CLEANING HISTORY COUNT: ${snapshot.docs.length}");

      cleaningHistory
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final d = doc.data();
          final ts = d['timestamp'] as Timestamp?;
          return CleaningHistoryEntry(
            timestamp: ts?.toDate() ?? DateTime.now(),
            status: _asString(d['status'], 'Unknown'),
            soilingIndex: _asDouble(d['soilingIndex']),
            estimatedLoss: _asDouble(d['estimatedLoss']),
            action: _asString(d['action'], ''),
            waterUsedLiters: _asDouble(d['waterUsedLiters']),
            source: _asString(d['source'], ''),
          );
        }));

      notifyListeners();
    });
  }

  void _listenToCoolingHistory() {
    _coolingHistorySub = _coolingHistoryRef
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      print("COOLING HISTORY COUNT: ${snapshot.docs.length}");

      coolingHistory
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final d = doc.data();
          final ts = d['timestamp'] as Timestamp?;
          return CoolingHistoryEntry(
            timestamp: ts?.toDate() ?? DateTime.now(),
            status: _asString(d['status'], 'Unknown'),
            panelTemperature: _asDouble(d['panelTemperature']),
            temperatureDrop: _asDouble(d['temperatureDrop']),
            pcmState: _asString(d['pcmState'], ''),
            action: _asString(d['action'], ''),
            source: _asString(d['source'], ''),
          );
        }));

      notifyListeners();
    });
  }

  void _listenToEnergyHistory() {
    _energyHistorySub = _energyHistoryRef
        .orderBy('date', descending: true)
        .limit(7)
        .snapshots()
        .listen((snapshot) {
      print("ENERGY HISTORY COUNT: ${snapshot.docs.length}");

      final docs = snapshot.docs.toList().reversed.toList();
      energyWeekWh = docs
          .map((doc) => _asDouble(doc.data()['energyGeneratedWh']))
          .toList();

      notifyListeners();
    });
  }

  String get pcmStateLabel {
    if (pcmTemperatureC < 24) return "Solid";
    if (pcmTemperatureC < 29) return "Active";
    return "Liquid";
  }

  String get thermalBandLabel {
    if (panelTemperatureC < coolingTargetMinC) return "Too Cold";
    if (panelTemperatureC <= coolingTargetMaxC) return "Optimal";
    if (panelTemperatureC <= coolingMaxSafeC) return "Warm";
    return "Critical";
  }

  final List<CoolingHistoryEntry> coolingHistory = [];

  Future<void> setCoolingManualMode(bool value) async {
    await _updateLiveStatus({
      'coolingManualMode': value,
      'coolingMode': value ? 'MANUAL' : 'AUTO',
      'manualOverridesCount': manualOverridesCount + 1,
    });

    if (!value && coolingInProgress) {
      await _updateLiveStatus({
        'coolingInProgress': false,
      });

      await _coolingHistoryRef.add({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Stopped',
        'panelTemperature': panelTemperatureC,
        'temperatureDrop': panelTemperatureDropC,
        'pcmState': pcmStateLabel,
        'action': 'Cooling cycle stopped because manual cooling was disabled',
        'source': 'Manual',
        'coolingMode': 'AUTO',
      });
    }
  }

  Future<void> startCoolingNow() async {
    if (coolingInProgress) return;

    await _updateLiveStatus({
      'coolingInProgress': true,
      'coolingMode': coolingManualMode ? 'MANUAL' : 'AUTO',
      'manualOverridesCount': manualOverridesCount + 1,
    });

    await _coolingHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Running',
      'panelTemperature': panelTemperatureC,
      'temperatureDrop': panelTemperatureDropC,
      'pcmState': pcmStateLabel,
      'action': 'Cooling cycle started manually',
      'source': 'Manual',
      'coolingMode': coolingManualMode ? 'MANUAL' : 'AUTO',
    });
  }

  Future<void> stopCooling() async {
    if (!coolingInProgress) return;

    await _updateLiveStatus({
      'coolingInProgress': false,
      'coolingMode': coolingManualMode ? 'MANUAL' : 'AUTO',
      'manualOverridesCount': manualOverridesCount + 1,
    });

    await _coolingHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Stopped',
      'panelTemperature': panelTemperatureC,
      'temperatureDrop': panelTemperatureDropC,
      'pcmState': pcmStateLabel,
      'action': 'Cooling cycle stopped by operator',
      'source': 'Manual',
      'coolingMode': coolingManualMode ? 'MANUAL' : 'AUTO',
    });
  }

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

  final List<TrackingHistoryEntry> trackingHistory = [];

  final List<CleaningHistoryEntry> cleaningHistory = [];

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

  double panelTemperatureC = 0.0;
  double voltageV = 0.0;
  double currentA = 0.0;

  bool get canManualCornerControl =>
      trackingManualMode && !safetyLock && !trackingSafetyAlert;

  String get manualCornerHint {
    if (!trackingManualMode) return "Enable manual mode to adjust panel corners";
    if (safetyLock) return "Safety lock enabled: corner movement blocked";
    return "Tap a corner to raise or lower its height";
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

  Future<void> setTrackingManualMode(bool value) async {
    final newTrackingSafetyAlert = !windSensorOnline || safetyLock;
    final newTrackerMode = value
        ? (newTrackingSafetyAlert ? "SAFE" : "MANUAL")
        : (panelStowed ? "STOW" : (newTrackingSafetyAlert ? "SAFE" : "AUTO"));

    await _updateLiveStatus({
      'trackingManualMode': value,
      'panelStowed': value ? false : panelStowed,
      'trackingSafetyAlert': newTrackingSafetyAlert,
      'trackerMode': newTrackerMode,
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> applyManualOrientation({
    required double newTilt,
    required double newRoll,
  }) async {
    await _updateLiveStatus({
      'tilt': newTilt,
      'roll': newRoll,
      'trackingManualMode': false,
      'panelStowed': false,
      'trackerMode': trackingSafetyAlert ? 'SAFE' : 'AUTO',
      'manualOverridesCount': manualOverridesCount + 1,
    });

    await _trackingHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'mode': 'MANUAL',
      'tilt': newTilt,
      'roll': newRoll,
      'avgIrradiance': avgIrradiance,
      'brightestDirection': brightestDirection,
      'topLeft': ldrTopLeft,
      'topRight': ldrTopRight,
      'bottomLeft': ldrBottomLeft,
      'bottomRight': ldrBottomRight,
      'weatherStatus': weatherStatus,
      'trackerMode': 'MANUAL',
    });
  }

  Future<void> setSafetyLock(bool value) async {
    final newTrackingSafetyAlert = !windSensorOnline || value;

    String newTrackerMode;
    if (panelStowed) {
      newTrackerMode = "STOW";
    } else if (newTrackingSafetyAlert) {
      newTrackerMode = "SAFE";
    } else if (trackingManualMode) {
      newTrackerMode = "MANUAL";
    } else {
      newTrackerMode = "AUTO";
    }

    await _updateLiveStatus({
      'safetyLock': value,
      'trackingSafetyAlert': newTrackingSafetyAlert,
      'trackerMode': newTrackerMode,
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> setForceCleaningReady(bool value) async {
    final newCleaningMode = value ? 'MANUAL' : 'AUTO';

    await _updateLiveStatus({
      'forceCleaningReady': value,
      'cleaningMode': newCleaningMode,
      'manualOverridesCount': manualOverridesCount + 1,
    });

    if (!value && cleaningInProgress) {
      await _updateLiveStatus({
        'cleaningInProgress': false,
        'lastCleaningLabel': 'Just now',
      });

      await _cleaningHistoryRef.add({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Stopped',
        'soilingIndex': soilingIndex,
        'estimatedLoss': estimatedLoss,
        'action': 'Cleaning cycle stopped because force cleaning was disabled',
        'waterUsedLiters': 0.0,
        'source': 'Manual',
        'cleaningMode': 'AUTO',
        'manualOverride': true,
      });
    }
  }

  Future<void> startCleaningNow() async {
    if (cleaningInProgress) return;

    await _updateLiveStatus({
      'cleaningInProgress': true,
      'cleaningMode': 'MANUAL',
      'cleaningCycles': cleaningCycles + 1,
      'manualOverridesCount': manualOverridesCount + 1,
      'waterUsageLiters': waterUsageLiters + 0.2,
      'lastCleaningLabel': 'Running now',
    });

    await _cleaningHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Running',
      'soilingIndex': soilingIndex,
      'estimatedLoss': estimatedLoss,
      'action': 'Cleaning cycle started manually',
      'waterUsedLiters': 0.2,
      'source': 'Manual',
      'cleaningMode': 'MANUAL',
      'manualOverride': true,
    });
  }

  Future<void> stopCleaning() async {
    if (!cleaningInProgress) return;

    await _updateLiveStatus({
      'cleaningInProgress': false,
      'cleaningMode': forceCleaningReady ? 'MANUAL' : 'AUTO',
      'manualOverridesCount': manualOverridesCount + 1,
      'lastCleaningLabel': 'Just now',
    });

    await _cleaningHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'Stopped',
      'soilingIndex': soilingIndex,
      'estimatedLoss': estimatedLoss,
      'action': 'Cleaning cycle stopped by operator',
      'waterUsedLiters': 0.0,
      'source': 'Manual',
      'cleaningMode': forceCleaningReady ? 'MANUAL' : 'AUTO',
      'manualOverride': true,
    });
  }

  Future<void> stowPanel() async {
    await _updateLiveStatus({
      'panelStowed': true,
      'trackingManualMode': false,
      'tilt': 34.0,
      'roll': 0.0,
      'trackerMode': 'STOW',
      'manualOverridesCount': manualOverridesCount + 1,
    });

    await _trackingHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'mode': 'STOW',
      'tilt': 34.0,
      'roll': 0.0,
      'avgIrradiance': avgIrradiance,
      'brightestDirection': brightestDirection,
      'topLeft': ldrTopLeft,
      'topRight': ldrTopRight,
      'bottomLeft': ldrBottomLeft,
      'bottomRight': ldrBottomRight,
      'weatherStatus': weatherStatus,
      'trackerMode': 'STOW',
    });
  }

  Future<void> returnToAutoTracking() async {
    final newTrackingSafetyAlert = !windSensorOnline || safetyLock;
    final newMode = newTrackingSafetyAlert ? 'SAFE' : 'AUTO';

    await _updateLiveStatus({
      'trackingManualMode': false,
      'panelStowed': false,
      'trackingSafetyAlert': newTrackingSafetyAlert,
      'trackerMode': newMode,
      'manualOverridesCount': manualOverridesCount + 1,
    });

    await _trackingHistoryRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'mode': newMode,
      'tilt': tilt,
      'roll': roll,
      'avgIrradiance': avgIrradiance,
      'brightestDirection': brightestDirection,
      'topLeft': ldrTopLeft,
      'topRight': ldrTopRight,
      'bottomLeft': ldrBottomLeft,
      'bottomRight': ldrBottomRight,
      'weatherStatus': weatherStatus,
      'trackerMode': newMode,
    });
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

  Future<void> raiseTopLeft() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerTopLeftHeight': (cornerTopLeftHeight + 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> lowerTopLeft() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerTopLeftHeight': (cornerTopLeftHeight - 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> raiseTopRight() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerTopRightHeight': (cornerTopRightHeight + 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> lowerTopRight() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerTopRightHeight': (cornerTopRightHeight - 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> raiseBottomLeft() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerBottomLeftHeight': (cornerBottomLeftHeight + 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> lowerBottomLeft() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerBottomLeftHeight': (cornerBottomLeftHeight - 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> raiseBottomRight() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerBottomRightHeight': (cornerBottomRightHeight + 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
  }

  Future<void> lowerBottomRight() async {
    if (!canManualCornerControl) return;
    await _updateLiveStatus({
      'cornerBottomRightHeight': (cornerBottomRightHeight - 5).clamp(0, 100).toDouble(),
      'panelStowed': false,
      'trackerMode': 'MANUAL',
      'manualOverridesCount': manualOverridesCount + 1,
    });
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
      DashboardSensorItem(
        name: "PCM Module",
        category: "Cooling",
        icon: Icons.ac_unit_rounded,
        state: pcmModuleOnline ? SensorHealthState.working : SensorHealthState.issue,
        value: pcmStateLabel,
        hint: pcmModuleOnline
            ? "Phase-change medium available"
            : "PCM module not responding",
      ),
      DashboardSensorItem(
        name: "PCM Temperature",
        category: "Cooling",
        icon: Icons.device_thermostat_rounded,
        state: !pcmTemperatureOnline
            ? SensorHealthState.issue
            : pcmTemperatureC >= 32
            ? SensorHealthState.warning
            : SensorHealthState.working,
        value: "${pcmTemperatureC.toStringAsFixed(1)} °C",
        hint: pcmTemperatureOnline
            ? "PCM thermal reading available"
            : "PCM temperature unavailable",
      ),
      DashboardSensorItem(
        name: "Thermal Controller",
        category: "Cooling",
        icon: Icons.memory_rounded,
        state: thermalControllerOnline
            ? SensorHealthState.working
            : SensorHealthState.issue,
        value: thermalControllerOnline ? "ONLINE" : "OFFLINE",
        hint: thermalControllerOnline
            ? "Cooling decision logic responsive"
            : "Thermal control feedback lost",
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

  double get trackingEfficiencyGain {
    final irradianceGain = ((avgIrradiance - 45).clamp(0, 35)) * 0.45;

    final modeBonus = trackerMode == "AUTO"
        ? 4.0
        : trackerMode == "MANUAL"
        ? 2.5
        : trackerMode == "SAFE"
        ? 1.0
        : trackerMode == "STOW"
        ? 0.5
        : 0.0;

    return (irradianceGain + modeBonus).clamp(0, 22).toDouble();
  }

  double get cleaningEfficiencyRecovery {
    final lossRecovery = estimatedLoss.clamp(0, 10) * 0.90;
    final cleanlinessBonus = ((20 - soilingIndex).clamp(0, 20)) * 0.25;
    final cycleBonus = math.min(cleaningCycles.toDouble(), 6) * 0.60;
    final runningBonus = cleaningInProgress ? 1.5 : 0.0;

    return (lossRecovery + cleanlinessBonus + cycleBonus + runningBonus)
        .clamp(0, 18)
        .toDouble();
  }

  double get coolingEfficiencyRecovery {
    final thermalDropGain = panelTemperatureDropC.clamp(0, 15) * 0.90;

    final thermalBonus = panelTemperatureC <= coolingTargetMaxC
        ? 3.0
        : panelTemperatureC <= coolingMaxSafeC
        ? 1.5
        : 0.5;

    final activeBonus = coolingInProgress ? 1.5 : 0.0;

    return (thermalDropGain + thermalBonus + activeBonus)
        .clamp(0, 17)
        .toDouble();
  }

  double get estimatedTotalImprovement =>
      (trackingEfficiencyGain +
          cleaningEfficiencyRecovery +
          coolingEfficiencyRecovery)
          .clamp(0, 45)
          .toDouble();

  double get operationalConsumptionEstimate {
    final trackingCost = trackingManualMode ? 0.35 : 0.15;
    final cleaningCost = (cleaningCycles * 0.15).clamp(0, 1.2);
    final coolingCost = coolingInProgress ? 0.80 : 0.35;

    return (trackingCost + cleaningCost + coolingCost).clamp(0, 4.0).toDouble();
  }

  double get overallPerformanceGain {
    final rawGain = estimatedTotalImprovement * ((100 - estimatedLoss) / 100);
    return rawGain.clamp(0, 35).toDouble();
  }

  double get netEnergyGainEstimate =>
      (overallPerformanceGain - operationalConsumptionEstimate)
          .clamp(0, 30)
          .toDouble();

  double get lossReductionEstimate =>
      ((trackingEfficiencyGain * 0.22) +
          (cleaningEfficiencyRecovery * 0.34) +
          (coolingEfficiencyRecovery * 0.28))
          .clamp(0, 20)
          .toDouble();

  double get systemEfficiencyScore {
    final score = 100 -
        estimatedLoss +
        (trackingEfficiencyGain * 0.45) +
        (cleaningEfficiencyRecovery * 0.40) +
        (coolingEfficiencyRecovery * 0.38) -
        (issueSensors * 0.8) -
        (warningSensors * 0.3);

    return score.clamp(0, 100).toDouble();
  }

  double get _totalContributionBase {
    final total =
        trackingEfficiencyGain + cleaningEfficiencyRecovery + coolingEfficiencyRecovery;
    return total <= 0 ? 1 : total;
  }

  double get trackingContributionPercent =>
      ((trackingEfficiencyGain / _totalContributionBase) * 100)
          .clamp(0, 100)
          .toDouble();

  double get cleaningContributionPercent =>
      ((cleaningEfficiencyRecovery / _totalContributionBase) * 100)
          .clamp(0, 100)
          .toDouble();

  double get coolingContributionPercent =>
      ((coolingEfficiencyRecovery / _totalContributionBase) * 100)
          .clamp(0, 100)
          .toDouble();

  String get dominantSubsystem {
    final values = {
      "Tracking": trackingEfficiencyGain,
      "Cleaning": cleaningEfficiencyRecovery,
      "Cooling": coolingEfficiencyRecovery,
    };

    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String get performanceHeadline {
    switch (dominantSubsystem) {
      case "Tracking":
        return "Tracking leads current gains.";
      case "Cleaning":
        return "Cleaning leads current recovery.";
      case "Cooling":
        return "Cooling leads current protection.";
      default:
        return "System performance is improving.";
    }
  }

  String get performanceDescription {
    switch (dominantSubsystem) {
      case "Tracking":
        return "Best gain comes from panel alignment.";
      case "Cleaning":
        return "Best gain comes from loss recovery.";
      case "Cooling":
        return "Best gain comes from thermal control.";
      default:
        return "Tracking, cleaning and cooling are all contributing.";
    }
  }

  List<double> get energyTrendValues => List<double>.from(energyWeekWh);

  List<String> get energyTrendLabels {
    const labels = ["D1", "D2", "D3", "D4", "D5", "D6", "D7"];
    if (energyWeekWh.length <= labels.length) {
      return labels.sublist(0, energyWeekWh.length);
    }
    return List.generate(energyWeekWh.length, (index) => "D${index + 1}");
  }

  List<double> get lossTrendValues {
    if (cleaningHistory.isEmpty) return [estimatedLoss];
    return cleaningHistory.reversed
        .map((entry) => entry.estimatedLoss)
        .toList();
  }

  List<String> get lossTrendLabels {
    if (cleaningHistory.isEmpty) return const ["Now"];
    return List.generate(cleaningHistory.length, (index) => "L${index + 1}");
  }

  List<double> get temperatureTrendValues {
    if (coolingHistory.isEmpty) return [panelTemperatureC];
    return coolingHistory.reversed
        .map((entry) => entry.panelTemperature)
        .toList();
  }

  List<String> get temperatureTrendLabels {
    if (coolingHistory.isEmpty) return const ["Now"];
    return List.generate(coolingHistory.length, (index) => "T${index + 1}");
  }

  List<double> get trackingTrendValues {
    if (trackingHistory.isEmpty) return [avgIrradiance];
    return trackingHistory.reversed
        .map((entry) => entry.avgIrradiance)
        .toList();
  }

  List<String> get trackingTrendLabels {
    if (trackingHistory.isEmpty) return const ["Now"];
    return List.generate(trackingHistory.length, (index) => "Q${index + 1}");
  }

  @override
  void dispose() {
    _liveStatusSub?.cancel();
    _sensorsSub?.cancel();
    _trackingHistorySub?.cancel();
    _cleaningHistorySub?.cancel();
    _coolingHistorySub?.cancel();
    _energyHistorySub?.cancel();
    super.dispose();
  }
}