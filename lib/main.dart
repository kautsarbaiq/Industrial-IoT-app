import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/role_provider.dart';
import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IndustrialIotApp());
}

class IndustrialIotApp extends StatelessWidget {
  const IndustrialIotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor:
                isDark ? const Color(0xFF020617) : Colors.white,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            title: 'Industrial IoT',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData.copyWith(
              textTheme:
                  GoogleFonts.poppinsTextTheme(themeProvider.themeData.textTheme),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const ShellScreen(),
            },
          );
        },
      ),
    );
  }
}
