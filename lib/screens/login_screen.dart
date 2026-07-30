import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/role_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/mesh_gradient_bg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController(text: 'hafiz.rahman');
  final _passCtrl = TextEditingController(text: '••••••••');
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login(AppRole role) {
    context.read<RoleProvider>().setRole(role);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      body: MeshGradientBg(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.cyan, AppColors.purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.precision_manufacturing_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.cyan, AppColors.purple],
                    ).createShader(b),
                    child: Text(
                      'INDUSTRIAL IoT',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back',
                            style: GoogleFonts.poppins(
                                color: onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        Text('Sign in to the plant console',
                            style: GoogleFonts.poppins(
                                color: onVar, fontSize: 14)),
                        const SizedBox(height: 24),
                        _label('User ID', onSurface),
                        const SizedBox(height: 6),
                        _field(
                          controller: _idCtrl,
                          hint: 'Enter your user ID',
                          icon: Icons.badge_outlined,
                          isDark: isDark,
                          onSurface: onSurface,
                        ),
                        const SizedBox(height: 16),
                        _label('Password', onSurface),
                        const SizedBox(height: 6),
                        _field(
                          controller: _passCtrl,
                          hint: 'Enter password',
                          icon: Icons.lock_outline,
                          isDark: isDark,
                          onSurface: onSurface,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.cyan,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _primaryButton(
                          'Sign in as Plant Manager',
                          () => _login(AppRole.manager),
                        ),
                        const SizedBox(height: 12),
                        _secondaryButton(
                          'Sign in as Operator',
                          () => _login(AppRole.operator),
                          isDark,
                          onSurface,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Demo build · front-end only',
                      style: GoogleFonts.poppins(color: onVar, fontSize: 11.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, Color color) => Text(text,
      style: GoogleFonts.poppins(
          color: color, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color onSurface,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.slate700
              : AppColors.cyan.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(color: onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: AppColors.slate500),
          prefixIcon: Icon(icon, color: AppColors.cyan, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(
      String label, VoidCallback onTap, bool isDark, Color onSurface) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: isDark ? AppColors.slate700 : AppColors.slate300),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
