import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/app_state.dart';
import '../utils/calculations.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 1;
  String _weight = '';
  String _activity = '';
  String _glass = '250';

  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    final provider = context.read<AppProvider>();
    final weightNum =
        _weight.isNotEmpty ? double.tryParse(_weight) : null;
    final act = _activity.isNotEmpty ? _activity : null;
    final computedGoal = calculateDailyGoal(weightNum, act);

    provider.updateSettings(
      weightKg: weightNum,
      activityLevel: act != null
          ? ActivityLevel.values.firstWhere((e) => e.name == act)
          : null,
      glassSizeMl: int.tryParse(_glass) ?? 250,
      dailyGoalMl: computedGoal,
    );

    provider.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: child,
                        ),
                      );
                    },
                    child: Transform.rotate(
                      angle: 0.05,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF38BDF8),
                              Color(0xFF7DD3FC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                              color: Colors.white, width: 2),
                          boxShadow: [
                            const BoxShadow(
                              color: Color(0xFF0284C7),
                              blurRadius: 0,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0EA5E9)
                                  .withValues(alpha: 0.5),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to\n',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        TextSpan(
                          text: 'HydroFlow',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0EA5E9),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "LET'S SET UP YOUR PROFILE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Steps
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                            opacity: animation, child: child),
                      );
                    },
                    child: _step == 1 ? _buildStep1() : _buildStep2(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      children: [
        // Weight input
        _buildLabel('BODY WEIGHT (KG, OPTIONAL)'),
        const SizedBox(height: 8),
        _buildInput(
          hint: 'e.g. 70',
          value: _weight,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() => _weight = v),
        ),

        const SizedBox(height: 24),

        // Activity Level
        _buildLabel('ACTIVITY LEVEL'),
        const SizedBox(height: 12),
        Row(
          children: ['low', 'moderate', 'high'].map((lvl) {
            final selected = _activity == lvl;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    left: lvl == 'low' ? 0 : 6,
                    right: lvl == 'high' ? 0 : 6),
                child: _buildSelectButton(
                  label: lvl.toUpperCase(),
                  selected: selected,
                  onTap: () => setState(() => _activity = lvl),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        // Continue
        _buildPrimaryButton(
          label: 'CONTINUE',
          onTap: () => setState(() => _step = 2),
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          label: 'SKIP (USE DEFAULT 2000ML)',
          onTap: () {
            setState(() {
              _weight = '';
              _activity = '';
              _step = 2;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey('step2'),
      children: [
        _buildLabel('TYPICAL GLASS SIZE'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [150, 250, 350, 500].map((size) {
            final selected = _glass == size.toString();
            final labels = {
              150: 'Small cup',
              250: 'Standard glass',
              350: 'Mug',
              500: 'Bottle',
            };
            return _buildGlassOption(
              size: size,
              label: labels[size]!,
              selected: selected,
              onTap: () => setState(() => _glass = size.toString()),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),

        _buildPrimaryButton(
          label: 'START HYDRATING',
          onTap: _handleComplete,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          label: 'BACK',
          onTap: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String hint,
    required String value,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textLight,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppTheme.cardBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF38BDF8), width: 2),
        ),
      ),
    );
  }

  Widget _buildSelectButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        transform: Matrix4.translationValues(0, selected ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2FE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF7DD3FC)
                : AppTheme.cardBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF7DD3FC)
                  : AppTheme.cardShadow,
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: selected
                  ? const Color(0xFF0284C7)
                  : AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassOption({
    required int size,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, selected ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2FE) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? const Color(0xFF7DD3FC)
                : AppTheme.cardBorder,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF7DD3FC)
                  : AppTheme.cardShadow,
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$size ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? const Color(0xFF0284C7)
                          : AppTheme.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'ml',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF0284C7)
                              .withValues(alpha: 0.7)
                          : AppTheme.textPrimary
                              .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: selected
                    ? const Color(0xFF0284C7).withValues(alpha: 0.8)
                    : AppTheme.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return _PressableButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF0284C7),
              blurRadius: 0,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x4D0EA5E9),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return _PressableButton(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE2E8F0),
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
        child: widget.child,
      ),
    );
  }
}
