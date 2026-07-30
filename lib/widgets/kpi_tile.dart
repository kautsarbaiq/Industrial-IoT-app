import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

/// Compact KPI tile: icon, big value, label, and an optional delta trend.
class KpiTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? delta; // e.g. "+2.4%"
  final bool deltaUp;
  final VoidCallback? onTap;

  const KpiTile({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.delta,
    this.deltaUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (delta != null)
                Row(children: [
                  Icon(
                    deltaUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 13,
                    color: deltaUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    delta!,
                    style: GoogleFonts.poppins(
                      color: deltaUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(color: onVar, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
