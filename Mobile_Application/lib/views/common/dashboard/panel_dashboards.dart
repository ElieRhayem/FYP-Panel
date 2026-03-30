import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/core/theme/app_theme.dart';
import 'package:mobile_application/viewmodels/auth_viewmodel.dart';
import 'package:mobile_application/views/common/dashboard/overview_tab.dart';
import 'package:mobile_application/views/common/dashboard/tracking_tab.dart';
import 'package:mobile_application/views/common/dashboard/cleaning_tab.dart';
import 'package:mobile_application/views/common/dashboard/statistics_tab.dart';
import 'package:mobile_application/views/common/dashboard/sensors_status_tab.dart';

class PanelDashboards extends StatefulWidget {
  const PanelDashboards({super.key});

  @override
  State<PanelDashboards> createState() => _PanelDashboardsState();
}

class _PanelDashboardsState extends State<PanelDashboards> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        return "Overview";
      case 1:
        return "Tracking";
      case 2:
        return "Cleaning";
      case 3:
        return "Sensors";
      case 4:
        return "Statistics";
      default:
        return "Panel Control";
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OverviewTab(),
      const TrackingTab(),
      const CleaningTab(),
      const SensorsStatusTab(),
      const StatisticsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Sign Out",
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}