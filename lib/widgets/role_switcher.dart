import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/role_provider.dart';
import '../theme/app_theme.dart';

/// A segmented Operator / Manager toggle used in Settings and the login demo.
class RoleSwitcher extends StatelessWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rp = context.watch<RoleProvider>();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900.withOpacity(0.5) : AppColors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Row(children: [
        _segment(context, 'Operator', AppRole.operator, rp),
        _segment(context, 'Plant Manager', AppRole.manager, rp),
      ]),
    );
  }

  Widget _segment(
      BuildContext context, String label, AppRole role, RoleProvider rp) {
    final selected = rp.role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => rp.setRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple])
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
