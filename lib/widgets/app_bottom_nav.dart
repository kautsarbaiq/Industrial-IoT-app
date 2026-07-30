import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NavDest {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavDest(this.icon, this.activeIcon, this.label);
}

/// Frosted glass bottom navigation bar.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavDest> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.slate900.withOpacity(0.85)
                : Colors.white.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < items.length; i++)
                    _item(context, i),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int i) {
    final active = i == currentIndex;
    final dest = items[i];
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? AppColors.cyan.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            active ? dest.activeIcon : dest.icon,
            color: active ? AppColors.cyan : AppColors.slate400,
            size: 23,
          ),
          const SizedBox(height: 2),
          Text(
            dest.label,
            style: GoogleFonts.poppins(
              color: active ? AppColors.cyan : AppColors.slate400,
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ]),
      ),
    );
  }
}
