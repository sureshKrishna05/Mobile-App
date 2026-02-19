import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Matching your exact file structure
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/login_page.dart';
//backend
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  // 1. Ensure Flutter binding is initialized before doing any async work
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Await pending Google Fonts so it doesn't freeze the first frame
  await GoogleFonts.pendingFonts();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
        // Using Poppins to keep the premium food-app look
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LoginPage(),
    );
  }
}