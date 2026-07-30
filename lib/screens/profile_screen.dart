import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/role_provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/role_switcher.dart';
import '../widgets/section_header.dart';
import '../services/mock_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    final rp = context.watch<RoleProvider>();
    final theme = context.watch<ThemeProvider>();

    final name =
        rp.isManager ? MockDataService.managerName : MockDataService.operatorName;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Row(children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple]),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.cyan.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.split(' ').map((e) => e[0]).take(2).join(),
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.poppins(
                              color: onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text(rp.roleLabel,
                          style: GoogleFonts.poppins(
                              color: AppColors.cyan,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(MockDataService.plantName,
                          style:
                              GoogleFonts.poppins(color: onVar, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            const SectionHeader(title: 'Active role'),
            const RoleSwitcher(),
            const SizedBox(height: 8),
            Text('Switch role to preview the operator or manager experience.',
                style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Appearance'),
            GlassCard(
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    theme.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.purple,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark mode',
                          style: GoogleFonts.poppins(
                              color: onSurface,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600)),
                      Text(theme.isDarkMode ? 'On' : 'Off',
                          style:
                              GoogleFonts.poppins(color: onVar, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: theme.isDarkMode,
                  activeColor: AppColors.cyan,
                  onChanged: (_) => theme.toggleTheme(),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'General'),
            _settingRow(context, Icons.notifications_outlined, 'Notifications',
                'Alarm & threshold alerts', AppColors.amber),
            _settingRow(context, Icons.language_rounded, 'Language',
                'English (MY)', AppColors.blue),
            _settingRow(context, Icons.cloud_sync_outlined, 'Data source',
                'Demo · mock data', AppColors.green),
            _settingRow(context, Icons.info_outline_rounded, 'About',
                'Industrial IoT v1.0.0', AppColors.cyan),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (r) => false),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.red, size: 20),
                label: Text('Sign out',
                    style: GoogleFonts.poppins(
                        color: AppColors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.red.withOpacity(0.4)),
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

  Widget _settingRow(BuildContext context, IconData icon, String title,
      String sub, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () {},
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      color: onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
              Text(sub, style: GoogleFonts.poppins(color: onVar, fontSize: 12)),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: AppColors.slate500, size: 15),
      ]),
    );
  }
}
