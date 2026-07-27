import React, { useState } from 'react';
import { AppProvider, useAppContext } from './store';
import { Onboarding } from './screens/Onboarding';
import { Home } from './screens/Home';
import { History } from './screens/History';
import { Settings } from './screens/Settings';
import { Droplet, BarChart2, Settings as SettingsIcon } from 'lucide-react';
import { cn } from './utils';

function AppShell() {
  const { state } = useAppContext();
  const [activeTab, setActiveTab] = useState<'home' | 'history' | 'settings'>('home');
  
  const theme = state.settings.theme || 'water';

  if (!state.onboarded) {
    return <Onboarding />;
  }

  const bgColors = {
    water: "bg-[#f4f9ff]",
    coffee: "bg-[#fff9f4]",
    smoothie: "bg-[#fff4f6]"
  };
  
  const wave1Colors = {
    water: "from-sky-200/50 to-sky-100/10",
    coffee: "from-amber-200/50 to-amber-100/10",
    smoothie: "from-pink-200/50 to-pink-100/10"
  };
  
  const wave2Colors = {
    water: "from-sky-300/40 to-sky-200/10",
    coffee: "from-amber-300/40 to-amber-200/10",
    smoothie: "from-pink-300/40 to-pink-200/10"
  };

  const navColors = {
    water: "shadow-[0_15px_40px_-10px_rgba(14,165,233,0.25),0_6px_0_0_#e0f2fe] border-sky-50",
    coffee: "shadow-[0_15px_40px_-10px_rgba(217,119,6,0.25),0_6px_0_0_#fef3c7] border-amber-50",
    smoothie: "shadow-[0_15px_40px_-10px_rgba(244,63,94,0.25),0_6px_0_0_#ffe4e6] border-pink-50"
  };

  return (
    <div className={cn("flex flex-col min-h-screen text-slate-700 font-sans relative overflow-hidden transition-colors duration-1000", bgColors[theme])}>
      
      {/* Background Atmosphere - Cute Waves */}
      <div className={cn("absolute top-[-5%] left-[-10%] w-[120%] h-64 bg-gradient-to-b z-0 rounded-b-[50%] scale-x-[1.2] origin-top pointer-events-none transition-colors duration-1000", wave1Colors[theme])}></div>
      <div className={cn("absolute top-[-5%] left-[-5%] w-[110%] h-48 bg-gradient-to-b z-0 rounded-b-[50%] scale-x-[1.5] origin-top pointer-events-none transition-colors duration-1000", wave2Colors[theme])}></div>
      
      {/* Active Screen */}
      <main className="flex-1 overflow-y-auto relative z-10 pt-4">
        {activeTab === 'home' && <Home />}
        {activeTab === 'history' && <History />}
        {activeTab === 'settings' && <Settings />}
      </main>
      
      {/* Bottom Nav */}
      <div className={cn("fixed bottom-6 w-[calc(100%-3rem)] max-w-sm left-1/2 -translate-x-1/2 bg-white px-6 py-2 flex justify-between items-center z-50 rounded-[2rem] border-2 transition-shadow duration-1000", navColors[theme])}>
        <NavButton 
          icon={<Droplet size={24} strokeWidth={2.5} />} 
          label="Drink" 
          active={activeTab === 'home'} 
          onClick={() => setActiveTab('home')}
          theme={theme}
        />
        <NavButton 
          icon={<BarChart2 size={24} strokeWidth={2.5} />} 
          label="History" 
          active={activeTab === 'history'} 
          onClick={() => setActiveTab('history')}
          theme={theme}
        />
        <NavButton 
          icon={<SettingsIcon size={24} strokeWidth={2.5} />} 
          label="Settings" 
          active={activeTab === 'settings'} 
          onClick={() => setActiveTab('settings')}
          theme={theme}
        />
      </div>
    </div>
  );
}

function NavButton({ icon, label, active, onClick, theme = 'water' }: { icon: React.ReactNode, label: string, active: boolean, onClick: () => void, theme?: 'water' | 'coffee' | 'smoothie' }) {
  
  const textColors = {
    water: {
      activeText: "text-sky-500",
      inactiveText: "text-slate-300 hover:text-sky-400",
      bgActive: "bg-sky-100/50 shadow-[0_4px_10px_rgba(14,165,233,0.1)]",
      label: "text-sky-600"
    },
    coffee: {
      activeText: "text-amber-500",
      inactiveText: "text-slate-300 hover:text-amber-400",
      bgActive: "bg-amber-100/50 shadow-[0_4px_10px_rgba(245,158,11,0.1)]",
      label: "text-amber-600"
    },
    smoothie: {
      activeText: "text-pink-500",
      inactiveText: "text-slate-300 hover:text-pink-400",
      bgActive: "bg-pink-100/50 shadow-[0_4px_10px_rgba(236,72,153,0.1)]",
      label: "text-pink-600"
    }
  };

  const colors = textColors[theme];

  return (
    <button 
      onClick={onClick}
      className={cn(
        "flex flex-col items-center justify-center transition-all duration-300 w-16 h-14 relative",
        active ? colors.activeText : cn(colors.inactiveText, "hover:-translate-y-1")
      )}
    >
      <div className={cn("p-2.5 rounded-2xl transition-all duration-300 z-10", active ? cn(colors.bgActive, "-translate-y-2 scale-110") : "bg-transparent")}>
        {icon}
      </div>
      <span className={cn("text-[10px] font-black uppercase tracking-wider transition-all duration-300 absolute bottom-1", active ? cn(colors.label, "opacity-100 translate-y-0") : "opacity-0 translate-y-4 pointer-events-none")}>{label}</span>
    </button>
  );
}

export default function App() {
  return (
    <AppProvider>
      <AppShell />
    </AppProvider>
  );
}
