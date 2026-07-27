// === Theme Type ===
enum ThemeType {
  water,
  coffee,
  smoothie;

  String toJson() => name;

  static ThemeType fromJson(String json) {
    return ThemeType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ThemeType.water,
    );
  }
}

// === Activity Level ===
enum ActivityLevel {
  low,
  moderate,
  high;

  String toJson() => name;

  static ActivityLevel fromJson(String json) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ActivityLevel.moderate,
    );
  }
}

// === Hydration Log ===
class HydrationLog {
  final String id;
  final int timestampMs;
  final int amountMl;

  const HydrationLog({
    required this.id,
    required this.timestampMs,
    required this.amountMl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestampMs': timestampMs,
        'amountMl': amountMl,
      };

  factory HydrationLog.fromJson(Map<String, dynamic> json) => HydrationLog(
        id: json['id'] as String,
        timestampMs: json['timestampMs'] as int,
        amountMl: json['amountMl'] as int,
      );
}

// === App Settings ===
class AppSettings {
  final int dailyGoalMl;
  final int glassSizeMl;
  final String wakeTime; // "HH:mm"
  final String sleepTime; // "HH:mm"
  final int intervalMinutes;
  final bool notificationsEnabled;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final ThemeType theme;

  const AppSettings({
    this.dailyGoalMl = 2000,
    this.glassSizeMl = 250,
    this.wakeTime = '07:00',
    this.sleepTime = '22:00',
    this.intervalMinutes = 120,
    this.notificationsEnabled = false,
    this.weightKg,
    this.activityLevel,
    this.theme = ThemeType.water,
  });

  AppSettings copyWith({
    int? dailyGoalMl,
    int? glassSizeMl,
    String? wakeTime,
    String? sleepTime,
    int? intervalMinutes,
    bool? notificationsEnabled,
    double? weightKg,
    bool clearWeight = false,
    ActivityLevel? activityLevel,
    bool clearActivity = false,
    ThemeType? theme,
  }) {
    return AppSettings(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      glassSizeMl: glassSizeMl ?? this.glassSizeMl,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      activityLevel:
          clearActivity ? null : (activityLevel ?? this.activityLevel),
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyGoalMl': dailyGoalMl,
        'glassSizeMl': glassSizeMl,
        'wakeTime': wakeTime,
        'sleepTime': sleepTime,
        'intervalMinutes': intervalMinutes,
        'notificationsEnabled': notificationsEnabled,
        'weightKg': weightKg,
        'activityLevel': activityLevel?.toJson(),
        'theme': theme.toJson(),
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        dailyGoalMl: json['dailyGoalMl'] as int? ?? 2000,
        glassSizeMl: json['glassSizeMl'] as int? ?? 250,
        wakeTime: json['wakeTime'] as String? ?? '07:00',
        sleepTime: json['sleepTime'] as String? ?? '22:00',
        intervalMinutes: json['intervalMinutes'] as int? ?? 120,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        activityLevel: json['activityLevel'] != null
            ? ActivityLevel.fromJson(json['activityLevel'] as String)
            : null,
        theme: json['theme'] != null
            ? ThemeType.fromJson(json['theme'] as String)
            : ThemeType.water,
      );
}

// === App State ===
class AppState {
  final AppSettings settings;
  final List<HydrationLog> logs;
  final bool onboarded;

  const AppState({
    this.settings = const AppSettings(),
    this.logs = const [],
    this.onboarded = false,
  });

  AppState copyWith({
    AppSettings? settings,
    List<HydrationLog>? logs,
    bool? onboarded,
  }) {
    return AppState(
      settings: settings ?? this.settings,
      logs: logs ?? this.logs,
      onboarded: onboarded ?? this.onboarded,
    );
  }

  Map<String, dynamic> toJson() => {
        'settings': settings.toJson(),
        'logs': logs.map((l) => l.toJson()).toList(),
        'onboarded': onboarded,
      };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
        settings: json['settings'] != null
            ? AppSettings.fromJson(json['settings'] as Map<String, dynamic>)
            : const AppSettings(),
        logs: (json['logs'] as List<dynamic>?)
                ?.map((l) =>
                    HydrationLog.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
        onboarded: json['onboarded'] as bool? ?? false,
      );
}
