import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/App_Color.dart';
import 'package:smartcanteen/screen/SignupPage.dart'; 
// ADD THIS IMPORT:
import 'package:smartcanteen/screen/DashboardPage.dart'; 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Dialog(
            backgroundColor: AppColors.surface,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(32),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Welcome Back",
                      style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                  const SizedBox(height: 30),
                  _buildTextField("Username", Icons.person_outline),
                  const SizedBox(height: 20),
                  _buildTextField("Password", Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: ElevatedButton(
                      // UPDATED LINE:
                      onPressed: () {
                        // Remove the dialog first
                        Navigator.pop(context); 
                        // Move to Dashboard and replace the login stack
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Login",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.3),
                radius: 1.2,
                colors: [AppColors.bgRadialStart, AppColors.bgRadialEnd],
              ),
            ),
          ),
          _buildAestheticBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: mobile ? 25 : 60, 
                vertical: 30
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLogo(),
                      _buildNavButton(context, "Sign Up"),
                    ],
                  ),
                  SizedBox(height: mobile ? 40 : 80),
                  Flex(
                    direction: mobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: mobile ? double.infinity : MediaQuery.of(context).size.width * 0.45,
                        child: _buildHeroText(context, mobile),
                      ),
                      if (mobile) const SizedBox(height: 60) else const SizedBox(width: 50),
                      SizedBox(
                        width: mobile ? double.infinity : MediaQuery.of(context).size.width * 0.4,
                        child: _buildHeroImageSection(mobile),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: CircleAvatar(
            radius: 120,
            backgroundColor: AppColors.primary.withOpacity(0.12),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -30,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('Smart Canteen',
            style: GoogleFonts.poppins(
                color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: Colors.white,
        ),
        child: Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 13)),
      ),
    );
  }

  Widget _buildHeroText(BuildContext context, bool mobile) {
    return Column(
      crossAxisAlignment: mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        RichText(
          textAlign: mobile ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: mobile ? 36 : 60, 
              fontWeight: FontWeight.w800, 
              color: AppColors.textDark, 
              height: 1.1
            ),
            children: const [
              TextSpan(text: 'Skip the Line,\n'),
              TextSpan(text: 'Satisfy the Craving.', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'The smartest way to order food at your canteen.',
          textAlign: mobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: AppColors.textLight, fontSize: mobile ? 16 : 18, height: 1.6),
        ),
        const SizedBox(height: 35),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _showLoginDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                SizedBox(width: 10),
                Icon(Icons.login, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImageSection(bool mobile) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            width: mobile ? 300 : 460,
            height: mobile ? 280 : 400,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(mobile ? 30 : 40),
          child: Image.network(
            'https://images.unsplash.com/photo-1559329007-40df8a9345d8?q=80&w=800',
            width: double.infinity,
            height: mobile ? 320 : 440,
            fit: BoxFit.cover,
          ),
        ),
        _buildBadge(
          top: 20, 
          right: mobile ? -10 : -30, 
          icon: Icons.star, 
          label: "RATED #1", 
          value: "Campus Choice",
          isSmall: mobile
        ),
        _buildBadge(
          bottom: -15, 
          left: mobile ? 10 : 30, 
          icon: Icons.flash_on, 
          label: "INSTANT", 
          value: "Smart Pickup",
          isSmall: mobile
        ),
      ],
    );
  }

  Widget _buildBadge({
    double? top, double? right, double? bottom, double? left,
    required IconData icon, required String label, required String value,
    bool isSmall = false
  }) {
    return Positioned(
      top: top, right: right, bottom: bottom, left: left,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 18, 
          vertical: isSmall ? 8 : 14
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.orange, size: isSmall ? 20 : 26),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(color: AppColors.textDark, fontSize: isSmall ? 12 : 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}