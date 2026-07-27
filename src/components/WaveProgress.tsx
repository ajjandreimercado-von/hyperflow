import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { cn } from '../utils';

export type BeverageType = 'water' | 'coffee' | 'smoothie';

interface WaveProgressProps {
  percentage: number;
  isEmpty?: boolean;
  beverageType?: BeverageType;
}

const colorMaps = {
  water: {
    bg: "bg-gradient-to-b from-sky-300 to-sky-500",
    wave1: "fill-sky-100",
    splash1: "from-sky-300 to-sky-100 drop-shadow-[0_4px_10px_rgba(56,189,248,0.4)]",
    splash2: "from-sky-400 to-sky-200 drop-shadow-[0_4px_8px_rgba(56,189,248,0.3)]",
    splash3: "from-sky-400 to-sky-100 drop-shadow-[0_2px_6px_rgba(56,189,248,0.3)]",
    shadow: "shadow-[inset_0_-10px_20px_rgba(255,255,255,0.7),0_15px_35px_rgba(14,165,233,0.15)]",
    innerShadow: "shadow-[inset_4px_0_12px_rgba(255,255,255,0.8),inset_-4px_0_12px_rgba(14,165,233,0.1)]",
    baseShadow: "bg-sky-900/10",
  },
  coffee: {
    bg: "bg-gradient-to-b from-amber-600 to-amber-800",
    wave1: "fill-amber-400/80",
    splash1: "from-amber-600 to-amber-400 drop-shadow-[0_4px_10px_rgba(217,119,6,0.4)]",
    splash2: "from-amber-700 to-amber-500 drop-shadow-[0_4px_8px_rgba(217,119,6,0.3)]",
    splash3: "from-amber-700 to-amber-400 drop-shadow-[0_2px_6px_rgba(217,119,6,0.3)]",
    shadow: "shadow-[inset_0_-10px_20px_rgba(255,255,255,0.4),0_15px_35px_rgba(180,83,9,0.15)]",
    innerShadow: "shadow-[inset_4px_0_12px_rgba(255,255,255,0.4),inset_-4px_0_12px_rgba(180,83,9,0.2)]",
    baseShadow: "bg-amber-900/10",
  },
  smoothie: {
    bg: "bg-gradient-to-b from-pink-400 to-rose-500",
    wave1: "fill-pink-200/90",
    splash1: "from-pink-400 to-pink-200 drop-shadow-[0_4px_10px_rgba(244,63,94,0.4)]",
    splash2: "from-pink-500 to-pink-300 drop-shadow-[0_4px_8px_rgba(244,63,94,0.3)]",
    splash3: "from-pink-500 to-pink-200 drop-shadow-[0_2px_6px_rgba(244,63,94,0.3)]",
    shadow: "shadow-[inset_0_-10px_20px_rgba(255,255,255,0.5),0_15px_35px_rgba(244,63,94,0.15)]",
    innerShadow: "shadow-[inset_4px_0_12px_rgba(255,255,255,0.6),inset_-4px_0_12px_rgba(244,63,94,0.15)]",
    baseShadow: "bg-rose-900/10",
  }
};

