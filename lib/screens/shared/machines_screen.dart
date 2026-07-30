import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/machine.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/machine_status_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/glass_page.dart';
import 'machine_detail_screen.dart';

/// Machine list. When [lineFilter] is set (operator view) only that line's
/// assets are shown and the screen owns its own scaffold/back button.
class MachinesScreen extends StatefulWidget {
  final String? lineFilter;
  const MachinesScreen({super.key, this.lineFilter});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  MachineStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;

    var machines = widget.lineFilter == null
        ? MockDataService.machines
        : MockDataService.machinesForLine(widget.lineFilter!);
    if (_filter != null) {
      machines = machines.where((m) => m.status == _filter).toList();
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenTitle(
              title: 'Machines',
              subtitle: widget.lineFilter ??
                  '${MockDataService.totalMachines} assets · ${MockDataService.runningMachines} running',
            ),
            const SizedBox(height: 16),
            _filterChips(context),
            const SizedBox(height: 12),
            if (machines.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text('No machines match this filter',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 14)),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children:
                      AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (w) => SlideAnimation(
                        verticalOffset: 30, child: FadeInAnimation(child: w)),
                    children: [
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
          ],
        ),
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    final chips = <MachineStatus?>[
      null,
      MachineStatus.running,
      MachineStatus.idle,
      MachineStatus.down,
      MachineStatus.maintenance,
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = chips[i];
          final selected = _filter == s;
          final color = s == null ? AppColors.cyan : machineStatusColor(s);
          final label = s == null ? 'All' : s.label;
          return GestureDetector(
            onTap: () => setState(() => _filter = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? color.withOpacity(0.5)
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Center(
                child: Text(label,
                    style: GoogleFonts.poppins(
                        color: selected
                            ? color
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12.5,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500)),
              ),
            ),
          );
        },
      ),
    );
  }
}
