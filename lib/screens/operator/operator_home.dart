import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/machine_status_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/glass_page.dart';
import '../shared/machine_detail_screen.dart';
import '../profile_screen.dart';

class OperatorHome extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const OperatorHome({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final line = MockDataService.lines[1]; // Line 2 — operator's line
    final machines = MockDataService.operatorMachines;

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
                _header(context),
                const SizedBox(height: 20),
                _shiftCard(context, line.output, line.target, line.oee),
                const SizedBox(height: 16),
                _quickActions(context),
                const SizedBox(height: 12),
                SectionHeader(
                  title: 'My machines',
                  action: 'All',
                  onAction: () => onNavigate(1),
                ),
                for (final m in machines)
                  MachineStatusCard(
                    machine: m,
                    onTap: () => openGlassPage(
                        context, m.name, MachineDetailScreen(machineId: m.id)),
                  ),
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
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${MockDataService.operatorName.split(' ').first} 👋',
                style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.w700)),
            Text(MockDataService.operatorLine,
                style: GoogleFonts.poppins(color: onVar, fontSize: 13)),
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
            gradient:
                const LinearGradient(colors: [AppColors.cyan, AppColors.purple]),
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
        ),
      ),
    ]);
  }

  Widget _shiftCard(BuildContext context, int output, int target, double oee) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final progress = (output / target).clamp(0.0, 1.0);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current shift · A',
                  style: GoogleFonts.poppins(
                      color: onVar,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('OEE ${oee.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                        color: AppColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$output',
                style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1)),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('/ $target units',
                  style: GoogleFonts.poppins(color: onVar, fontSize: 14)),
            ),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.slate800
                        : AppColors.slate100,
                valueColor: AlwaysStoppedAnimation(
                    progress >= 0.75 ? AppColors.green : AppColors.amber),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toStringAsFixed(0)}% of shift target',
              style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      (
        Icons.add_chart_rounded,
        'Log Output',
        AppColors.cyan,
        () => onNavigate(2)
      ),
      (
        Icons.report_problem_rounded,
        'Log Downtime',
        AppColors.amber,
        () => onNavigate(2)
      ),
      (
        Icons.notifications_active_rounded,
        'Alerts',
        AppColors.red,
        () => onNavigate(3)
      ),
      (
        Icons.bar_chart_rounded,
        'My Shift',
        AppColors.purple,
        () => onNavigate(4)
      ),
    ];
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final a in actions)
            Expanded(
              child: GestureDetector(
                onTap: a.$4,
                behavior: HitTestBehavior.opaque,
                child: Column(children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: a.$3.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(a.$1, color: a.$3, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(a.$2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
