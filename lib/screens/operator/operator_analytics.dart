import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/oee_gauge.dart';
import '../../widgets/section_header.dart';

class OperatorAnalytics extends StatelessWidget {
  const OperatorAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final line = MockDataService.lines[1];
    final machines = MockDataService.operatorMachines;
    final rejects = 54;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 450),
              childAnimationBuilder: (w) => SlideAnimation(
                  verticalOffset: 40, child: FadeInAnimation(child: w)),
              children: [
                const ScreenTitle(
                    title: 'My Shift',
                    subtitle: 'Line 2 · Injection Molding performance'),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: KpiTile(
                      icon: Icons.inventory_2_rounded,
                      color: AppColors.cyan,
                      value: '${line.output}',
                      label: 'Units this shift',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KpiTile(
                      icon: Icons.cancel_rounded,
                      color: AppColors.red,
                      value: '$rejects',
                      label: 'Rejects',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(children: [
                    Text('Line OEE',
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    OeeGauge(value: line.oee, size: 150),
                    const SizedBox(height: 8),
                    Text('${line.runningCount} of ${line.machineCount} machines running',
                        style: GoogleFonts.poppins(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Machine OEE comparison'),
                _machineBars(context, machines),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Output by hour'),
                _outputLine(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _machineBars(BuildContext context, List machines) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassCard(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.grid(isDark), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 25,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 9)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= machines.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(machines[i].code,
                          style: GoogleFonts.poppins(
                              color: onVar, fontSize: 9.5)),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: [
              for (int i = 0; i < machines.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: machines[i].oee,
                    width: 26,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: machines[i].oee >= 65
                          ? [AppColors.cyan, AppColors.purple]
                          : [AppColors.amber, AppColors.red],
                    ),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outputLine(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    // Operator's line contributes ~1/3 of plant output.
    final data =
        MockDataService.hourlyOutput.map((e) => e * 0.33).toList();
    return GlassCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.grid(isDark), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                      style: GoogleFonts.poppins(color: onVar, fontSize: 9)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (v, _) => Text('${v.toInt() + 1}h',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 9)),
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < data.length; i++)
                    FlSpot(i.toDouble(), data[i]),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                gradient: const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple]),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.cyan.withOpacity(0.18),
                      AppColors.cyan.withOpacity(0.0)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
