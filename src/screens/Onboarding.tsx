import React, { useState } from 'react';
import { useAppContext } from '../store';
import { calculateDailyGoal, cn } from '../utils';
import { Droplet } from 'lucide-react';
import { motion } from 'motion/react';

export function Onboarding() {
  const { updateSettings, completeOnboarding } = useAppContext();
  const [step, setStep] = useState(1);
  const [weight, setWeight] = useState('');
  const [activity, setActivity] = useState<'low' | 'moderate' | 'high' | ''>('');
  const [glass, setGlass] = useState('250');
  
  const handleComplete = () => {
    const weightNum = weight ? parseFloat(weight) : null;
    const act = activity || null;
    const computedGoal = calculateDailyGoal(weightNum, act as any);
    
    updateSettings({
      weightKg: weightNum,
      activityLevel: act as any,
      glassSizeMl: parseInt(glass, 10),
      dailyGoalMl: computedGoal,
    });
    
    if ('Notification' in window) {
      Notification.requestPermission();
    }
    
    completeOnboarding();
  };

  return (
    <div className="min-h-screen flex flex-col p-6 items-center justify-center max-w-md mx-auto z-10 relative bg-[#f4f9ff]">
      <motion.div 
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="w-24 h-24 bg-gradient-to-tr from-sky-400 to-sky-200 rounded-[2rem] flex items-center justify-center mb-8 text-white shadow-[0_8px_0_0_#0284c7,0_15px_40px_-10px_rgba(14,165,233,0.5)] rotate-3 border-2 border-white"
      >
        <Droplet size={48} strokeWidth={2.5} fill="currentColor" className="text-white drop-shadow-md" />
      </motion.div>
      
      <h1 className="text-3xl font-black text-slate-800 mb-2 tracking-tight text-center drop-shadow-sm">Welcome to <br/><span className="text-sky-500">HydroFlow</span></h1>
      <p className="text-slate-400 text-center mb-10 text-xs font-bold uppercase tracking-widest">Let's set up your profile</p>
      
      {step === 1 && (
        <motion.div initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} className="w-full space-y-6">
          <div className="space-y-2">
            <label className="text-[10px] font-bold uppercase tracking-widest text-slate-400 pl-2">Body Weight (kg, optional)</label>
            <input 
              type="number" 
              placeholder="e.g. 70" 
              value={weight} 
              onChange={e => setWeight(e.target.value)}
              className="w-full p-4 bg-white border-2 border-slate-100 text-slate-700 rounded-2xl outline-none focus:border-sky-400 shadow-[0_4px_0_0_#e2e8f0] focus:shadow-[0_4px_0_0_#bae6fd] transition-all font-bold placeholder:text-slate-300 placeholder:font-medium"
            />
          </div>
          
          <div className="space-y-3">
            <label className="text-[10px] font-bold uppercase tracking-widest text-slate-400 pl-2">Activity Level</label>
            <div className="grid grid-cols-3 gap-3">
              {(['low', 'moderate', 'high'] as const).map(lvl => (
                <button
                  key={lvl}
                  onClick={() => setActivity(lvl)}
                  className={`py-4 px-2 rounded-2xl border-2 text-[10px] font-black uppercase tracking-widest transition-all ${
                    activity === lvl 
                      ? 'bg-sky-100 border-sky-300 text-sky-600 shadow-[0_4px_0_0_#7dd3fc] -translate-y-1' 
                      : 'bg-white border-slate-100 text-slate-400 hover:bg-slate-50 shadow-[0_4px_0_0_#e2e8f0] active:translate-y-1 active:shadow-none'
                  }`}
                >
                  {lvl}
                </button>
              ))}
            </div>
          </div>
          
          <button 
            onClick={() => setStep(2)}
            className="w-full p-4 bg-gradient-to-b from-sky-400 to-sky-500 text-white font-black uppercase tracking-widest text-sm rounded-2xl shadow-[0_6px_0_0_#0284c7,0_15px_30px_rgba(14,165,233,0.3)] active:translate-y-1 active:shadow-none transition-all mt-8"
          >
            Continue
          </button>
          
          <button 
            onClick={() => {
              setWeight('');
              setActivity('');
              setStep(2);
            }}
            className="w-full p-4 text-slate-400 text-xs font-bold uppercase tracking-widest active:scale-95 transition-transform hover:text-sky-500 bg-white border-2 border-slate-100 rounded-2xl shadow-[0_4px_0_0_#e2e8f0] active:translate-y-1 active:shadow-none"
          >
            Skip (Use Default 2000ml)
          </button>
        </motion.div>
      )}
      
      {step === 2 && (
        <motion.div initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} className="w-full space-y-6">
          <div className="space-y-3">
            <label className="text-[10px] font-bold uppercase tracking-widest text-slate-400 pl-2">Typical Glass Size</label>
            <div className="grid grid-cols-2 gap-3">
              {[150, 250, 350, 500].map(size => (
                <button
                  key={size}
                  onClick={() => setGlass(size.toString())}
                  className={`p-6 rounded-3xl border-2 flex flex-col items-center justify-center gap-2 transition-all ${
                    glass === size.toString() 
                      ? 'bg-sky-100 border-sky-300 text-sky-600 shadow-[0_4px_0_0_#7dd3fc] -translate-y-1' 
                      : 'bg-white border-slate-100 text-slate-400 hover:bg-slate-50 shadow-[0_4px_0_0_#e2e8f0] active:translate-y-1 active:shadow-none'
                  }`}
                >
                  <span className={cn("font-black text-2xl", glass === size.toString() ? "text-sky-600" : "text-slate-700")}>{size} <span className="text-sm font-bold opacity-70">ml</span></span>
                  <span className="text-[10px] font-bold uppercase tracking-widest opacity-80">
                    {size === 150 ? 'Small cup' : size === 250 ? 'Standard glass' : size === 350 ? 'Mug' : 'Bottle'}
                  </span>
                </button>
              ))}
            </div>
          </div>
          
          <button 
            onClick={handleComplete}
            className="w-full p-4 bg-gradient-to-b from-sky-400 to-sky-500 text-white font-black uppercase tracking-widest text-sm rounded-2xl shadow-[0_6px_0_0_#0284c7,0_15px_30px_rgba(14,165,233,0.3)] active:translate-y-1 active:shadow-none transition-all mt-8"
          >
            Start Hydrating
          </button>
          <button 
            onClick={() => setStep(1)}
            className="w-full p-4 text-slate-400 text-xs font-bold uppercase tracking-widest active:scale-95 transition-transform hover:text-sky-500 bg-white border-2 border-slate-100 rounded-2xl shadow-[0_4px_0_0_#e2e8f0] active:translate-y-1 active:shadow-none"
          >
            Back
          </button>
        </motion.div>
      )}
    </div>
  );
}
