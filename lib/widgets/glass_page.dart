import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mesh_gradient_bg.dart';

/// Pushes a full-screen page with the shared mesh background and a transparent
/// app bar. Used for drill-downs (machine detail, alarms, settings, etc.).
Future<T?> openGlassPage<T>(
  BuildContext context,
  String title,
  Widget body, {
  List<Widget>? actions,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (ctx) => GlassScaffold(title: title, actions: actions, body: body),
    ),
  );
}

class GlassScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const GlassScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
              color: onSurface, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: actions,
      ),
      body: MeshGradientBg(child: body),
    );
  }
}
