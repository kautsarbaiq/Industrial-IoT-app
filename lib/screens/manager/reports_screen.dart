import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/shift_report.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/glass_page.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = MockDataService.shiftReports;
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
                    title: 'Reports',
                    subtitle: 'Shift & daily production summaries'),
                const SizedBox(height: 20),
                _typeRow(context),
                const SizedBox(height: 8),
                const SectionHeader(title: 'Recent shifts'),
                for (int i = 0; i < reports.length; i++)
                  _reportCard(context, reports[i], highlight: i == 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeRow(BuildContext context) {
    final types = [
      ('Shift', Icons.schedule_rounded, AppColors.cyan),
      ('Daily', Icons.today_rounded, AppColors.purple),
      ('Weekly', Icons.date_range_rounded, AppColors.amber),
      ('OEE', Icons.speed_rounded, AppColors.green),
    ];
    return Row(
      children: [
        for (final t in types)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GlassCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onTap: () => _snack(context, '${t.$1} report'),
                child: Column(children: [
                  Icon(t.$2, color: t.$3, size: 22),
                  const SizedBox(height: 6),
                  Text(t.$1,
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _reportCard(BuildContext context, ShiftReport r,
      {bool highlight = false}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    const color = AppColors.brand; // single flat light-blue (no OEE health bands)
    return GlassCard(
      onTap: () => openGlassPage(context, 'Shift Report', _ReportDetail(report: r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(r.shift,
                        style: GoogleFonts.poppins(
                            color: onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (highlight) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('CURRENT',
                            style: GoogleFonts.poppins(
                                color: AppColors.emeraldDark,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                      ),
                    ],
                  ]),
                  Text(
                      '${DateFormat('EEE, d MMM').format(r.date)} · ${r.supervisor}',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
                ],
              ),
            ),
            Column(children: [
              Text('${r.oee.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text('OEE',
                  style: GoogleFonts.poppins(
                      color: onVar, fontSize: 10, letterSpacing: 1)),
            ]),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _metric(context, 'Output', '${(r.output / 1000).toStringAsFixed(1)}k'),
            _metric(context, 'Attainment',
                '${r.attainment.toStringAsFixed(0)}%'),
            _metric(context, 'Downtime', '${r.downtimeMinutes}m'),
            _metric(context, 'Rejects', '${r.rejects}'),
          ]),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: GoogleFonts.poppins(
                color: onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 10.5)),
      ]),
    );
  }

  static void _snack(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate800,
        content: Text('$what — generating (demo)',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}

class _ReportDetail extends StatelessWidget {
  final ShiftReport report;
  const _ReportDetail({required this.report});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final r = report;
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                            colors: [AppColors.cyan, AppColors.purple]),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(MockDataService.plantName,
                              style: GoogleFonts.poppins(
                                  color: onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              '${r.shift} · ${DateFormat('d MMM yyyy').format(r.date)}',
                              style: GoogleFonts.poppins(
                                  color: onVar, fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _kv(context, 'Line', r.line),
                  _kv(context, 'Supervisor', r.supervisor),
                  _kv(context, 'Output', '${r.output} units'),
                  _kv(context, 'Target', '${r.target} units'),
                  _kv(context, 'Attainment',
                      '${r.attainment.toStringAsFixed(1)}%'),
                  _kv(context, 'Downtime', '${r.downtimeMinutes} min'),
                  _kv(context, 'Rejects', '${r.rejects} units'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            GlassCard(
              child: Column(children: [
                Text('OEE Breakdown',
                    style: GoogleFonts.poppins(
                        color: onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _bar(context, 'Availability', r.availability, AppColors.cyan),
                const SizedBox(height: 12),
                _bar(context, 'Performance', r.performance, AppColors.purple),
                const SizedBox(height: 12),
                _bar(context, 'Quality', r.quality, AppColors.green),
                const SizedBox(height: 16),
                Divider(color: onVar.withOpacity(0.15)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall OEE',
                        style: GoogleFonts.poppins(
                            color: onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text('${r.oee.toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                            color: AppColors.cyan,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => ReportsScreen._snack(context, 'PDF export'),
                icon: const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.white, size: 20),
                label: Text('Export as PDF',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: GoogleFonts.poppins(color: onVar, fontSize: 13)),
          Text(v,
              style: GoogleFonts.poppins(
                  color: onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, String label, double value, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 12.5)),
          Text('${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                  color: onSurface, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 7,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.slate800
                : AppColors.slate100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
