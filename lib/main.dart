import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './app_routes.dart';
import 'dart:async';
import 'package:appearance/appearance.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesManager.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppearanceState {
  @override
  Widget build(BuildContext context) {
    return BuildWithAppearance(
      initial: ThemeMode.light, // Ensure the default theme is light mode
      builder: (context) => MaterialApp(
        title: 'SastraVerse',
        debugShowCheckedModeBanner: false,
        themeMode: Appearance.of(context)?.mode,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[50], // Lighter light background
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            surface: Colors.white, // Card background
          ),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            bodyMedium: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
            titleLarge: GoogleFonts.poppins(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212), // A very dark gray, almost black
          colorScheme: ColorScheme.dark(
            primary: Colors.blue[300]!, // Lighter blue for dark mode
            secondary: Colors.blueAccent[200]!,
            surface: const Color(0xFF1E1E1E), // Dark card background
          ),
          textTheme: TextTheme(
            bodyLarge: GoogleFonts.poppins(color: const Color.fromARGB(179, 255, 255, 255), fontSize: 16),
            bodyMedium: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            titleLarge: GoogleFonts.poppins(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 16),
            Text(
              'SastraVerse',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}