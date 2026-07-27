export type ThemeType = 'water' | 'coffee' | 'smoothie';

export interface AppSettings {
  dailyGoalMl: number;
  glassSizeMl: number;
  wakeTime: string; // "HH:mm"
  sleepTime: string; // "HH:mm"
  intervalMinutes: number;
  notificationsEnabled: boolean;
  weightKg: number | null;
  activityLevel: 'low' | 'moderate' | 'high' | null;
  theme: ThemeType;
}

export interface HydrationLog {
  id: string;
  timestampMs: number;
  amountMl: number;
}

export interface AppState {
  settings: AppSettings;
  logs: HydrationLog[];
  onboarded: boolean;
}
