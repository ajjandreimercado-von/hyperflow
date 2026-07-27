import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final state = provider.state;
        final theme = state.settings.theme;
        final colors = AppTheme.colorsFor(theme);
        final goal = state.settings.dailyGoalMl;

        // Build last 7 days data
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final chartData = <_DayData>[];
        for (int i = 6; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          final dayStart = date.millisecondsSinceEpoch;
          final dayEnd = dayStart + 86400000;

          final dayLogs = state.logs
              .where((log) =>
                  log.timestampMs >= dayStart &&
                  log.timestampMs < dayEnd)
              .toList();
          final totalMl =
              dayLogs.fold<int>(0, (sum, log) => sum + log.amountMl);

          chartData.add(_DayData(
            label: i == 0 ? 'Today' : DateFormat('EEE').format(date),
            ml: totalMl,
            goalMet: totalMl >= goal,
          ));
        }

        final weeklyAvg =
            (chartData.fold<int>(0, (sum, d) => sum + d.ml) / 7).round();
        final goalsMet = chartData.where((d) => d.goalMet).length;

        // Calculate max Y for chart
        final maxMl = chartData
            .fold<int>(goal, (max, d) => d.ml > max ? d.ml : max);
        final maxY = (maxMl * 1.3).roundToDouble();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
              top: 16, left: 24, right: 24, bottom: 140),
          child: Column(
            children: [
              const Text(
                'Weekly Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Chart Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                      color: AppTheme.cardBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 0,
                      offset: const Offset(0, 8),
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
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAST 7 DAYS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$goal ',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ml/day',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bar Chart
                    SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.white,
                              tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              tooltipRoundedRadius: 16,
                              getTooltipItem: (group, groupIndex,
                                  rod, rodIndex) {
                                return BarTooltipItem(
                                  '${chartData[group.x].ml} ml',
                                  TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8),
                                    child: Text(
                                      '${value.toInt()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 ||
                                      idx >= chartData.length) {
                                    return const SizedBox();
                                  }
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8),
                                    child: Text(
                                      chartData[idx].label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: chartData
                              .asMap()
                              .entries
                              .map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.ml.toDouble(),
                                  color: entry.value.goalMet
                                      ? colors.barMet
                                      : colors.barUnmet,
                                  width: 28,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mini Stats
              Row(
                children: [
                  // Weekly Avg
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                            color: AppTheme.cardBorder, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFE2E8F0),
                            blurRadius: 0,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'WEEKLY AVG',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$weeklyAvg ',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                TextSpan(
                                  text: 'ml',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Goals Met
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.btnGradientTop,
                            colors.btnGradientBottom,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                            color: colors.primaryLight, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.btnShadow,
                            blurRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'GOALS MET',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$goalsMet ',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '/ 7',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayData {
  final String label;
  final int ml;
  final bool goalMet;

  const _DayData({
    required this.label,
    required this.ml,
    required this.goalMet,
  });
}
