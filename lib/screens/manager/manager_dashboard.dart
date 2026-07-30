import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/machine.dart';
import '../../models/alarm.dart';
import '../../models/production_line.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/oee_gauge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/glass_page.dart';
import '../shared/alarms_screen.dart';
import '../shared/machines_screen.dart';
import '../shared/floor_plan_screen.dart';
import '../shared/energy_screen.dart';
import '../profile_screen.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

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
                verticalOffset: 40,
                child: FadeInAnimation(child: w),
              ),
              children: [
                _header(context),
                const SizedBox(height: 20),
                _oeeCard(context),
                const SizedBox(height: 16),
                _kpiGrid(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Monitoring'),
                _quickAccess(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Output vs Target (today)'),
                _outputChart(context),
                const SizedBox(height: 20),
                const SectionHeader(title: 'OEE — last 7 days'),
                _weeklyOeeChart(context),
                const SizedBox(height: 20),
                SectionHeader(
                    title: 'Lines',
                    action: 'View all',
                    onAction: () => openGlassPage(
                        context, 'Machines', const MachinesScreen())),
                ...MockDataService.lines.map((l) => _lineRow(context, l)),
                const SizedBox(height: 12),
                SectionHeader(
                  title: 'Active alarms',
                  action: 'See all',
                  onAction: () =>
                      openGlassPage(context, 'Alarms & Events', const AlarmsScreen()),
                ),
                ..._topAlarms(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plant Overview',
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 14, color: onVar),
                const SizedBox(width: 4),
                Text(MockDataService.plantName,
                    style: GoogleFonts.poppins(color: onVar, fontSize: 13)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('LIVE',
                      style: GoogleFonts.poppins(
                          color: AppColors.emeraldDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ),
              ]),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => openGlassPage(context, 'Settings', const ProfileScreen()),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [AppColors.cyan, AppColors.purple]),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _oeeCard(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OeeGauge(value: MockDataService.plantOee, size: 132),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _factorBar(context, 'Availability',
                        MockDataService.plantAvailability, AppColors.cyan),
                    const SizedBox(height: 14),
                    _factorBar(context, 'Performance',
                        MockDataService.plantPerformance, AppColors.purple),
                    const SizedBox(height: 14),
                    _factorBar(context, 'Quality',
                        MockDataService.plantQuality, AppColors.green),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: onVar.withOpacity(0.15)),
          const SizedBox(height: 4),
          Row(
            children: [
              _statusChip(context, MachineStatus.running,
                  MockDataService.runningMachines),
              _statusChip(
                  context,
                  MachineStatus.idle,
                  MockDataService.machines
                      .where((m) => m.status == MachineStatus.idle)
                      .length),
              _statusChip(
                  context,
                  MachineStatus.down,
                  MockDataService.machines
                      .where((m) => m.status == MachineStatus.down)
                      .length),
              _statusChip(
                  context,
                  MachineStatus.maintenance,
                  MockDataService.machines
                      .where((m) => m.status == MachineStatus.maintenance)
                      .length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _factorBar(
      BuildContext context, String label, double value, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
            Text('${value.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 7,
              backgroundColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.slate800
                      : AppColors.slate100,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, MachineStatus s, int count) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = machineStatusColor(s);
    return Expanded(
      child: Column(children: [
        Text('$count',
            style: GoogleFonts.poppins(
                color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(s.label,
            style: GoogleFonts.poppins(color: onVar, fontSize: 10.5)),
      ]),
    );
  }

  Widget _kpiGrid(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: KpiTile(
            icon: Icons.inventory_2_rounded,
            color: AppColors.cyan,
            value: '${(MockDataService.outputToday / 1000).toStringAsFixed(1)}k',
            label: 'Output today',
            delta: '+6.2%',
            deltaUp: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            icon: Icons.track_changes_rounded,
            color: AppColors.purple,
            value: '${MockDataService.outputAttainment.toStringAsFixed(0)}%',
            label: 'Target attainment',
            delta: '-3.1%',
            deltaUp: false,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: KpiTile(
            icon: Icons.notifications_active_rounded,
            color: AppColors.red,
            value: '${MockDataService.activeAlarms}',
            label: '${MockDataService.criticalAlarms} critical · active alarms',
            onTap: () => openGlassPage(
                context, 'Alarms & Events', const AlarmsScreen()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: KpiTile(
            icon: Icons.bolt_rounded,
            color: AppColors.amber,
            value: '${MockDataService.runningMachines}/${MockDataService.totalMachines}',
            label: 'Machines running',
            onTap: () =>
                openGlassPage(context, 'Machines', const MachinesScreen()),
          ),
        ),
      ]),
    ]);
  }

  Widget _quickAccess(BuildContext context) {
    Widget tile(IconData icon, String title, String sub, Color color, Widget page) {
      final onSurface = Theme.of(context).colorScheme.onSurface;
      final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
      return Expanded(
        child: GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(16),
          onTap: () => openGlassPage(context, title, page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text(sub, style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
            ],
          ),
        ),
      );
    }

    return Row(children: [
      tile(Icons.grid_view_rounded, 'Floor Plan', 'Live layout', AppColors.cyan,
          const FloorPlanScreen()),
      const SizedBox(width: 12),
      tile(Icons.bolt_rounded, 'Energy', 'Power & cost', AppColors.amber,
          const EnergyScreen()),
    ]);
  }

  Widget _outputChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final data = MockDataService.hourlyOutput;
    const target = 1000.0;
    final maxY = 1300.0;
    return GlassCard(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 300,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.grid(isDark), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 300,
                  getTitlesWidget: (v, _) => Text(
                      '${(v / 1000).toStringAsFixed(1)}k',
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
                y: target,
                color: AppColors.amber,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: GoogleFonts.poppins(
                      color: AppColors.amber,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => 'target',
                ),
              ),
            ]),
            barGroups: [
              for (int i = 0; i < data.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: data[i],
                    width: 9,
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: data[i] >= target
                          ? [AppColors.cyan, AppColors.purple]
                          : [
                              AppColors.amber.withOpacity(0.7),
                              AppColors.amber
                            ],
                    ),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weeklyOeeChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final data = MockDataService.weeklyOee;
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return GlassCard(
      child: SizedBox(
        height: 190,
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
                  reservedSize: 30,
                  interval: 10,
                  getTitlesWidget: (v, _) => Text('${v.toInt()}',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 9)),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => v.toInt() < days.length
                      ? Text(days[v.toInt()],
                          style:
                              GoogleFonts.poppins(color: onVar, fontSize: 10))
                      : const SizedBox(),
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: MockDataService.oeeTarget,
                color: AppColors.green,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: GoogleFonts.poppins(
                      color: AppColors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => 'target ${MockDataService.oeeTarget.toInt()}%',
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
                gradient: const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple]),
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                      radius: 3.5,
                      color: AppColors.purple,
                      strokeWidth: 0),
                ),
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

  Widget _lineRow(BuildContext context, ProductionLine l) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = l.oee >= 85
        ? AppColors.green
        : l.oee >= 65
            ? AppColors.amber
            : AppColors.red;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.name,
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${l.runningCount}/${l.machineCount} running · ${l.output} / ${l.target} units',
                  style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: l.attainment / 100,
                  minHeight: 6,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.slate800
                          : AppColors.slate100,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(children: [
          Text('${l.oee.toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
          Text('OEE',
              style: GoogleFonts.poppins(
                  color: onVar, fontSize: 10, letterSpacing: 1)),
        ]),
      ]),
    );
  }

  List<Widget> _topAlarms(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final alarms = MockDataService.alarms
        .where((a) => !a.acknowledged)
        .take(3)
        .toList();
    return alarms.map((a) {
      final color = alarmSeverityColor(a.severity);
      return GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: () => openGlassPage(context, 'Alarms & Events', const AlarmsScreen()),
        child: Row(children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.machineName,
                    style: GoogleFonts.poppins(
                        color: onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                Text(a.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(label: a.severity.label, color: color, dot: false),
        ]),
      );
    }).toList();
  }
}
