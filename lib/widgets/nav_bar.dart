import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class HydroNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  final ThemeType theme;

  const HydroNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsFor(theme);

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: colors.borderLight.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: colors.borderLight,
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.water_drop_rounded,
                label: 'Drink',
                active: activeIndex == 0,
                onTap: () => onTap(0),
                colors: colors,
              ),
              _NavButton(
                icon: Icons.bar_chart_rounded,
                label: 'History',
                active: activeIndex == 1,
                onTap: () => onTap(1),
                colors: colors,
              ),
              _NavButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                active: activeIndex == 2,
                onTap: () => onTap(2),
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final HydroColors colors;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icon with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(10),
              transform: Matrix4.translationValues(
                  0, active ? -8 : 0, 0),
              decoration: BoxDecoration(
                color: active ? colors.navActiveBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 24,
                color: active ? colors.navActiveText : AppTheme.textLight,
              ),
            ),

            // Label (visible only when active)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              bottom: active ? 0 : -16,
              child: AnimatedOpacity(
                opacity: active ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: colors.navLabel,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
