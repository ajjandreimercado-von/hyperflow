import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/calculations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;
  late TextEditingController _glassController;
  late TextEditingController _weightController;
  late String _activity;
  late TimeOfDay _wakeTime;
  late TimeOfDay _sleepTime;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = context.read<AppProvider>().state.settings;
      _goalController =
          TextEditingController(text: settings.dailyGoalMl.toString());
      _glassController =
          TextEditingController(text: settings.glassSizeMl.toString());
      _weightController = TextEditingController(
          text: settings.weightKg?.toStringAsFixed(0) ?? '');
      _activity = settings.activityLevel?.name ?? 'moderate';
      _wakeTime = _parseTime(settings.wakeTime);
      _sleepTime = _parseTime(settings.sleepTime);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _glassController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleSave() {
    final provider = context.read<AppProvider>();
    provider.updateSettings(
      dailyGoalMl: int.tryParse(_goalController.text) ?? 2000,
      glassSizeMl: int.tryParse(_glassController.text) ?? 250,
      wakeTime: _formatTime(_wakeTime),
      sleepTime: _formatTime(_sleepTime),
      weightKg: double.tryParse(_weightController.text),
      activityLevel: ActivityLevel.values
          .firstWhere((e) => e.name == _activity),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved!',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.colorsFor(provider.state.settings.theme).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleAutoCalc() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter weight first',
              style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final computed = calculateDailyGoal(weight, _activity);
    setState(() {
      _goalController.text = computed.toString();
    });
  }

  Future<void> _pickTime(bool isWake) async {
    final initial = isWake ? _wakeTime : _sleepTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isWake) {
          _wakeTime = picked;
        } else {
          _sleepTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final theme = provider.state.settings.theme;
        final colors = AppTheme.colorsFor(theme);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 16, left: 24, right: 24, bottom: 140),
          child: Column(
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Daily Target Section
              _buildCard(
                children: [
                  _buildSectionTitle('DAILY TARGET', colors),
                  const SizedBox(height: 20),

                  _buildLabel('DAILY GOAL (ML)'),
                  const SizedBox(height: 8),
                  _buildTextField(_goalController, colors),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel('WEIGHT (KG)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                                _weightController, colors),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ACTIVITY'),
                            const SizedBox(height: 8),
                            _buildDropdown(colors),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Auto Calculate Button
                  _PressableWidget(
                    onTap: _handleAutoCalc,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      decoration: BoxDecoration(
                        color: colors.borderLight,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colors.borderLight,
                            blurRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'AUTO-CALCULATE GOAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primaryDark,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preferences Section
              _buildCard(
                children: [
                  _buildSectionTitle('PREFERENCES', colors),
                  const SizedBox(height: 20),

                  _buildLabel('GLASS SIZE (ML)'),
                  const SizedBox(height: 8),
                  _buildTextField(_glassController, colors),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel('WAKE TIME'),
                            const SizedBox(height: 8),
                            _buildTimePicker(
                              time: _wakeTime,
                              onTap: () => _pickTime(true),
                              colors: colors,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel('SLEEP TIME'),
                            const SizedBox(height: 8),
                            _buildTimePicker(
                              time: _sleepTime,
                              onTap: () => _pickTime(false),
                              colors: colors,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Interval display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.cardBorder, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOUR CALCULATED REMINDER INTERVAL IS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.state.settings.intervalMinutes} minutes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Button
              _PressableWidget(
                onTap: _handleSave,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.btnGradientTop,
                        colors.btnGradientBottom,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colors.btnShadow,
                        blurRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: colors.primary.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Reset Button
              _PressableWidget(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      title: const Text('Erase All Data',
                          style: TextStyle(
                              fontWeight: FontWeight.w900)),
                      content: const Text(
                          'Are you sure you want to reset all your data?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: AppTheme.textMuted)),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.resetData();
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Erase',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppTheme.cardBorder, width: 2),
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
                      'ERASE ALL DATA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        boxShadow: [
          const BoxShadow(
            color: Color(0xFFE2E8F0),
            blurRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title, HydroColors colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.primary,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, HydroColors colors) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.inputBg,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: colors.primaryLight, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown(HydroColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activity,
          isExpanded: true,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
            fontSize: 14,
          ),
          items: ['low', 'moderate', 'high']
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v[0].toUpperCase() + v.substring(1)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _activity = v);
          },
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required TimeOfDay time,
    required VoidCallback onTap,
    required HydroColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Text(
          _formatTime(time),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableWidget({required this.child, required this.onTap});

  @override
  State<_PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<_PressableWidget> {
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
