import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/nav_bar.dart';
import 'services/notification_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    // Request permissions after the UI has loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final theme = provider.state.settings.theme;
        final colors = AppTheme.colorsFor(theme);

        return Scaffold(
          backgroundColor: colors.screenBg,
          body: SafeArea(
            child: Stack(
              children: [
                // Background atmosphere - curved gradient waves
                Positioned(
                  top: -20,
                  left: -40,
                  right: -40,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.primaryLight.withValues(alpha: 0.3),
                          colors.primaryLight.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        bottomRight: Radius.circular(200),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  left: -20,
                  right: -20,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.primary.withValues(alpha: 0.2),
                          colors.primary.withValues(alpha: 0.02),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(300),
                        bottomRight: Radius.circular(300),
                      ),
                    ),
                  ),
                ),

                // Active Screen
                Positioned.fill(
                  child: IndexedStack(
                    index: _activeTab,
                    children: const [
                      HomeScreen(),
                      HistoryScreen(),
                      SettingsScreen(),
                    ],
                  ),
                ),

                // Bottom Nav Bar
                HydroNavBar(
                  activeIndex: _activeTab,
                  onTap: (index) => setState(() => _activeTab = index),
                  theme: theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
