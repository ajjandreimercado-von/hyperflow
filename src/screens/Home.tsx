import React, { useState, useEffect } from 'react';
import { useAppContext } from '../store';
import { WaveProgress, BeverageType } from '../components/WaveProgress';
import { cn } from '../utils';
import { Droplet, Plus, Coffee } from 'lucide-react';
import { motion } from 'motion/react';

export function Home() {
  const { state, logDrink, getTodayLogs, getLastDrink, updateSettings } = useAppContext();
  const [now, setNow] = useState(Date.now());
  const [notificationSent, setNotificationSent] = useState(false);
  
  const theme = state.settings.theme || 'water';

  const handleDrink = (amount: number, type: BeverageType) => {
    if (theme !== type) {
      updateSettings({ theme: type });
    }
    logDrink(amount);
  };

  const todayLogs = getTodayLogs();
  const currentTotalMl = todayLogs.reduce((sum, log) => sum + log.amountMl, 0);
  const goalMl = state.settings.dailyGoalMl;
  
  const percentage = Math.min(100, Math.round((currentTotalMl / goalMl) * 100)) || 0;
  
  const lastDrink = getLastDrink();
  const intervalMs = state.settings.intervalMinutes * 60 * 1000;
  
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  let remainingMs = 0;
  let remainingPercentage = 0;
  
  if (lastDrink) {
    const elapsedMs = now - lastDrink.timestampMs;
    remainingMs = Math.max(0, intervalMs - elapsedMs);
    remainingPercentage = remainingMs / intervalMs;
  } else {
    remainingPercentage = 0;
  }
  
  const isEmpty = remainingPercentage === 0;

  useEffect(() => {
    if (isEmpty && !notificationSent && state.settings.notificationsEnabled && 'Notification' in window) {
      if (Notification.permission === 'granted') {
        new Notification("💧 Time to hydrate!", {
          body: `It's been a while. Drink ${state.settings.glassSizeMl}ml of water!`,
          icon: '/vite.svg'
        });
      }
      setNotificationSent(true);
    }
    
    if (!isEmpty) {
      setNotificationSent(false);
    }
  }, [isEmpty, notificationSent, state.settings]);

  let timeLabel = "Now!";
  if (remainingMs > 0) {
    const h = Math.floor(remainingMs / 3600000);
    const m = Math.floor((remainingMs % 3600000) / 60000);
    if (h > 0) {
      timeLabel = `${h}h ${m}m`;
    } else {
      timeLabel = `${m}m`;
    }
  }

  const nextGlassStyles = {
    water: "shadow-[0_6px_0_0_#e0f2fe,0_15px_30px_rgba(14,165,233,0.1)] border-sky-100",
    coffee: "shadow-[0_6px_0_0_#fef3c7,0_15px_30px_rgba(217,119,6,0.1)] border-amber-100",
    smoothie: "shadow-[0_6px_0_0_#ffe4e6,0_15px_30px_rgba(244,63,94,0.1)] border-pink-100"
  };

  const timeTextColors = {
    water: "text-sky-500",
    coffee: "text-amber-600",
    smoothie: "text-pink-500"
  };

  return (
    <div className="flex-1 flex flex-col pt-2 pb-28 items-center px-6 relative z-10">
      
      <h1 className="text-xl font-black text-slate-800 mb-6 drop-shadow-sm tracking-tight">Drink Water Reminder</h1>
      
      {/* Theme Toggle */}
      <div className="flex bg-white p-1 rounded-full shadow-sm mb-6 border border-slate-100">
        {(['water', 'coffee', 'smoothie'] as const).map(t => (
          <button
            key={t}
            onClick={() => updateSettings({ theme: t })}
            className={cn(
              "px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider transition-all",
              theme === t 
                ? t === 'water' ? "bg-sky-500 text-white shadow-md"
                : t === 'coffee' ? "bg-amber-500 text-white shadow-md"
                : "bg-pink-500 text-white shadow-md"
                : "text-slate-400 hover:text-slate-600"
            )}
          >
            {t}
          </button>
        ))}
      </div>
      
      <div className="text-center mb-8">
        <h2 className="text-6xl font-black text-slate-800 tracking-tight drop-shadow-sm">{percentage}%</h2>
        <p className="text-sm font-bold text-slate-400 mt-1 uppercase tracking-widest">Daily Goal: {goalMl} ml</p>
      </div>
      
      <div className="flex-1 flex flex-col items-center justify-center w-full min-h-[260px]">
         <WaveProgress 
           percentage={remainingPercentage} 
           isEmpty={isEmpty}
           beverageType={theme}
         />
         
         <div className={`mt-8 text-center bg-white px-8 py-3 rounded-full border-2 transform -translate-y-2 transition-colors ${nextGlassStyles[theme]}`}>
           <p className="text-slate-400 text-[10px] font-black uppercase tracking-widest mb-0.5">Next glass in</p>
           <p className={`text-2xl font-black tracking-tight ${isEmpty ? 'text-amber-500 animate-pulse' : timeTextColors[theme]}`}>{timeLabel}</p>
         </div>
      </div>
      
       {/* Quick Actions Row */}
      <div className="w-full mt-10 bg-white/60 backdrop-blur-md rounded-[2rem] p-5 shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-white flex justify-between gap-3 relative z-20">
         <ActionButton 
           icon={<Plus size={24} />} 
           label="Custom" 
           onClick={() => handleDrink(100, theme)} 
           border
           colorScheme={theme}
         />
         <ActionButton 
           icon={<Droplet size={24} className={theme === 'water' ? 'text-white' : 'text-sky-500'} fill="currentColor" />} 
           label={`${state.settings.glassSizeMl}ml`}
           sublabel="Water"
           onClick={() => handleDrink(state.settings.glassSizeMl, 'water')} 
           active={theme === 'water'}
           colorScheme="water"
         />
         <ActionButton 
           icon={<Coffee size={24} className={theme === 'coffee' ? 'text-white' : 'text-amber-600'} />} 
           label="350ml"
           sublabel="Coffee"
           onClick={() => handleDrink(350, 'coffee')} 
           active={theme === 'coffee'}
           colorScheme="coffee"
         />
         <ActionButton 
           icon={<Droplet size={24} className={theme === 'smoothie' ? 'text-white' : 'text-pink-500'} fill="currentColor" />} 
           label="500ml"
           sublabel="Smoothie"
           onClick={() => handleDrink(500, 'smoothie')} 
           active={theme === 'smoothie'}
           colorScheme="smoothie"
         />
      </div>
    </div>
  );
}

