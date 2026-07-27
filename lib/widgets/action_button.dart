import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? sublabel;
  final VoidCallback onTap;
  final bool active;
  final bool border;
  final ThemeType colorScheme;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.sublabel,
    this.active = false,
    this.border = false,
    this.colorScheme = ThemeType.water,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsFor(widget.colorScheme);

    // Determine button colors
    Color bgColor;
    Color textColor;
    Color borderColor;
    Color shadowColor;
    List<Color>? gradient;

    if (widget.border) {
      bgColor = Colors.white;
      textColor = colors.primary;
      borderColor = colors.primaryLight.withOpacity(0.4);
      shadowColor = colors.borderLight;
      gradient = null;
    } else if (widget.active) {
      bgColor = colors.primary;
      textColor = Colors.white;
      borderColor = colors.primaryLight;
      shadowColor = colors.btnShadow;
      gradient = [colors.btnGradientTop, colors.btnGradientBottom];
    } else {
      bgColor = Colors.white;
      textColor = AppTheme.textSecondary;
      borderColor = AppTheme.cardBorder;
      shadowColor = AppTheme.cardShadow;
      gradient = null;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: gradient == null ? bgColor : null,
          gradient: gradient != null
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            if (!_pressed)
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          children: [
            // 3D highlight for active
            if (widget.active)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 24,
                  color: widget.iconColor ??
                      (widget.active ? Colors.white : textColor),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    widget.sublabel!,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: widget.active
                          ? Colors.white.withOpacity(0.9)
                          : AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
