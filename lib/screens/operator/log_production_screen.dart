import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/mock_data_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_header.dart';

class LogProductionScreen extends StatefulWidget {
  const LogProductionScreen({super.key});

  @override
  State<LogProductionScreen> createState() => _LogProductionScreenState();
}

class _LogProductionScreenState extends State<LogProductionScreen> {
  late String _machine = MockDataService.operatorMachines.first.name;
  int _good = 120;
  int _reject = 3;
  String? _downtimeReason;
  int _downtimeMin = 0;

  final _reasons = const [
    'Changeover',
    'Material shortage',
    'Mechanical fault',
    'Quality hold',
    'No operator',
    'Cleaning',
  ];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final machines = MockDataService.operatorMachines;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenTitle(
                title: 'Log Production',
                subtitle: 'Record output & downtime for your line'),
            const SizedBox(height: 20),

            // Machine selector
            const SectionHeader(title: 'Machine'),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _machine,
                  isExpanded: true,
                  dropdownColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.slate800
                      : Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.cyan),
                  borderRadius: BorderRadius.circular(16),
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  items: [
                    for (final m in machines)
                      DropdownMenuItem(
                        value: m.name,
                        child: Text('${m.name}  ·  ${m.code}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _machine = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Output counters
            const SectionHeader(title: 'Output count'),
            Row(children: [
              Expanded(
                  child: _counter(context, 'Good units', _good, AppColors.green,
                      (v) => setState(() => _good = v))),
              const SizedBox(width: 12),
              Expanded(
                  child: _counter(context, 'Rejects', _reject, AppColors.red,
                      (v) => setState(() => _reject = v))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _quickAdd(context, '+10', () => setState(() => _good += 10)),
              const SizedBox(width: 8),
              _quickAdd(context, '+50', () => setState(() => _good += 50)),
              const SizedBox(width: 8),
              _quickAdd(context, '+100', () => setState(() => _good += 100)),
            ]),
            const SizedBox(height: 20),

            // Downtime
            const SectionHeader(title: 'Downtime (optional)'),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 12.5)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in _reasons)
                        _reasonChip(context, r),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('Duration',
                        style:
                            GoogleFonts.poppins(color: onVar, fontSize: 12.5)),
                    const Spacer(),
                    _stepper(context),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple]),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.cyan.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Center(
                    child: Text('Submit Log',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter(BuildContext context, String label, int value, Color color,
      ValueChanged<int> onChanged) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(label, style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _roundBtn(context, Icons.remove_rounded, color,
              () => onChanged(value > 0 ? value - 1 : 0)),
          Text('$value',
              style: GoogleFonts.poppins(
                  color: onSurface, fontSize: 24, fontWeight: FontWeight.w800)),
          _roundBtn(context, Icons.add_rounded, color, () => onChanged(value + 1)),
        ]),
      ]),
    );
  }

  Widget _roundBtn(
      BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _quickAdd(BuildContext context, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: AppColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _reasonChip(BuildContext context, String r) {
    final selected = _downtimeReason == r;
    return GestureDetector(
      onTap: () => setState(() => _downtimeReason = selected ? null : r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected
                  ? AppColors.amber.withOpacity(0.5)
                  : Theme.of(context).colorScheme.outline),
        ),
        child: Text(r,
            style: GoogleFonts.poppins(
                color: selected
                    ? AppColors.amber
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }

  Widget _stepper(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(children: [
      _roundBtn(context, Icons.remove_rounded, AppColors.amber,
          () => setState(() => _downtimeMin = _downtimeMin >= 5 ? _downtimeMin - 5 : 0)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('$_downtimeMin min',
            style: GoogleFonts.poppins(
                color: onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
      _roundBtn(context, Icons.add_rounded, AppColors.amber,
          () => setState(() => _downtimeMin += 5)),
    ]);
  }

  void _submit() {
    final parts = <String>['$_good good', '$_reject rejects'];
    if (_downtimeReason != null && _downtimeMin > 0) {
      parts.add('$_downtimeMin min · $_downtimeReason');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green,
        content: Text('Logged for $_machine — ${parts.join(', ')}',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}
