import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/production_order.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

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
                    title: 'Production & OEE',
                    subtitle: 'Live orders, OEE breakdown & losses'),
                const SizedBox(height: 20),
                _oeeFormula(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'OEE by hour'),
                _hourlyOee(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Production orders'),
                ...MockDataService.orders.map((o) => _orderCard(context, o)),
                const SizedBox(height: 12),
                const SectionHeader(title: 'Downtime Pareto (min)'),
                _downtimePareto(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Quality — defect breakdown'),
                _defectBreakdown(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _oeeFormula(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final a = MockDataService.plantAvailability;
    final p = MockDataService.plantPerformance;
    final q = MockDataService.plantQuality;
    final oee = MockDataService.plantOee;
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _factorPill(context, 'Availability', a, AppColors.cyan),
              _op(context, '×'),
              _factorPill(context, 'Performance', p, AppColors.purple),
              _op(context, '×'),
              _factorPill(context, 'Quality', q, AppColors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: onVar.withOpacity(0.15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('OEE = ',
                  style: GoogleFonts.poppins(
                      color: onVar,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple]).createShader(b),
                child: Text('${oee.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('World-class benchmark: 85%',
              style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _factorPill(
      BuildContext context, String label, double value, Color color) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(children: [
      Text('${value.toStringAsFixed(0)}%',
          style: GoogleFonts.poppins(
              color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 10.5)),
    ]);
  }

  Widget _op(BuildContext context, String s) => Text(s,
      style: GoogleFonts.poppins(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 18,
          fontWeight: FontWeight.w400));

  Widget _hourlyOee(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final data = MockDataService.hourlyOee;
    return GlassCard(
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 60,
            maxY: 100,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.grid(isDark), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 10,
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

  Widget _orderCard(BuildContext context, ProductionOrder o) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = orderStatusColor(o.status);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${o.orderNo} · ${o.product}',
                      style: GoogleFonts.poppins(
                          color: onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(o.line,
                      style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(label: o.status.label, color: color, dot: false),
          ]),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${o.producedQty} / ${o.targetQty} units',
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500)),
              Text('${(o.progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: o.progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.slate800
                  : AppColors.slate100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (o.producedQty > 0) ...[
            const SizedBox(height: 10),
            Row(children: [
              _miniMetric(context, 'Good', '${o.goodQty}', AppColors.green),
              const SizedBox(width: 20),
              _miniMetric(context, 'Reject', '${o.rejectQty}', AppColors.red),
              const SizedBox(width: 20),
              _miniMetric(context, 'Yield',
                  '${o.yieldPct.toStringAsFixed(1)}%', AppColors.cyan),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _miniMetric(
      BuildContext context, String label, String value, Color color) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text('$label ',
          style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
      Text(value,
          style: GoogleFonts.poppins(
              color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _downtimePareto(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final reasons = MockDataService.downtimeReasons;
    final maxV = reasons.first.minutes.toDouble();
    return GlassCard(
      child: Column(
        children: [
          for (final r in reasons)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                SizedBox(
                  width: 118,
                  child: Text(r.reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          GoogleFonts.poppins(color: onVar, fontSize: 12)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: r.minutes / maxV),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 16,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? AppColors.slate800
                                : AppColors.slate100,
                        valueColor: AlwaysStoppedAnimation(
                          Color.lerp(AppColors.amber, AppColors.red,
                              r.minutes / maxV)!,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 34,
                  child: Text('${r.minutes}',
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

  Widget _defectBreakdown(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final defects = MockDataService.defectCategories;
    final total = defects.fold<int>(0, (a, b) => a + b.count);
    final colors = [
      AppColors.cyan,
      AppColors.purple,
      AppColors.amber,
      AppColors.red,
      AppColors.blue,
    ];
    return GlassCard(
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(alignment: Alignment.center, children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 34,
                  sections: [
                    for (int i = 0; i < defects.length; i++)
                      PieChartSectionData(
                        value: defects[i].count.toDouble(),
                        color: colors[i % colors.length],
                        radius: 22,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total',
                    style: GoogleFonts.poppins(
                        color: onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                Text('defects',
                    style: GoogleFonts.poppins(color: onVar, fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < defects.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[i % colors.length])),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(defects[i].name,
                            style: GoogleFonts.poppins(
                                color: onVar, fontSize: 12)),
                      ),
                      Text('${defects[i].count}',
                          style: GoogleFonts.poppins(
                              color: onSurface,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
