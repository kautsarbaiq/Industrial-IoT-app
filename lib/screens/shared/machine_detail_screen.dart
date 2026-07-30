import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/machine.dart';
import '../../models/alarm.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/oee_gauge.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class MachineDetailScreen extends StatelessWidget {
  final String machineId;
  const MachineDetailScreen({super.key, required this.machineId});

  @override
  Widget build(BuildContext context) {
    final m = MockDataService.machineById(machineId);
    final color = machineStatusColor(m.status);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final running = m.status == MachineStatus.running;
    final alarms = MockDataService.alarms
        .where((a) => a.machineName == m.name)
        .toList();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${m.code} · ${m.type}',
                              style: GoogleFonts.poppins(
                                  color: onVar, fontSize: 12.5)),
                          const SizedBox(height: 2),
                          Text(m.line,
                              style: GoogleFonts.poppins(
                                  color: onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    StatusBadge(
                        label: m.status.label, color: color, pulse: running),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      Icon(Icons.assignment_outlined, color: color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(m.currentJob,
                            style: GoogleFonts.poppins(
                                color: onSurface,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // OEE + factors
            GlassCard(
              child: Row(children: [
                OeeGauge(
                    value: running ? m.oee : 0,
                    size: 120,
                    label: 'OEE'),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(children: [
                    _factor(context, 'Availability', m.availability, AppColors.cyan),
                    const SizedBox(height: 12),
                    _factor(context, 'Performance', m.performance, AppColors.purple),
                    const SizedBox(height: 12),
                    _factor(context, 'Quality', m.quality, AppColors.green),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Live telemetry'),
            _telemetryGrid(context, m),
            const SizedBox(height: 20),

            const SectionHeader(title: 'OEE trend (last 12 readings)'),
            _trendChart(context, m, color),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Maintenance'),
            _maintenanceCard(context, m),
            const SizedBox(height: 20),

            if (alarms.isNotEmpty) ...[
              const SectionHeader(title: 'Recent events'),
              ...alarms.map((a) => _alarmRow(context, a)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _factor(
      BuildContext context, String label, double value, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
          Text('${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                  color: onSurface, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.slate800
                : AppColors.slate100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _telemetryGrid(BuildContext context, Machine m) {
    final tiles = [
      _Tele('Temperature', '${m.temperature.toStringAsFixed(1)}°C',
          Icons.thermostat_rounded, AppColors.red),
      _Tele('Vibration', '${m.vibration.toStringAsFixed(1)} mm/s',
          Icons.vibration_rounded, AppColors.amber),
      _Tele('Speed', '${m.speed.toStringAsFixed(0)} rpm',
          Icons.speed_rounded, AppColors.cyan),
      _Tele('Power', '${m.power.toStringAsFixed(1)} kW',
          Icons.bolt_rounded, AppColors.purple),
      _Tele('Throughput', '${m.throughput}/hr', Icons.output_rounded,
          AppColors.green),
      _Tele('Uptime', '${m.uptimePct.toStringAsFixed(1)}%',
          Icons.timelapse_rounded, AppColors.blue),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: [for (final t in tiles) _teleTile(context, t)],
    );
  }

  Widget _teleTile(BuildContext context, _Tele t) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(t.icon, color: t.color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.value,
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              Text(t.label,
                  style: GoogleFonts.poppins(color: onVar, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendChart(BuildContext context, Machine m, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final data = m.oeeTrend;
    final safeColor = color == AppColors.offline ? AppColors.slate400 : color;
    return GlassCard(
      child: SizedBox(
        height: 170,
        child: LineChart(
          LineChartData(
            minY: 0,
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
              bottomTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                color: safeColor,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      safeColor.withOpacity(0.2),
                      safeColor.withOpacity(0.0)
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

  Widget _maintenanceCard(BuildContext context, Machine m) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final fmt = DateFormat('d MMM yyyy');
    return GlassCard(
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last service',
                  style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
              const SizedBox(height: 2),
              Text(fmt.format(m.lastMaintenance),
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Container(width: 1, height: 34, color: onVar.withOpacity(0.2)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next due',
                  style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
              const SizedBox(height: 2),
              Text(fmt.format(m.nextMaintenance),
                  style: GoogleFonts.poppins(
                      color: AppColors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _alarmRow(BuildContext context, Alarm a) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = alarmSeverityColor(a.severity);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Icon(
          a.severity == AlarmSeverity.critical
              ? Icons.error_rounded
              : a.severity == AlarmSeverity.warning
                  ? Icons.warning_amber_rounded
                  : Icons.info_outline_rounded,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(a.message,
              style: GoogleFonts.poppins(color: onSurface, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        Text(DateFormat('HH:mm').format(a.timestamp),
            style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
      ]),
    );
  }
}

class _Tele {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Tele(this.label, this.value, this.icon, this.color);
}
