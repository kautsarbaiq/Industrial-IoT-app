import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/section_header.dart';

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    title: 'Energy Monitoring',
                    subtitle: 'Live power draw, consumption & cost'),
                const SizedBox(height: 20),
                _kpis(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Plant load (kW) by hour'),
                _powerTrend(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Power draw by line'),
                _byLine(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Top consumers (kW)'),
                _consumers(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kpis(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: KpiTile(
            icon: Icons.bolt_rounded,
            color: AppColors.amber,
            value: '${MockDataService.totalPowerNow.toStringAsFixed(0)} kW',
            label: 'Live plant load',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            icon: Icons.battery_charging_full_rounded,
            color: AppColors.cyan,
            value: '${(MockDataService.energyTodayKwh / 1000).toStringAsFixed(2)}k',
            label: 'kWh today',
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: KpiTile(
            icon: Icons.payments_rounded,
            color: AppColors.green,
            value: 'RM ${MockDataService.costTodayRM.toStringAsFixed(0)}',
            label: 'Energy cost today',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            icon: Icons.eco_rounded,
            color: AppColors.purple,
            value: MockDataService.energyIntensity.toStringAsFixed(1),
            label: 'kWh / 1k units',
          ),
        ),
      ]),
    ]);
  }

  Widget _powerTrend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final data = MockDataService.hourlyPower;
    return GlassCard(
      child: SizedBox(
        height: 190,
        child: LineChart(
          LineChartData(
            minY: 60,
            maxY: 180,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 30,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.grid(isDark), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 30,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
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
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: MockDataService.peakDemandKw,
                color: AppColors.red,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: GoogleFonts.poppins(
                      color: AppColors.red,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) =>
                      'peak ${MockDataService.peakDemandKw.toStringAsFixed(0)}kW',
                ),
              ),
            ]),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < data.length; i++)
                    FlSpot(i.toDouble(), data[i]),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.brand,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.brand.withOpacity(0.14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _byLine(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final byLine = MockDataService.powerByLine;
    final entries = byLine.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxV = entries.first.value;
    final colors = [AppColors.brand, AppColors.brand, AppColors.brand];
    return GlassCard(
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                SizedBox(
                  width: 96,
                  child: Text(entries[i].key.split(' · ').first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: entries[i].value / maxV),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 16,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.slate800
                                : AppColors.slate100,
                        valueColor:
                            AlwaysStoppedAnimation(colors[i % colors.length]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  child: Text('${entries[i].value.toStringAsFixed(1)}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          color: onSurface,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _consumers(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final machines = MockDataService.machinesByPower.take(5).toList();
    return GlassCard(
      child: Column(
        children: [
          for (int i = 0; i < machines.length; i++) ...[
            Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.amber.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: GoogleFonts.poppins(
                          color: AppColors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(machines[i].name,
                        style: GoogleFonts.poppins(
                            color: onSurface,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600)),
                    Text(machines[i].code,
                        style:
                            GoogleFonts.poppins(color: onVar, fontSize: 11)),
                  ],
                ),
              ),
              Text('${machines[i].power.toStringAsFixed(1)} kW',
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700)),
            ]),
            if (i < machines.length - 1)
              Divider(color: onVar.withOpacity(0.12), height: 20),
          ],
        ],
      ),
    );
  }
}
