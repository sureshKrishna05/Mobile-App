import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/login_page.dart';
import 'package:smartcanteen/screen/college_section_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load variables from your .env file
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await GoogleFonts.pendingFonts();
  runApp(const SmartCanteenApp());
}

class SmartCanteenApp extends StatelessWidget {
  const SmartCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgRadialEnd,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const _AuthGate(),
    );
  }
}

/// Checks if a session already exists and routes accordingly.
/// - Logged in  → CollegeSelectionPage
/// - Logged out → LoginPage
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const CollegeSelectionPage();
    }
    return const LoginPage();
  }
}