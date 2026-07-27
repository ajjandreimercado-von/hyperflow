import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'app_shell.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.init();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const HydroFlowApp());
}

class HydroFlowApp extends StatelessWidget {
  const HydroFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'HydroFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}

class MainRouter extends StatelessWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Show loading while state is being loaded from SharedPreferences
        if (!provider.initialized) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F9FF),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF38BDF8), Color(0xFF7DD3FC)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0xFF0284C7),
                          blurRadius: 0,
                          offset: Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFF0EA5E9)
                              .withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'HydroFlow',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0EA5E9),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Route based on onboarding status
        if (!provider.state.onboarded) {
          return const OnboardingScreen();
        }

        return const AppShell();
      },
    );
  }
}
