import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class WaveProgress extends StatefulWidget {
  final double percentage; // 0.0 to 1.0
  final bool isEmpty;
  final ThemeType beverageType;

  const WaveProgress({
    super.key,
    required this.percentage,
    this.isEmpty = false,
    this.beverageType = ThemeType.water,
  });

  @override
  State<WaveProgress> createState() => _WaveProgressState();
}

class _WaveProgressState extends State<WaveProgress>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _floatController;
  late AnimationController _waterLevelController;
  late Animation<double> _waterLevelAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _waterLevelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _waterLevelAnimation = Tween<double>(
      begin: 0,
      end: widget.percentage.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _waterLevelController,
      curve: Curves.elasticOut,
    ));

    _waterLevelController.forward();
  }

  @override
  void didUpdateWidget(WaveProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _waterLevelAnimation = Tween<double>(
        begin: _waterLevelAnimation.value,
        end: widget.percentage.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _waterLevelController,
        curve: Curves.elasticOut,
      ));
      _waterLevelController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _floatController.dispose();
    _waterLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsFor(widget.beverageType);

    return SizedBox(
      width: 192,
      height: 256,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Shadow below the cup
          Positioned(
            bottom: -12,
            child: Container(
              width: 128,
              height: 20,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // The Glass Cup
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.15),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // The Liquid with wave animation
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_waveController, _waterLevelAnimation]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(192, 256),
                        painter: _LiquidPainter(
                          waterLevel: _waterLevelAnimation.value,
                          wavePhase: _waveController.value * 2 * pi,
                          isEmpty: widget.isEmpty,
                          liquidTop: widget.isEmpty
                              ? const Color(0xFFE2E8F0)
                              : colors.liquidTop,
                          liquidBottom: widget.isEmpty
                              ? const Color(0xFFCBD5E1)
                              : colors.liquidBottom,
                          waveColor: widget.isEmpty
                              ? Colors.white.withValues(alpha: 0.6)
                              : colors.waveOverlay.withValues(alpha: 0.6),
                        ),
                      );
                    },
                  ),

                  // Inner glass highlights
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Container(
                      width: 16,
                      height: 192,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 8,
                      height: 128,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  // Cute Face (visible when water > 30%)
                  AnimatedBuilder(
                    animation: _waterLevelAnimation,
                    builder: (context, child) {
                      final show = _waterLevelAnimation.value > 0.3;
                      return AnimatedOpacity(
                        opacity: show ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: child,
                      );
                    },
                    child: Positioned.fill(
                      child: Align(
                        alignment: const Alignment(0, 0.4),
                        child: _CuteFace(),
                      ),
                    ),
                  ),

                  // Bubbles
                  AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final offset = _floatController.value * 15;
                      return Stack(
                        children: [
                          Positioned(
                            bottom: 16 + offset,
                            left: 24,
                            child: _Bubble(
                                size: 12,
                                opacity: 0.4 *
                                    _waterLevelAnimation.value.clamp(0, 1)),
                          ),
                          Positioned(
                            bottom: 48 + offset * 0.7,
                            right: 32,
                            child: _Bubble(
                                size: 8,
                                opacity: 0.4 *
                                    _waterLevelAnimation.value.clamp(0, 1)),
                          ),
                          Positioned(
                            bottom: 80 + offset * 0.5,
                            left: 40,
                            child: _Bubble(
                                size: 6,
                                opacity: 0.3 *
                                    _waterLevelAnimation.value.clamp(0, 1)),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Decorative splash drops
          _SplashDrop(
            top: -24,
            right: -32,
            size: 40,
            color: colors.splash1,
            floatController: _floatController,
            rotation: 0.785, // 45 deg
          ),
          _SplashDrop(
            top: 80,
            left: -40,
            size: 24,
            color: colors.splash2,
            floatController: _floatController,
            rotation: -0.785,
            delayFactor: 0.3,
          ),
          _SplashDrop(
            bottom: 16,
            right: -24,
            size: 24,
            color: colors.splash3,
            floatController: _floatController,
            rotation: 0.21,
            delayFactor: 0.6,
          ),
        ],
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double waterLevel;
  final double wavePhase;
  final bool isEmpty;
  final Color liquidTop;
  final Color liquidBottom;
  final Color waveColor;

  _LiquidPainter({
    required this.waterLevel,
    required this.wavePhase,
    required this.isEmpty,
    required this.liquidTop,
    required this.liquidBottom,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waterLevel <= 0) return;

    final liquidHeight = size.height * waterLevel;
    final top = size.height - liquidHeight;

    // Main liquid gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [liquidTop, liquidBottom],
      ).createShader(Rect.fromLTWH(0, top, size.width, liquidHeight));

    // Wave path
    final path = Path();
    path.moveTo(0, top);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          top + sin(wavePhase + x * 0.04) * 6 + sin(wavePhase * 1.3 + x * 0.06) * 3;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, liquidPaint);

    // Second wave (overlay)
    final wavePaint = Paint()..color = waveColor;

    final wavePath = Path();
    wavePath.moveTo(0, top + 4);

    for (double x = 0; x <= size.width; x += 1) {
      final y = top +
          4 +
          sin(wavePhase * 0.8 + x * 0.05 + 1) * 4 +
          sin(wavePhase * 1.5 + x * 0.03) * 2;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(_LiquidPainter oldDelegate) =>
      waterLevel != oldDelegate.waterLevel ||
      wavePhase != oldDelegate.wavePhase ||
      isEmpty != oldDelegate.isEmpty;
}

class _CuteFace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left cheek
        Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFF472B6).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        const SizedBox(width: 4),
        // Eyes + mouth
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Left eye (>)
                CustomPaint(
                  size: const Size(14, 14),
                  painter: _EyePainter(isLeft: true),
                ),
                const SizedBox(width: 12),
                // Right eye (<)
                CustomPaint(
                  size: const Size(14, 14),
                  painter: _EyePainter(isLeft: false),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Mouth (smile arc)
            CustomPaint(
              size: const Size(14, 10),
              painter: _MouthPainter(),
            ),
          ],
        ),
        const SizedBox(width: 4),
        // Right cheek
        Container(
          width: 14,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFFF472B6).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}

class _EyePainter extends CustomPainter {
  final bool isLeft;
  _EyePainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (isLeft) {
      // > shape
      path.moveTo(size.width * 0.3, size.height * 0.15);
      path.lineTo(size.width * 0.8, size.height * 0.5);
      path.lineTo(size.width * 0.3, size.height * 0.85);
    } else {
      // < shape
      path.moveTo(size.width * 0.7, size.height * 0.15);
      path.lineTo(size.width * 0.2, size.height * 0.5);
      path.lineTo(size.width * 0.7, size.height * 0.85);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.2,
      size.width * 0.85,
      size.height * 0.2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;

  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SplashDrop extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final AnimationController floatController;
  final double rotation;
  final double delayFactor;

  const _SplashDrop({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.floatController,
    this.rotation = 0,
    this.delayFactor = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatController,
      builder: (context, child) {
        final t = ((floatController.value + delayFactor) % 1.0);
        final offset = sin(t * pi) * 15;
        return Positioned(
          top: top != null ? top! - offset : null,
          bottom: bottom != null ? bottom! + offset : null,
          left: left,
          right: right,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.8),
                    color.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.5),
                  topRight: Radius.circular(size * 0.1),
                  bottomLeft: Radius.circular(size * 0.5),
                  bottomRight: Radius.circular(size * 0.5),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