export function WaveProgress({ percentage, isEmpty = false, beverageType = 'water' }: WaveProgressProps) {
  const clamped = Math.max(0, Math.min(1, percentage));
  const waterHeight = clamped * 100;
  const colors = colorMaps[beverageType];
  
  const [tilt, setTilt] = useState({ x: 0, y: 0 });

  useEffect(() => {
    let isDeviceOrientationSupported = false;

    const handleOrientation = (event: DeviceOrientationEvent) => {
      isDeviceOrientationSupported = true;
      const { beta, gamma } = event;
      if (beta === null || gamma === null) return;
      
      const maxTilt = 15;
      const x = Math.max(-maxTilt, Math.min(maxTilt, gamma));
      let adjustedBeta = beta - 45; // Assume 45deg holding angle
      const y = Math.max(-maxTilt, Math.min(maxTilt, adjustedBeta));
      
      setTilt({ x, y });
    };

    const handleMouseMove = (e: MouseEvent) => {
      if (isDeviceOrientationSupported) return; // Skip if using accelerometer
      const x = ((e.clientX / window.innerWidth) - 0.5) * 30; // Max 15deg tilt
      const y = ((e.clientY / window.innerHeight) - 0.5) * -30; // Invert Y for mouse
      setTilt({ x, y });
    };

    window.addEventListener('deviceorientation', handleOrientation);
    window.addEventListener('mousemove', handleMouseMove);

    return () => {
      window.removeEventListener('deviceorientation', handleOrientation);
      window.removeEventListener('mousemove', handleMouseMove);
    };
  }, []);

  return (
    <motion.div 
      className="relative group flex items-end justify-center w-48 h-64 mx-auto mt-4"
      style={{ perspective: 1000 }}
      animate={{
        rotateX: tilt.y,
        rotateY: tilt.x,
      }}
      transition={{ type: "spring", stiffness: 100, damping: 20 }}
    >
      {/* 3D Cup Shadow on the table */}
      <motion.div 
        className={cn("absolute -bottom-4 left-1/2 -translate-x-1/2 w-32 h-6 rounded-full blur-md transition-colors duration-1000", colors.baseShadow)}
        animate={{
          x: tilt.x * -1,
          y: tilt.y * 0.5,
          scale: 1 + (tilt.y * -0.01)
        }}
      ></motion.div>
      
      {/* Outer Glass Container (3D Glossy) */}
      <div className={cn("absolute inset-0 border-[3px] border-white/80 bg-white/30 backdrop-blur-[2px] rounded-b-[2.5rem] rounded-t-xl overflow-hidden flex items-end z-10 transition-shadow duration-1000", colors.shadow)}>
        
        {/* Inner Glass Highlights */}
        <div className={cn("absolute inset-0 rounded-b-[2.5rem] rounded-t-xl pointer-events-none z-30 transition-shadow duration-1000", colors.innerShadow)}></div>
        <div className="absolute top-2 left-3 w-4 h-48 bg-gradient-to-b from-white to-transparent rounded-full opacity-60 z-30 pointer-events-none transform -rotate-1"></div>
        <div className="absolute top-4 right-4 w-2 h-32 bg-gradient-to-b from-white to-transparent rounded-full opacity-40 z-30 pointer-events-none transform rotate-1"></div>

        {/* The Liquid */}
        <motion.div
          className={cn(
            "w-full relative z-10 transition-colors duration-1000",
            isEmpty ? "bg-slate-200" : colors.bg
          )}
          initial={{ height: `${waterHeight}%` }}
          animate={{ height: `${waterHeight}%` }}
          transition={{ type: "spring", bounce: 0.2, duration: 1.2 }}
        >
          {/* Waves */}
          <motion.div 
            className="absolute left-0 right-0 top-0 origin-center"
            animate={{
              rotateZ: tilt.x * -0.8, // Liquid sloshes opposite to tilt
              y: tilt.y * -0.3
            }}
            transition={{ type: "spring", stiffness: 80, damping: 10 }}
          >
            <div className="absolute left-0 right-0 top-0 -translate-y-[99%] w-[200%] -translate-x-1/4 opacity-90 animate-wave-slow mix-blend-overlay pointer-events-none">
              <svg viewBox="0 0 1440 320" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none" className={cn("w-full h-12 transition-colors duration-1000", isEmpty ? "fill-slate-100/60" : colors.wave1)}>
                <path d="M0,160L48,176C96,192,192,224,288,213.3C384,203,480,149,576,133.3C672,117,768,139,864,165.3C960,192,1056,224,1152,213.3C1248,203,1344,149,1392,122.7L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
              </svg>
            </div>
            <div className="absolute left-0 right-0 top-0 -translate-y-[99%] w-[200%] -translate-x-1/4 opacity-60 animate-wave-fast mix-blend-overlay pointer-events-none">
              <svg viewBox="0 0 1440 320" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none" className={cn("w-full h-10", isEmpty ? "fill-white/60" : "fill-white/80")}>
                <path d="M0,192L48,181.3C96,171,192,149,288,144C384,139,480,149,576,165.3C672,181,768,203,864,186.7C960,171,1056,117,1152,101.3C1248,85,1344,107,1392,117.3L1440,128L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
              </svg>
            </div>
          </motion.div>
          
          {/* Cute Face (Visible when there is water) */}
          <div className={cn("absolute bottom-[15%] left-1/2 -translate-x-1/2 flex items-center justify-center gap-2 transition-opacity duration-300 z-30 drop-shadow-sm", 
            clamped > 0.3 ? "opacity-100" : "opacity-0"
          )}>
             {/* Left cheek */}
             <div className="w-3.5 h-2.5 bg-pink-400/80 rounded-full blur-[2px] mt-2"></div>
             
             {/* Eyes and Mouth container */}
             <div className="flex flex-col items-center justify-center">
                <div className="flex gap-4">
                  {/* Left Eye > */}
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0f172a" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" className="text-slate-800 opacity-80">
                    <polyline points="9 6 15 12 9 18"></polyline>
                  </svg>
                  {/* Right Eye < */}
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0f172a" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" className="text-slate-800 opacity-80">
                    <polyline points="15 6 9 12 15 18"></polyline>
                  </svg>
                </div>
                {/* Mouth */}
                <svg width="16" height="12" viewBox="0 0 24 24" fill="none" stroke="#0f172a" strokeWidth="6" strokeLinecap="round" strokeLinejoin="round" className="mt-1 opacity-80">
                  <path d="M6 9a6 6 0 0 0 12 0"></path>
                </svg>
             </div>
             
             {/* Right cheek */}
             <div className="w-3.5 h-2.5 bg-pink-400/80 rounded-full blur-[2px] mt-2"></div>
          </div>
          
          {/* Bubbles in liquid */}
          <div className="absolute bottom-4 left-6 w-3 h-3 bg-white/40 rounded-full blur-[0.5px] animate-float"></div>
          <div className="absolute bottom-12 right-8 w-2 h-2 bg-white/40 rounded-full blur-[0.5px] animate-float-delayed"></div>
          <div className="absolute bottom-20 left-10 w-1.5 h-1.5 bg-white/30 rounded-full animate-float"></div>
        </motion.div>
      </div>
      
      {/* Decorative Splash drops around it */}
      <motion.div 
        className={cn("absolute -top-6 -right-8 w-10 h-10 bg-gradient-to-tr rounded-full rounded-tr-sm rotate-45 opacity-80 animate-float z-20 border border-white/60 transition-colors duration-1000", colors.splash1)}
        animate={{ x: tilt.x * 0.8, y: tilt.y * 0.8 }}
      ></motion.div>
      <motion.div 
        className={cn("absolute top-1/3 -left-10 w-6 h-6 bg-gradient-to-tr rounded-full rounded-tl-sm -rotate-45 opacity-70 animate-float-delayed z-20 border border-white/60 transition-colors duration-1000", colors.splash2)}
        animate={{ x: tilt.x * 1.2, y: tilt.y * 1.2 }}
      ></motion.div>
      <motion.div 
        className={cn("absolute bottom-4 -right-6 w-6 h-6 bg-gradient-to-tr rounded-full rounded-tr-sm rotate-12 opacity-80 animate-float z-20 border border-white/60 transition-colors duration-1000", colors.splash3)}
        animate={{ x: tilt.x * 0.5, y: tilt.y * 0.5 }}
      ></motion.div>
    </motion.div>
  );
}

