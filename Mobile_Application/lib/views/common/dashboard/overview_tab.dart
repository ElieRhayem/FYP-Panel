import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/widgets/mc_metric.dart';
import 'package:mobile_application/core/widgets/mc_panel.dart';
import 'package:mobile_application/core/widgets/mc_radar_scanner.dart';
import 'package:mobile_application/core/widgets/status_light.dart';
import 'package:mobile_application/viewmodels/dashboard_view_model.dart';
import 'package:mobile_application/widgets/grid_background.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_widgets.dart';
import 'package:mobile_application/views/common/dashboard/dashboard_helpers.dart';

class OverviewTab extends StatefulWidget {
  final VoidCallback? onSeeMore;
  final VoidCallback? onSoilingSeeMore;
  final VoidCallback? onTrackingSeeMore;

  const OverviewTab({
    super.key,
    this.onSeeMore,
    this.onSoilingSeeMore,
    this.onTrackingSeeMore,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> with AutomaticKeepAliveClientMixin{
  late Future<Map<String, dynamic>> _weatherFuture;
  Timer? _weatherRefreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchBeirutWeather();

    _weatherRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (!mounted) return;
      setState(() {
        _weatherFuture = _fetchBeirutWeather();
      });
    });
  }

  @override
  void dispose() {
    _weatherRefreshTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchBeirutWeather() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=33.8938'
          '&longitude=35.5018'
          '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m'
          '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset'
          '&timezone=auto',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Beirut weather');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _weatherLabelFromCode(int code) {
    switch (code) {
      case 0:
        return "Clear";
      case 1:
      case 2:
      case 3:
        return "Partly Cloudy";
      case 45:
      case 48:
        return "Fog";
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return "Rain";
      case 71:
      case 73:
      case 75:
        return "Snow";
      case 95:
      case 96:
      case 99:
        return "Thunderstorm";
      default:
        return "Weather Unavailable";
    }
  }

