import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/machine.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/glass_page.dart';
import 'machine_detail_screen.dart';

/// Schematic shop-floor layout: each production line is a lane, machines are
/// status-coloured nodes on a conveyor. Tap a node to open its detail.
class FloorPlanScreen extends StatelessWidget {
  const FloorPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lines = MockDataService.lines;
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTitle(
                title: 'Floor Plan',
                subtitle: 'Live shop-floor layout by line'),
            const SizedBox(height: 16),
            _legend(context),
            const SizedBox(height: 16),
            for (final l in lines) _lane(context, l.name),
          ],
        ),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    Widget dot(MachineStatus s) {
      final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: machineStatusColor(s)),
        ),
        const SizedBox(width: 5),
        Text(s.label, style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
      ]);
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          dot(MachineStatus.running),
          dot(MachineStatus.idle),
          dot(MachineStatus.down),
          dot(MachineStatus.maintenance),
        ],
      ),
    );
  }

  Widget _lane(BuildContext context, String line) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final machines = MockDataService.machinesForLine(line);
    final running =
        machines.where((m) => m.status == MachineStatus.running).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 6,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(line,
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
            ),
            Text('$running/${machines.length} run',
                style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
          ]),
          const SizedBox(height: 18),
          SizedBox(
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // conveyor line
                Positioned(
                  left: 8,
                  right: 8,
                  top: 27,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate700 : AppColors.slate200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [for (final m in machines) _node(context, m)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _node(BuildContext context, Machine m) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = machineStatusColor(m.status);
    final bg = Theme.of(context).brightness == Brightness.dark
        ? AppColors.slate900
        : Colors.white;
    return GestureDetector(
      onTap: () =>
          openGlassPage(context, m.name, MachineDetailScreen(machineId: m.id)),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(_iconFor(m.type), color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(m.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600)),
            Text(
                m.status == MachineStatus.running
                    ? '${m.oee.toStringAsFixed(0)}%'
                    : m.status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(color: onVar, fontSize: 9.5)),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    final t = type.toLowerCase();
    if (t.contains('robot') || t.contains('arm')) {
      return Icons.precision_manufacturing_rounded;
    }
    if (t.contains('cnc') || t.contains('machining')) return Icons.settings_rounded;
    if (t.contains('press')) return Icons.compress_rounded;
    if (t.contains('vision') || t.contains('inspection')) {
      return Icons.center_focus_strong_rounded;
    }
    if (t.contains('mould') || t.contains('mold') || t.contains('injection')) {
      return Icons.iron_rounded;
    }
    if (t.contains('dryer') || t.contains('feeder')) return Icons.air_rounded;
    if (t.contains('fill')) return Icons.local_drink_rounded;
    if (t.contains('label')) return Icons.label_rounded;
    if (t.contains('pallet')) return Icons.inventory_2_rounded;
    return Icons.memory_rounded;
  }
}
