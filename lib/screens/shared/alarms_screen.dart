import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/alarm.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  // Locally-acknowledged ids layered over the mock data (front-end demo).
  final Set<String> _acked = {};
  int _tab = 0; // 0 = active, 1 = all

  bool _isAcked(Alarm a) => a.acknowledged || _acked.contains(a.id);

  @override
  Widget build(BuildContext context) {
    final all = MockDataService.alarms;
    final active = all.where((a) => !_isAcked(a)).toList();
    final list = _tab == 0 ? active : all;

    final crit = active.where((a) => a.severity == AlarmSeverity.critical).length;
    final warn = active.where((a) => a.severity == AlarmSeverity.warning).length;
    final info = active.where((a) => a.severity == AlarmSeverity.info).length;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTitle(
                title: 'Alarms & Events',
                subtitle: '${active.length} active · ${all.length} total'),
            const SizedBox(height: 16),
            Row(children: [
              _summary(context, 'Critical', crit, AppColors.red),
              const SizedBox(width: 10),
              _summary(context, 'Warning', warn, AppColors.amber),
              const SizedBox(width: 10),
              _summary(context, 'Info', info, AppColors.cyan),
            ]),
            const SizedBox(height: 16),
            _tabs(context),
            const SizedBox(height: 8),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.green, size: 48),
                    const SizedBox(height: 12),
                    Text('All clear — no active alarms',
                        style: GoogleFonts.poppins(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 14)),
                  ]),
                ),
              )
            else
              ...list.map((a) => _alarmCard(context, a)),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, String label, int count, Color color) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(children: [
          Text('$count',
              style: GoogleFonts.poppins(
                  color: color, fontSize: 26, fontWeight: FontWeight.w800)),
          Text(label,
              style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final labels = ['Active', 'All'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900.withOpacity(0.5) : AppColors.slate100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.slate200),
      ),
      child: Row(children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: _tab == i
                      ? const LinearGradient(
                          colors: [AppColors.cyan, AppColors.purple])
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: _tab == i
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _alarmCard(BuildContext context, Alarm a) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = alarmSeverityColor(a.severity);
    final acked = _isAcked(a);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                a.severity == AlarmSeverity.critical
                    ? Icons.error_rounded
                    : a.severity == AlarmSeverity.warning
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.machineName,
                      style: GoogleFonts.poppins(
                          color: onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(a.line,
                      style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
                ],
              ),
            ),
            StatusBadge(label: a.severity.label, color: color, dot: false),
          ]),
          const SizedBox(height: 10),
          Text(a.message,
              style: GoogleFonts.poppins(color: onSurface, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.schedule_rounded, color: onVar, size: 14),
            const SizedBox(width: 4),
            Text(DateFormat('d MMM · HH:mm').format(a.timestamp),
                style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
            const Spacer(),
            if (acked)
              Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 16),
                const SizedBox(width: 4),
                Text('Acknowledged',
                    style: GoogleFonts.poppins(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ])
            else
              GestureDetector(
                onTap: () => setState(() => _acked.add(a.id)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text('Acknowledge',
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}
