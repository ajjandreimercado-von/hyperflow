import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { AppState, AppSettings, HydrationLog } from './types';
import { calculateIntervalMinutes, calculateDailyGoal } from './utils';
import { v4 as uuidv4 } from 'uuid';

const STORAGE_KEY = 'hydroflow_state';

const defaultSettings: AppSettings = {
  dailyGoalMl: 2000,
  glassSizeMl: 250,
  wakeTime: '07:00',
  sleepTime: '22:00',
  intervalMinutes: calculateIntervalMinutes(2000, 250, '07:00', '22:00'),
  notificationsEnabled: false,
  weightKg: null,
  activityLevel: null,
  theme: 'water',
};

const defaultState: AppState = {
  settings: defaultSettings,
  logs: [],
  onboarded: false,
};

interface AppContextType {
  state: AppState;
  updateSettings: (settings: Partial<AppSettings>) => void;
  logDrink: (amountMl?: number) => void;
  completeOnboarding: () => void;
  resetData: () => void;
  getTodayLogs: () => HydrationLog[];
  getLastDrink: () => HydrationLog | null;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AppState>(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        return { 
          ...defaultState, 
          ...parsed,
          settings: { ...defaultSettings, ...(parsed.settings || {}) }
        };
      }
    } catch (e) {
      console.error('Failed to load state', e);
    }
    return defaultState;
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [state]);

  const updateSettings = (newSettings: Partial<AppSettings>) => {
    setState(prev => {
      const updated = { ...prev.settings, ...newSettings };
      
      // Auto-recalculate interval if goal, glass, or time changes
      if (newSettings.dailyGoalMl || newSettings.glassSizeMl || newSettings.wakeTime || newSettings.sleepTime) {
        updated.intervalMinutes = calculateIntervalMinutes(
          updated.dailyGoalMl,
          updated.glassSizeMl,
          updated.wakeTime,
          updated.sleepTime
        );
      }
      
      return { ...prev, settings: updated };
    });
  };

  const logDrink = (amountMl?: number) => {
    setState(prev => ({
      ...prev,
      logs: [
        ...prev.logs,
        {
          id: uuidv4(),
          timestampMs: Date.now(),
          amountMl: amountMl ?? prev.settings.glassSizeMl,
        }
      ]
    }));
  };

  const completeOnboarding = () => {
    setState(prev => ({ ...prev, onboarded: true }));
  };

  const resetData = () => {
    setState(defaultState);
  };

  const getTodayLogs = () => {
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    return state.logs.filter(log => log.timestampMs >= startOfToday.getTime());
  };

  const getLastDrink = () => {
    if (state.logs.length === 0) return null;
    return [...state.logs].sort((a, b) => b.timestampMs - a.timestampMs)[0];
  };

  return (
    <AppContext.Provider value={{ state, updateSettings, logDrink, completeOnboarding, resetData, getTodayLogs, getLastDrink }}>
      {children}
    </AppContext.Provider>
  );
}

export function useAppContext() {
  const context = useContext(AppContext);
  if (!context) throw new Error('useAppContext must be used within AppProvider');
  return context;
}