  IconData _weatherIconFromCode(int code, bool isDay) {
    if (code == 0) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
    }
    if ([1, 2, 3].contains(code)) return Icons.cloud_queue_rounded;
    if ([45, 48].contains(code)) return Icons.foggy;
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) {
      return Icons.grain_rounded;
    }
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  Widget _weatherChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.cyanAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusMiniTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.black.withOpacity(0.16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(
                color: Colors.white.withOpacity(0.60),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _energyDayRow({
    required String day,
    required double value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              day,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "${value.toStringAsFixed(0)} Wh",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showEnergyDialog(BuildContext context, DashboardViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final totalWeek = vm.energyWeekWh.fold<double>(0, (a, b) => a + b);
    final avgWeek = totalWeek / vm.energyWeekWh.length;
    final highest = vm.energyWeekWh.reduce((a, b) => a > b ? a : b);
    final lowest = vm.energyWeekWh.reduce((a, b) => a < b ? a : b);
    final dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: cs.primary.withOpacity(0.15)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns = constraints.maxWidth >= 360;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.primary.withOpacity(0.10),
                              border: Border.all(color: cs.primary.withOpacity(0.22)),
                            ),
                            child: Icon(Icons.bolt_rounded, color: cs.primary),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Energy Details",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Detailed production summary for the current day and the last 7 days.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.68),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (useTwoColumns)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: McMetric(
                                label: "Energy Today",
                                value: vm.energyTodayWh.toStringAsFixed(0),
                                unit: "Wh",
                                icon: Icons.flash_on_rounded,
                                accent: cs.primary,
                                hint: "Current accumulated production",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: McMetric(
                                label: "Weekly Average",
                                value: avgWeek.toStringAsFixed(0),
                                unit: "Wh",
                                icon: Icons.analytics_rounded,
                                accent: const Color(0xFFFFC857),
                                hint: "Average over last 7 days",
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            McMetric(
                              label: "Energy Today",
                              value: vm.energyTodayWh.toStringAsFixed(0),
                              unit: "Wh",
                              icon: Icons.flash_on_rounded,
                              accent: cs.primary,
                              hint: "Current accumulated production",
                            ),
                            const SizedBox(height: 12),
                            McMetric(
                              label: "Weekly Average",
                              value: avgWeek.toStringAsFixed(0),
                              unit: "Wh",
                              icon: Icons.analytics_rounded,
                              accent: const Color(0xFFFFC857),
                              hint: "Average over last 7 days",
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _detailPill("Week Total", "${totalWeek.toStringAsFixed(0)} Wh"),
                          _detailPill("Best Day", "${highest.toStringAsFixed(0)} Wh"),
                          _detailPill("Lowest Day", "${lowest.toStringAsFixed(0)} Wh"),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Daily Energy Output",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.90),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: List.generate(vm.energyWeekWh.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == vm.energyWeekWh.length - 1 ? 0 : 8,
                            ),
                            child: _energyDayRow(
                              day: dayLabels[index % dayLabels.length],
                              value: vm.energyWeekWh[index],
                              accent: index == vm.energyWeekWh.length - 1
                                  ? cs.primary
                                  : const Color(0xFFFFC857),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _lastChangedPositionLabel(DashboardViewModel vm) {
    if (vm.trackingHistory.isEmpty) return "No tracking history available";
    return vm.trackingHistory.first.timeLabel;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = context.watch<DashboardViewModel>();
    final cs = Theme.of(context).colorScheme;

    final status = statusFromLoss(vm.estimatedLoss);
    final statusColor = statusColorFromStatus(status);

    return Stack(
      children: [
        const Positioned.fill(child: GridBackground()),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: McPanel(
                      title: "BEIRUT WEATHER",
                      child: SizedBox(
                        height: 110,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: McPanel(
                      title: "BEIRUT WEATHER",
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.white70,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Unable to load live weather right now.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                final current = data['current'] as Map<String, dynamic>;
                final daily = data['daily'] as Map<String, dynamic>;

                final temp = (current['temperature_2m'] as num).toDouble();
                final apparent =
                (current['apparent_temperature'] as num).toDouble();
                final humidity =
                (current['relative_humidity_2m'] as num).toInt();
                final wind = (current['wind_speed_10m'] as num).toDouble();
                final rain = (current['precipitation'] as num).toDouble();
                final code = (current['weather_code'] as num).toInt();
                final isDay = (current['is_day'] as num).toInt() == 1;
                final maxTemp =
                (daily['temperature_2m_max'][0] as num).toDouble();
                final minTemp =
                (daily['temperature_2m_min'][0] as num).toDouble();

                final weatherLabel = _weatherLabelFromCode(code);
                final weatherIcon = _weatherIconFromCode(code, isDay);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: McPanel(
                    title: "BEIRUT WEATHER",
                    trailing: Text(
                      weatherLabel.toUpperCase(),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.primary.withOpacity(0.10),
                            border:
                            Border.all(color: cs.primary.withOpacity(0.25)),
                          ),
                          child: Icon(weatherIcon, size: 34, color: cs.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${temp.toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Feels like ${apparent.toStringAsFixed(1)}°C",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.70),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _weatherChip(Icons.air_rounded,
                                      "${wind.toStringAsFixed(0)} km/h"),
                                  _weatherChip(
                                      Icons.opacity_rounded, "$humidity%"),
                                  _weatherChip(Icons.umbrella_rounded,
                                      "${rain.toStringAsFixed(1)} mm"),
                                  _weatherChip(
                                    Icons.thermostat_rounded,
                                    "${minTemp.toStringAsFixed(0)}° / ${maxTemp.toStringAsFixed(0)}°",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            McPanel(
              title: "SYSTEM STATUS",
              trailing: StatusLight(color: statusColor, label: status),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: BigReadout(
                          label: "POWER",
                          value: vm.powerW,
                          unit: "W",
                          accent: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BigReadout(
                          label: "LOSS",
                          value: vm.estimatedLoss,
                          unit: "%",
                          accent: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: McMetric(
                          label: "Energy Today",
                          value: vm.energyTodayWh.toStringAsFixed(0),
                          unit: "Wh",
                          icon: Icons.bolt_rounded,
                          accent: cs.primary,
                          hint: "Accumulated production today",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: McMetric(
                          label: "7-Day Avg",
                          value: (vm.energyWeekWh.fold<double>(
                              0, (a, b) => a + b) /
                              vm.energyWeekWh.length)
                              .toStringAsFixed(0),
                          unit: "Wh",
                          icon: Icons.analytics_rounded,
                          accent: const Color(0xFFFFC857),
                          hint: "Average daily production",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showEnergyDialog(context, vm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            "Tap for detailed energy view",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.70),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white.withOpacity(0.60),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            McPanel(
              title: "OVERALL HEALTH",
              trailing: InkWell(
                onTap: widget.onSeeMore,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    "See more",
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              child: McRadarScanner(
                healthScore: vm.overallHealth,
                title: "",
                accent: cs.primary,
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, c) {
                final twoCols = c.maxWidth > 720;

                final left = Column(
                  children: [
                    McPanel(
                      title: "SOILING",
                      trailing: InkWell(
                        onTap: widget.onSoilingSeeMore,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            "See more",
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: McMetric(
                                  label: "Mode",
                                  value: vm.cleaningMode,
                                  unit: "",
                                  icon: Icons.cleaning_services_rounded,
                                  accent: const Color(0xFFFFC857),
                                  hint: "Current cleaning operating mode",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: McMetric(
                                  label: "Soiling Index",
                                  value: vm.soilingIndex.toStringAsFixed(1),
                                  unit: "%",
                                  icon: Icons.visibility_rounded,
                                  accent: const Color(0xFF7C4DFF),
                                  hint: "Latest camera-based surface scan",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                              color: Colors.white.withOpacity(0.03),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.cyanAccent.withOpacity(0.10),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Last cleaned",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vm.lastCleaningDisplayLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final right = Column(
                  children: [
                    McPanel(
                      title: "TRACKING SNAPSHOT",
                      trailing: InkWell(
                        onTap: widget.onTrackingSeeMore,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            "See more",
                            style: TextStyle(
                              color: cs.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: McMetric(
                                  label: "Mode",
                                  value: vm.trackerMode,
                                  unit: "",
                                  icon: Icons.explore_rounded,
                                  accent: const Color(0xFFFFC857),
                                  hint: "Current tracking operating mode",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: McMetric(
                                  label: "Avg Irradiance",
                                  value: vm.avgIrradiance.toStringAsFixed(1),
                                  unit: "%",
                                  icon: Icons.wb_sunny_outlined,
                                  accent: const Color(0xFFFFC857),
                                  hint: "Average across 4 LDR sensors",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                              color: Colors.white.withOpacity(0.03),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.cyanAccent.withOpacity(0.10),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Last changed position",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _lastChangedPositionLabel(vm),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
          ],
        ),
      ],
    );
  }
}