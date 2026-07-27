import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_state.dart';
import '../utils/calculations.dart';
import '../services/notification_service.dart';

const _storageKey = 'hydroflow_state';
const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  AppState _state = const AppState();
  bool _initialized = false;

  AppState get state => _state;
  bool get initialized => _initialized;

  AppProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored != null) {
        final parsed = jsonDecode(stored) as Map<String, dynamic>;
        _state = AppState.fromJson(parsed);
      }
    } catch (e) {
      debugPrint('Failed to load state: $e');
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('Failed to save state: $e');
    }
  }

  void _scheduleNotification() {
    if (!_state.settings.notificationsEnabled) {
      NotificationService().cancelAll();
      return;
    }

    final lastDrink = getLastDrink();
    if (lastDrink != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = now - lastDrink.timestampMs;
      final intervalMs = _state.settings.intervalMinutes * 60 * 1000;
      final remainingMs = intervalMs - elapsedMs;

      if (remainingMs > 0) {
        NotificationService().scheduleWaterReminder(
          intervalMinutes: remainingMs ~/ 60000,
          title: 'HydroFlow',
          body: 'Time to drink a glass of water!',
        );
      } else {
        NotificationService().cancelAll();
      }
    }
  }

  void updateSettings({
    int? dailyGoalMl,
    int? glassSizeMl,
    String? wakeTime,
    String? sleepTime,
    bool? notificationsEnabled,
    double? weightKg,
    bool clearWeight = false,
    ActivityLevel? activityLevel,
    bool clearActivity = false,
    ThemeType? theme,
  }) {
    var updated = _state.settings.copyWith(
      dailyGoalMl: dailyGoalMl,
      glassSizeMl: glassSizeMl,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      notificationsEnabled: notificationsEnabled,
      weightKg: weightKg,
      clearWeight: clearWeight,
      activityLevel: activityLevel,
      clearActivity: clearActivity,
      theme: theme,
    );

    // Auto-recalculate interval if relevant fields change
    if (dailyGoalMl != null ||
        glassSizeMl != null ||
        wakeTime != null ||
        sleepTime != null) {
      final newInterval = calculateIntervalMinutes(
        updated.dailyGoalMl,
        updated.glassSizeMl,
        updated.wakeTime,
        updated.sleepTime,
      );
      updated = updated.copyWith(intervalMinutes: newInterval);
    }

    _state = _state.copyWith(settings: updated);
    notifyListeners();
    _saveState();
    _scheduleNotification();
  }

  void logDrink([int? amountMl]) {
    final log = HydrationLog(
      id: _uuid.v4(),
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      amountMl: amountMl ?? _state.settings.glassSizeMl,
    );

    _state = _state.copyWith(logs: [..._state.logs, log]);
    notifyListeners();
    _saveState();
    _scheduleNotification();
  }

  void completeOnboarding() {
    _state = _state.copyWith(onboarded: true);
    notifyListeners();
    _saveState();
  }

  void resetData() {
    _state = const AppState();
    notifyListeners();
    _saveState();
  }

  List<HydrationLog> getTodayLogs() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _state.logs
        .where((log) => log.timestampMs >= startOfToday.millisecondsSinceEpoch)
        .toList();
  }

  HydrationLog? getLastDrink() {
    if (_state.logs.isEmpty) return null;
    return _state.logs.reduce(
      (a, b) => a.timestampMs > b.timestampMs ? a : b,
    );
  }
}
