import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Matching your exact file structure
import 'package:smartcanteen/theme/App_Color.dart';
import 'package:smartcanteen/screen/LoginPage.dart';

void main() {
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