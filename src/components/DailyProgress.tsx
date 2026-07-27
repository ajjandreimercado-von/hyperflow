import React from 'react';
import { cn } from '../utils';

interface DailyProgressProps {
  currentMl: number;
  goalMl: number;
}

export function DailyProgress({ currentMl, goalMl }: DailyProgressProps) {
  const percentage = Math.min(100, Math.round((currentMl / goalMl) * 100)) || 0;
  
  return (
    <div className="flex flex-col gap-2 w-full max-w-sm mx-auto px-4">
      <div className="flex justify-between items-end">
        <span className="text-xs font-bold text-cyan-400 uppercase tracking-tighter">Daily Progress</span>
        <span className="text-lg font-mono font-bold text-white">
          {currentMl} <span className="text-slate-500 text-sm italic uppercase">/ {goalMl} ml</span>
        </span>
      </div>
      <div className="h-2 w-full bg-slate-800 rounded-full overflow-hidden flex shadow-inner">
        <div 
          className="h-full bg-gradient-to-r from-blue-600 to-cyan-400 transition-all duration-1000 ease-out shadow-[0_0_10px_rgba(34,211,238,0.5)]"
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  );
}
