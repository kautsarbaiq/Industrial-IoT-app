import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/mesh_gradient_bg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<double> _scale =
      Tween<double>(begin: 0.85, end: 1.0).animate(
    CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      body: MeshGradientBg(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.brandDeep,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.precision_manufacturing_rounded,
                        color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.brandDeep, AppColors.brandDeep],
                    ).createShader(b),
                    child: Text(
                      'INDUSTRIAL IoT',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Machine Monitoring · OEE · Production',
                    style: GoogleFonts.poppins(color: onVar, fontSize: 12.5),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.cyan.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
