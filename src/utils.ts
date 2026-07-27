import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Calculate interval based on goal, glass size, wake and sleep
export function calculateIntervalMinutes(
  goalMl: number,
  glassMl: number,
  wake: string,
  sleep: string
): number {
  if (goalMl <= 0 || glassMl <= 0) return 120;
  
  const [wakeH, wakeM] = wake.split(':').map(Number);
  const [sleepH, sleepM] = sleep.split(':').map(Number);
  
  let wakeMinutes = wakeH * 60 + wakeM;
  let sleepMinutes = sleepH * 60 + sleepM;
  
  if (sleepMinutes < wakeMinutes) {
    sleepMinutes += 24 * 60; // sleep is next day
  }
  
  const totalWakingMinutes = sleepMinutes - wakeMinutes;
  if (totalWakingMinutes <= 0) return 120; // fallback
  
  const glassesNeeded = Math.ceil(goalMl / glassMl);
  if (glassesNeeded <= 1) return totalWakingMinutes;
  
  // Calculate interval
  const interval = totalWakingMinutes / glassesNeeded;
  
  // Round to nearest 5 minutes
  return Math.round(interval / 5) * 5;
}

export function calculateDailyGoal(weightKg?: number | null, activityLevel?: 'low' | 'moderate' | 'high' | null): number {
  if (!weightKg) return 2000;
  
  let goal = weightKg * 30; // base 30ml per kg
  
  if (activityLevel === 'moderate') {
    goal += 350;
  } else if (activityLevel === 'high') {
    goal += 700;
  }
  
  // Round to nearest 50ml
  return Math.round(goal / 50) * 50;
}
