import React, { useState } from 'react';
import { useAppContext } from '../store';
import { calculateDailyGoal } from '../utils';

export function Settings() {
  const { state, updateSettings, resetData } = useAppContext();
  
  const theme = state.settings.theme || 'water';
  
  const colors = {
    water: {
      heading: "text-sky-400",
      focus: "focus:border-sky-400 focus:shadow-[0_0_15px_rgba(56,189,248,0.15)]",
      focusNoShadow: "focus:border-sky-400",
      btnSecondary: "text-sky-600 bg-sky-100 hover:bg-sky-200 shadow-[0_4px_0_0_#bae6fd]",
      accentText: "text-sky-500",
      btnPrimary: "bg-gradient-to-b from-sky-400 to-sky-500 shadow-[0_6px_0_0_#0284c7,0_15px_30px_rgba(14,165,233,0.3)]"
    },
    coffee: {
      heading: "text-amber-500",
      focus: "focus:border-amber-400 focus:shadow-[0_0_15px_rgba(251,191,36,0.15)]",
      focusNoShadow: "focus:border-amber-400",
      btnSecondary: "text-amber-700 bg-amber-100 hover:bg-amber-200 shadow-[0_4px_0_0_#fde68a]",
      accentText: "text-amber-600",
      btnPrimary: "bg-gradient-to-b from-amber-400 to-amber-500 shadow-[0_6px_0_0_#b45309,0_15px_30px_rgba(245,158,11,0.3)]"
    },
    smoothie: {
      heading: "text-pink-500",
      focus: "focus:border-pink-400 focus:shadow-[0_0_15px_rgba(244,114,182,0.15)]",
      focusNoShadow: "focus:border-pink-400",
      btnSecondary: "text-pink-700 bg-pink-100 hover:bg-pink-200 shadow-[0_4px_0_0_#fbcfe8]",
      accentText: "text-pink-600",
      btnPrimary: "bg-gradient-to-b from-pink-400 to-pink-500 shadow-[0_6px_0_0_#be185d,0_15px_30px_rgba(236,72,153,0.3)]"
    }
  };
  const t = colors[theme];
  
  const [goal, setGoal] = useState(state.settings.dailyGoalMl.toString());
  const [glass, setGlass] = useState(state.settings.glassSizeMl.toString());
  const [wake, setWake] = useState(state.settings.wakeTime);
  const [sleep, setSleep] = useState(state.settings.sleepTime);
  const [weight, setWeight] = useState(state.settings.weightKg?.toString() || '');
  const [activity, setActivity] = useState(state.settings.activityLevel || 'moderate');
  
  const handleSave = () => {
    updateSettings({
      dailyGoalMl: parseInt(goal, 10),
      glassSizeMl: parseInt(glass, 10),
      wakeTime: wake,
      sleepTime: sleep,
      weightKg: weight ? parseFloat(weight) : null,
      activityLevel: activity as any
    });
    alert('Settings saved!');
  };
  
  const handleAutoCalc = () => {
    if (!weight) return alert('Enter weight first');
    const computed = calculateDailyGoal(parseFloat(weight), activity as any);
    setGoal(computed.toString());
  };

  return (
    <div className="flex-1 flex flex-col p-6 pb-32 max-w-md mx-auto w-full z-10 relative">
      <h2 className="text-2xl font-black text-slate-800 mb-6 text-center mt-2 tracking-tight">Settings</h2>
      
      <div className="space-y-6">
        
        {/* Goal section */}
        <div className="bg-white rounded-[2rem] border-2 border-slate-100 shadow-[0_8px_0_0_#e2e8f0,0_15px_30px_rgba(0,0,0,0.05)] p-6 space-y-5">
          <h3 className={`text-xs font-bold uppercase tracking-widest ${t.heading}`}>Daily Target</h3>
          
          <div className="space-y-2">
            <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Daily Goal (ml)</label>
            <input 
              type="number" 
              value={goal}
              onChange={e => setGoal(e.target.value)}
              className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focus}`}
            />
          </div>
          
          <div className="grid grid-cols-2 gap-3 pt-2">
            <div className="space-y-2">
              <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Weight (kg)</label>
              <input 
                type="number" 
                value={weight}
                onChange={e => setWeight(e.target.value)}
                className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focusNoShadow}`}
              />
            </div>
            <div className="space-y-2">
              <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Activity</label>
              <select 
                value={activity}
                onChange={e => setActivity(e.target.value as any)}
                className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focusNoShadow}`}
              >
                <option value="low">Low</option>
                <option value="moderate">Moderate</option>
                <option value="high">High</option>
              </select>
            </div>
          </div>
          <button 
            onClick={handleAutoCalc}
            className={`w-full py-3 text-xs font-bold uppercase tracking-widest rounded-xl transition-colors active:translate-y-1 active:shadow-none ${t.btnSecondary}`}
          >
            Auto-Calculate Goal
          </button>
        </div>

        {/* Preferences */}
        <div className="bg-white rounded-[2rem] border-2 border-slate-100 shadow-[0_8px_0_0_#e2e8f0,0_15px_30px_rgba(0,0,0,0.05)] p-6 space-y-5">
          <h3 className={`text-xs font-bold uppercase tracking-widest ${t.heading}`}>Preferences</h3>
          
          <div className="space-y-2">
            <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Glass Size (ml)</label>
            <input 
              type="number" 
              value={glass}
              onChange={e => setGlass(e.target.value)}
              className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focusNoShadow}`}
            />
          </div>
          
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Wake Time</label>
              <input 
                type="time" 
                value={wake}
                onChange={e => setWake(e.target.value)}
                className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focusNoShadow}`}
              />
            </div>
            <div className="space-y-2">
              <label className="text-[10px] text-slate-400 uppercase font-bold tracking-widest">Sleep Time</label>
              <input 
                type="time" 
                value={sleep}
                onChange={e => setSleep(e.target.value)}
                className={`w-full p-4 bg-slate-50 border border-slate-100 text-slate-700 rounded-2xl outline-none focus:bg-white transition-all font-bold ${t.focusNoShadow}`}
              />
            </div>
          </div>
          
          <div className="pt-2">
            <p className="text-[10px] font-bold tracking-wide text-slate-400 bg-slate-50 p-4 rounded-2xl border-2 border-slate-100 text-center shadow-inner">
              Your calculated reminder interval is <br/><strong className={`${t.accentText} text-sm`}>{state.settings.intervalMinutes} minutes</strong>
            </p>
          </div>
        </div>

        <button 
          onClick={handleSave}
          className={`w-full p-4 text-white font-black uppercase tracking-widest text-sm rounded-[1.5rem] active:translate-y-1 active:shadow-none transition-all ${t.btnPrimary}`}
        >
          Save Changes
        </button>
        
        <button 
          onClick={() => {
            if(confirm('Are you sure you want to reset all your data?')) {
              resetData();
            }
          }}
          className="w-full p-4 text-slate-400 font-bold uppercase tracking-widest text-xs bg-white border-2 border-slate-100 rounded-[1.5rem] shadow-[0_4px_0_0_#e2e8f0] active:translate-y-1 active:shadow-none transition-all mt-2 hover:text-red-500 hover:border-red-100 hover:shadow-[0_4px_0_0_#fee2e2]"
        >
          Erase All Data
        </button>
      </div>
    </div>
  );
}