function ActionButton({ icon, label, sublabel, onClick, border, active, colorScheme = 'water' }: { icon: React.ReactNode, label: string, sublabel?: string, onClick: () => void, border?: boolean, active?: boolean, colorScheme?: 'water' | 'coffee' | 'smoothie' }) {
  
  const colorStyles = {
    water: active 
      ? "border-sky-400 bg-gradient-to-b from-sky-400 to-sky-500 shadow-[0_6px_0_0_#0284c7] text-white active:shadow-none" 
      : "border-slate-100 bg-white shadow-[0_6px_0_0_#e2e8f0] hover:bg-slate-50 text-slate-600 active:shadow-none",
    coffee: active 
      ? "border-amber-500 bg-gradient-to-b from-amber-500 to-amber-600 shadow-[0_6px_0_0_#b45309] text-white active:shadow-none" 
      : "border-slate-100 bg-white shadow-[0_6px_0_0_#e2e8f0] hover:bg-slate-50 text-slate-600 active:shadow-none",
    smoothie: active 
      ? "border-pink-400 bg-gradient-to-b from-pink-400 to-pink-500 shadow-[0_6px_0_0_#be185d] text-white active:shadow-none" 
      : "border-slate-100 bg-white shadow-[0_6px_0_0_#e2e8f0] hover:bg-slate-50 text-slate-600 active:shadow-none"
  };

  const borderStyles = {
    water: "border-sky-200 bg-white shadow-[0_6px_0_0_#bae6fd] text-sky-500 hover:bg-sky-50 active:shadow-none",
    coffee: "border-amber-200 bg-white shadow-[0_6px_0_0_#fde68a] text-amber-500 hover:bg-amber-50 active:shadow-none",
    smoothie: "border-pink-200 bg-white shadow-[0_6px_0_0_#fbcfe8] text-pink-500 hover:bg-pink-50 active:shadow-none"
  };

  return (
    <motion.button
      whileTap={{ y: 4, scale: 0.96 }}
      onClick={onClick}
      className={cn(
        "flex-1 flex flex-col items-center justify-center py-4 rounded-3xl border-2 transition-all relative overflow-hidden group",
        border ? borderStyles[colorScheme] : colorStyles[colorScheme]
      )}
    >
      {/* 3D Highlight for active button */}
      {active && <div className="absolute top-0 left-0 w-full h-1/2 bg-gradient-to-b from-white/30 to-transparent rounded-t-3xl"></div>}
      
      <div className={cn("mb-1.5 drop-shadow-sm")}>{icon}</div>
      <span className="text-[12px] font-black tracking-wide relative z-10">{label}</span>
      {sublabel && <span className={cn("text-[9px] font-bold uppercase tracking-wider relative z-10", active ? "text-white/90" : "text-slate-400")}>{sublabel}</span>}
    </motion.button>
  );
}
