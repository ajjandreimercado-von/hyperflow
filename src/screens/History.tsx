import React, { useMemo } from 'react';
import { useAppContext } from '../store';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { subDays, format, startOfDay } from 'date-fns';

export function History() {
  const { state } = useAppContext();
  
  const theme = state.settings.theme || 'water';
  
  const colors = {
    water: {
      primaryText: "text-sky-400",
      barMet: "#38bdf8",
      barUnmet: "#bae6fd",
      tooltipBg: "rgba(14, 165, 233, 0.05)",
      tooltipBorder: "#f0f9ff",
      tooltipText: "text-sky-500",
      gradient: "from-sky-400 to-sky-500",
      shadow: "shadow-[0_6px_0_0_#0284c7]",
      border: "border-sky-400",
      badgeText: "text-sky-100",
      fractionText: "text-sky-200"
    },
    coffee: {
      primaryText: "text-amber-500",
      barMet: "#d97706",
      barUnmet: "#fde68a",
      tooltipBg: "rgba(245, 158, 11, 0.05)",
      tooltipBorder: "#fffbeb",
      tooltipText: "text-amber-600",
      gradient: "from-amber-400 to-amber-500",
      shadow: "shadow-[0_6px_0_0_#b45309]",
      border: "border-amber-400",
      badgeText: "text-amber-100",
      fractionText: "text-amber-200"
    },
    smoothie: {
      primaryText: "text-pink-500",
      barMet: "#ec4899",
      barUnmet: "#fbcfe8",
      tooltipBg: "rgba(236, 72, 153, 0.05)",
      tooltipBorder: "#fdf2f8",
      tooltipText: "text-pink-500",
      gradient: "from-pink-400 to-pink-500",
      shadow: "shadow-[0_6px_0_0_#be185d]",
      border: "border-pink-400",
      badgeText: "text-pink-100",
      fractionText: "text-pink-200"
    }
  };
  
  const t = colors[theme];
  
  const chartData = useMemo(() => {
    const data = [];
    const today = startOfDay(new Date());
    
    // Last 7 days
    for (let i = 6; i >= 0; i--) {
      const date = subDays(today, i);
      const dayStart = date.getTime();
      const dayEnd = dayStart + 86400000;
      
      const dayLogs = state.logs.filter(log => log.timestampMs >= dayStart && log.timestampMs < dayEnd);
      const totalMl = dayLogs.reduce((sum, log) => sum + log.amountMl, 0);
      
      data.push({
        name: i === 0 ? 'Today' : format(date, 'EEE'),
        ml: totalMl,
        date: format(date, 'MMM d'),
        goalMet: totalMl >= state.settings.dailyGoalMl
      });
    }
    return data;
  }, [state.logs, state.settings.dailyGoalMl]);

  return (
    <div className="flex-1 flex flex-col p-6 pb-32 max-w-md mx-auto w-full z-10 relative">
      <h2 className="text-2xl font-black text-slate-800 mb-6 text-center mt-2 tracking-tight">Weekly Statistics</h2>
      
      <div className="bg-white rounded-[2rem] p-6 shadow-[0_8px_0_0_#e2e8f0,0_15px_30px_rgba(0,0,0,0.05)] border-2 border-slate-100 mb-6">
        <div className="flex justify-between items-end mb-6">
          <div>
            <p className={`text-[10px] font-bold ${t.primaryText} uppercase tracking-widest mb-1`}>Last 7 Days</p>
            <p className="text-3xl font-black text-slate-700">{state.settings.dailyGoalMl} <span className="text-sm font-bold text-slate-400">ml/day</span></p>
          </div>
        </div>
        
        <div className="h-64 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
              <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#94a3b8', fontWeight: 'bold' }} dy={10} />
              <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 11, fill: '#94a3b8', fontWeight: 'bold' }} />
              <Tooltip 
                cursor={{ fill: t.tooltipBg }}
                contentStyle={{ borderRadius: '16px', border: `1px solid ${t.tooltipBorder}`, background: 'white', boxShadow: '0 4px 15px rgba(0,0,0,0.05)' }}
                formatter={(value: number) => [<span className={`${t.tooltipText} font-bold`}>{value} ml</span>, <span className="text-slate-400 text-xs">Total</span>]}
                labelStyle={{ color: '#64748b', fontWeight: 900, marginBottom: '4px' }}
              />
              <Bar dataKey="ml" radius={[8, 8, 8, 8]}>
                {chartData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.goalMet ? t.barMet : t.barUnmet} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
      
      {/* Mini Stats */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-white p-5 rounded-[2rem] border-2 border-slate-100 shadow-[0_6px_0_0_#e2e8f0] flex flex-col items-center justify-center text-center transition-transform hover:-translate-y-1">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Weekly Avg</p>
          <p className="text-2xl font-black text-slate-700 tracking-tight">
            {Math.round(chartData.reduce((acc, curr) => acc + curr.ml, 0) / 7)} <span className="text-sm font-bold text-slate-400">ml</span>
          </p>
        </div>
        <div className={`bg-gradient-to-b ${t.gradient} p-5 rounded-[2rem] border-2 ${t.border} ${t.shadow} flex flex-col items-center justify-center text-center transition-transform hover:-translate-y-1`}>
          <p className={`text-[10px] font-bold ${t.badgeText} uppercase tracking-widest mb-1`}>Goals Met</p>
          <p className="text-2xl font-black text-white tracking-tight">
            {chartData.filter(d => d.goalMet).length} <span className={`text-sm font-bold ${t.fractionText}`}>/ 7</span>
          </p>
        </div>
      </div>
    </div>
  );
}
