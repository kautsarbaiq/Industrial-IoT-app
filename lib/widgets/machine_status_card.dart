import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/machine.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'status_badge.dart';
import 'trend_sparkline.dart';

/// A machine summary card: status, current job, OEE + a mini trend.
class MachineStatusCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback? onTap;

  const MachineStatusCard({super.key, required this.machine, this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final color = machineStatusColor(machine.status);
    final running = machine.status == MachineStatus.running;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(machine.type), color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${machine.code} · ${machine.type}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: onVar, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: machine.status.label,
              color: color,
              pulse: running,
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.currentJob,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    running
                        ? '${machine.throughput}/${machine.targetThroughput} units·hr'
                        : 'Throughput paused',
                    style: GoogleFonts.poppins(color: onVar, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TrendSparkline(
                data: machine.oeeTrend,
                color: color == AppColors.offline ? AppColors.slate400 : color,
                height: 34,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  machine.status == MachineStatus.running
                      ? '${machine.oee.toStringAsFixed(0)}%'
                      : '—',
                  style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('OEE', style: GoogleFonts.poppins(color: onVar, fontSize: 10, letterSpacing: 1)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    final t = type.toLowerCase();
    if (t.contains('robot') || t.contains('arm')) return Icons.precision_manufacturing_rounded;
    if (t.contains('cnc') || t.contains('machining')) return Icons.settings_rounded;
    if (t.contains('press')) return Icons.compress_rounded;
    if (t.contains('vision') || t.contains('inspection')) return Icons.center_focus_strong_rounded;
    if (t.contains('mould') || t.contains('mold') || t.contains('injection')) return Icons.iron_rounded;
    if (t.contains('dryer') || t.contains('feeder')) return Icons.air_rounded;
    if (t.contains('fill')) return Icons.local_drink_rounded;
    if (t.contains('label')) return Icons.label_rounded;
    if (t.contains('pallet')) return Icons.inventory_2_rounded;
    return Icons.memory_rounded;
  }
}
