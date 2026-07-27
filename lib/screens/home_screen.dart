import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/wave_progress.dart';
import '../widgets/action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  int _now = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now().millisecondsSinceEpoch;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _handleDrink(BuildContext context, int amount, ThemeType type) {
    final provider = context.read<AppProvider>();
    final currentTheme = provider.state.settings.theme;
    if (currentTheme != type) {
      provider.updateSettings(theme: type);
    }
    provider.logDrink(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        final theme = state.settings.theme;
        final colors = AppTheme.colorsFor(theme);

        final todayLogs = provider.getTodayLogs();
        final currentTotalMl =
            todayLogs.fold<int>(0, (sum, log) => sum + log.amountMl);
        final goalMl = state.settings.dailyGoalMl;
        final percentage =
            goalMl > 0 ? (currentTotalMl / goalMl * 100).round().clamp(0, 100) : 0;

        final lastDrink = provider.getLastDrink();
        final intervalMs = state.settings.intervalMinutes * 60 * 1000;

        double remainingPercentage = 0;
        int remainingMs = 0;

        if (lastDrink != null) {
          final elapsedMs = _now - lastDrink.timestampMs;
          remainingMs = (intervalMs - elapsedMs).clamp(0, intervalMs);
          remainingPercentage = remainingMs / intervalMs;
        }

        final isEmpty = remainingPercentage == 0;

        String timeLabel = 'Now!';
        if (remainingMs > 0) {
          final h = remainingMs ~/ 3600000;
          final m = (remainingMs % 3600000) ~/ 60000;
          if (h > 0) {
            timeLabel = '${h}h ${m}m';
          } else {
            timeLabel = '${m}m';
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 8, left: 24, right: 24, bottom: 120),
          child: Column(
            children: [
              // Title
              const Text(
                'Drink Water Reminder',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Theme Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: ThemeType.values.map((t) {
                    final isActive = theme == t;
                    final btnColors = AppTheme.colorsFor(t);
                    return GestureDetector(
                      onTap: () =>
                          provider.updateSettings(theme: t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? btnColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: btnColors.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          t.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: isActive
                                ? Colors.white
                                : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Percentage + Goal
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DAILY GOAL: $goalMl ML',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 24),

              // Wave Progress Cup
              WaveProgress(
                percentage: remainingPercentage,
                isEmpty: isEmpty,
                beverageType: theme,
              ),

              const SizedBox(height: 32),

              // Next glass timer
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: colors.borderLight,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.borderLight,
                      blurRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'NEXT GLASS IN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMuted,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isEmpty
                            ? const Color(0xFFF59E0B)
                            : colors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Quick Actions Row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ActionButton(
                      icon: Icons.add_rounded,
                      label: 'Custom',
                      onTap: () => _handleDrink(context, 100, theme),
                      border: true,
                      colorScheme: theme,
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      icon: Icons.water_drop_rounded,
                      iconColor: theme == ThemeType.water
                          ? Colors.white
                          : const Color(0xFF0EA5E9),
                      label: '${state.settings.glassSizeMl}ml',
                      sublabel: 'WATER',
                      onTap: () => _handleDrink(
                          context,
                          state.settings.glassSizeMl,
                          ThemeType.water),
                      active: theme == ThemeType.water,
                      colorScheme: ThemeType.water,
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      icon: Icons.coffee_rounded,
                      iconColor: theme == ThemeType.coffee
                          ? Colors.white
                          : const Color(0xFFD97706),
                      label: '350ml',
                      sublabel: 'COFFEE',
                      onTap: () =>
                          _handleDrink(context, 350, ThemeType.coffee),
                      active: theme == ThemeType.coffee,
                      colorScheme: ThemeType.coffee,
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      icon: Icons.water_drop_rounded,
                      iconColor: theme == ThemeType.smoothie
                          ? Colors.white
                          : const Color(0xFFEC4899),
                      label: '500ml',
                      sublabel: 'SMOOTHIE',
                      onTap: () =>
                          _handleDrink(context, 500, ThemeType.smoothie),
                      active: theme == ThemeType.smoothie,
                      colorScheme: ThemeType.smoothie,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
