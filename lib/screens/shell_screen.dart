import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/role_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_page.dart';
import '../widgets/mesh_gradient_bg.dart';
import 'manager/manager_dashboard.dart';
import 'manager/production_screen.dart';
import 'manager/reports_screen.dart';
import 'operator/operator_home.dart';
import 'operator/log_production_screen.dart';
import 'operator/operator_analytics.dart';
import 'shared/machines_screen.dart';
import 'shared/alarms_screen.dart';
import 'shared/maintenance_screen.dart';
import 'shared/floor_plan_screen.dart';
import 'shared/energy_screen.dart';
import 'profile_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  AppRole? _prevRole;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(builder: (context, rp, _) {
      // Reset to first tab when the role changes.
      if (_prevRole != null && _prevRole != rp.role) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _index = 0);
        });
      }
      _prevRole = rp.role;

      final screens = rp.isManager
          ? <Widget>[
              const ManagerDashboard(),
              const MachinesScreen(),
              const ProductionScreen(),
              const ReportsScreen(),
              const _MoreScreen(),
            ]
          : <Widget>[
              OperatorHome(onNavigate: _go),
              const MachinesScreen(lineFilter: 'Line 2 · Injection Molding'),
              const LogProductionScreen(),
              const AlarmsScreen(),
              const OperatorAnalytics(),
            ];

      final items = rp.isManager
          ? const [
              NavDest(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
              NavDest(Icons.memory_outlined, Icons.memory_rounded, 'Machines'),
              NavDest(Icons.insights_outlined, Icons.insights_rounded, 'Production'),
              NavDest(Icons.description_outlined, Icons.description_rounded, 'Reports'),
              NavDest(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
            ]
          : const [
              NavDest(Icons.home_outlined, Icons.home_rounded, 'Home'),
              NavDest(Icons.memory_outlined, Icons.memory_rounded, 'Machines'),
              NavDest(Icons.add_chart_outlined, Icons.add_chart_rounded, 'Log'),
              NavDest(Icons.notifications_outlined, Icons.notifications_rounded, 'Alerts'),
              NavDest(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'My Shift'),
            ];

      final safeIndex = _index.clamp(0, screens.length - 1);

      return Scaffold(
        extendBody: true,
        body: MeshGradientBg(
          child: IndexedStack(index: safeIndex, children: screens),
        ),
        bottomNavigationBar:
            AppBottomNav(currentIndex: safeIndex, onTap: _go, items: items),
      );
    });
  }
}

/// Manager "More" hub → Alarms, Maintenance, Settings.
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More',
                style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            Text('Alarms, maintenance & settings',
                style: GoogleFonts.poppins(color: onVar, fontSize: 14)),
            const SizedBox(height: 24),
            _tile(context, Icons.grid_view_rounded, 'Floor Plan',
                'Live shop-floor layout by line', AppColors.cyan,
                const FloorPlanScreen()),
            _tile(context, Icons.bolt_rounded, 'Energy Monitoring',
                'Power draw, kWh & cost', AppColors.amber,
                const EnergyScreen()),
            _tile(context, Icons.notifications_active_rounded, 'Alarms & Events',
                'Live faults, warnings and notices', AppColors.red,
                const AlarmsScreen()),
            _tile(context, Icons.build_rounded, 'Maintenance',
                'Preventive & corrective schedule', AppColors.blue,
                const MaintenanceScreen()),
            _tile(context, Icons.settings_rounded, 'Settings',
                'Role, theme & account', AppColors.purple,
                const ProfileScreen()),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String sub,
      Color color, Widget page) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => openGlassPage(context, title, page),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: onSurface,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600)),
                Text(sub,
                    style: GoogleFonts.poppins(color: onVar, fontSize: 12.5)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.slate500, size: 16),
        ]),
      ),
    );
  }
}
