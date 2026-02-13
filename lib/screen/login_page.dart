import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/signup_page.dart'; 
// import 'package:smartcanteen/screen/dashboard_page.dart'; 
import 'package:smartcanteen/screen/college_section_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _showLoginDialog(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    showDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: Dialog(
            backgroundColor: AppColors.surface,
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth > 450 ? 0 : 20, // Responsive dialog padding
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Container(
              padding: const EdgeInsets.all(32),
              width: screenWidth > 400 ? 400 : screenWidth * 0.9, // Caps width at 400
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
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const CollegeSelectionPage()),
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
    final size = MediaQuery.sizeOf(context);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine layout breakpoints
                final isDesktop = constraints.maxWidth >= 900;
                final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
                final isMobile = constraints.maxWidth < 600;
                
                // Dynamically calculate horizontal padding based on screen size
                final double horizontalPadding = isDesktop ? size.width * 0.1 : (isTablet ? 40 : 20);

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLogo(size.width),
                          _buildNavButton(context, "Sign Up"),
                        ],
                      ),
                      SizedBox(height: isMobile ? size.height * 0.05 : size.height * 0.1),
                      
                      // Flex dynamically changes between Row (Desktop) and Column (Mobile/Tablet)
                      Flex(
                        direction: isDesktop ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: isDesktop ? constraints.maxWidth * 0.45 : double.infinity,
                            child: _buildHeroText(context, isDesktop),
                          ),
                          if (!isDesktop) SizedBox(height: size.height * 0.08) else const SizedBox(width: 50),
                          SizedBox(
                            width: isDesktop ? constraints.maxWidth * 0.4 : double.infinity,
                            child: _buildHeroImageSection(constraints.maxWidth),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                );
              }
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
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
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
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(double screenWidth) {
    // Logo text scales down slightly on very small screens
    final double fontSize = (screenWidth * 0.045).clamp(16.0, 22.0);
    
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
                color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: fontSize)),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.orange.withValues(alpha: 0.1), blurRadius: 10)
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

  Widget _buildHeroText(BuildContext context, bool isDesktop) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Font size fluidly adjusts between 32 and 65 based on screen width
    final double titleSize = (screenWidth * 0.08).clamp(32.0, 65.0);
    final double subtitleSize = (screenWidth * 0.025).clamp(14.0, 18.0);

    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: titleSize, 
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
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          style: TextStyle(color: AppColors.textLight, fontSize: subtitleSize, height: 1.6),
        ),
        const SizedBox(height: 35),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
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

Widget _buildHeroImageSection(double maxWidth) {
    // Ensures the image isn't too large on massive screens, nor overflowing on small ones
    final double baseWidth = (maxWidth * 0.8).clamp(250.0, 460.0);
    final double baseHeight = (baseWidth * 0.9).clamp(250.0, 440.0);
    final bool isSmall = maxWidth < 600;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            width: baseWidth * 0.95,
            height: baseHeight * 0.9,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(isSmall ? 30 : 40),
          child: Image.network(
            'https://images.unsplash.com/photo-1559329007-40df8a9345d8?q=80&w=800',
            width: baseWidth,
            height: baseHeight,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: baseWidth,
                height: baseHeight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              );
            },
          ),
        ),
        _buildBadge(
          top: 20, 
          right: isSmall ? -10 : -30, 
          icon: Icons.star, 
          label: "RATED #1", 
          value: "Campus Choice",
          isSmall: isSmall
        ),
        _buildBadge(
          bottom: -15, 
          left: isSmall ? 10 : 30, 
          icon: Icons.flash_on, 
          label: "INSTANT", 
          value: "Smart Pickup",
          isSmall: isSmall
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20)],
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