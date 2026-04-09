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
class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _ready = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // On Flutter Web, session restores asynchronously from localStorage.
    // Wait for the first auth state event before routing.
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() { _loggedIn = true; _ready = true; });
      return;
    }
    // Listen for the session to restore
    Supabase.instance.client.auth.onAuthStateChange.first.then((event) {
      if (mounted) {
        setState(() {
          _loggedIn = event.session != null;
          _ready = true;
        });
      }
    });
    // Timeout fallback — if no session after 2s, go to login
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && !_ready) {
      setState(() { _loggedIn = false; _ready = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppColors.bgRadialEnd,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return _loggedIn ? const CollegeSelectionPage() : const LoginPage();
  }
}
