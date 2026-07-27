/// Calculate the reminder interval in minutes based on daily goal,
/// glass size, and wake/sleep times.
int calculateIntervalMinutes(
  int goalMl,
  int glassMl,
  String wake,
  String sleep,
) {
  if (goalMl <= 0 || glassMl <= 0) return 120;

  final wakeParts = wake.split(':').map(int.parse).toList();
  final sleepParts = sleep.split(':').map(int.parse).toList();

  int wakeMinutes = wakeParts[0] * 60 + wakeParts[1];
  int sleepMinutes = sleepParts[0] * 60 + sleepParts[1];

  if (sleepMinutes < wakeMinutes) {
    sleepMinutes += 24 * 60; // sleep is next day
  }

  final totalWakingMinutes = sleepMinutes - wakeMinutes;
  if (totalWakingMinutes <= 0) return 120; // fallback

  final glassesNeeded = (goalMl / glassMl).ceil();
  if (glassesNeeded <= 1) return totalWakingMinutes;

  // Calculate interval
  final interval = totalWakingMinutes / glassesNeeded;

  // Round to nearest 5 minutes
  return ((interval / 5).round() * 5).clamp(5, totalWakingMinutes);
}

/// Calculate the recommended daily water goal based on weight and activity level.
int calculateDailyGoal(double? weightKg, String? activityLevel) {
  if (weightKg == null || weightKg <= 0) return 2000;

  double goal = weightKg * 30; // base 30ml per kg

  if (activityLevel == 'moderate') {
    goal += 350;
  } else if (activityLevel == 'high') {
    goal += 700;
  }

  // Round to nearest 50ml
  return ((goal / 50).round() * 50);
}
