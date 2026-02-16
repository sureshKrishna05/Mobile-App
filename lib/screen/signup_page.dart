import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/otp_verification_page.dart'; 

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, -0.3),
                radius: 1.2,
                colors: [AppColors.bgRadialStart, AppColors.bgRadialEnd],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine layout breakpoints for padding
                final bool isDesktop = constraints.maxWidth > 800;
                final bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth <= 800;
                
                // Fluid horizontal padding
                final double horizontalPadding = isDesktop ? constraints.maxWidth * 0.15 : (isTablet ? 60 : 25);
                
                // Fluid spacing based on screen height
                final double verticalSpacing = (constraints.maxHeight * 0.04).clamp(20.0, 50.0);

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header: Back Button & Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
                              onPressed: () => Navigator.pop(context),
                            ),
                            _buildSmallLogo(constraints.maxWidth),
                          ],
                        ),
                        
                        SizedBox(height: verticalSpacing),
                        
                        // Registration Form Container
                        Container(
                          constraints: const BoxConstraints(maxWidth: 450), // Prevents ultra-wide stretching
                          padding: EdgeInsets.all(isDesktop ? 40 : 30), // Slightly larger padding on big screens
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create Account",
                                style: GoogleFonts.poppins(
                                  // Fluid typography for the title
                                  fontSize: (constraints.maxWidth * 0.07).clamp(26.0, 32.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              _buildField("Username", Icons.alternate_email),
                              const SizedBox(height: 15),
                              
                              _buildField("Email", Icons.email_outlined),
                              const SizedBox(height: 15),
                              
                              _buildField("Password", Icons.lock_outlined, isPass: true),
                              const SizedBox(height: 15),
                              
                              _buildField("Confirm Password", Icons.lock_reset_outlined, isPass: true),
                              const SizedBox(height: 30),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const OTPVerificationPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text(
                                    "Register Now",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Already have an account? ",
                                      style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                                      children: const [
                                        TextSpan(
                                          text: "Login",
                                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, IconData icon, {bool isPass = false}) {
    return TextField(
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSmallLogo(double maxWidth) {
    // Scales the logo text smoothly
    final double logoTextSize = (maxWidth * 0.04).clamp(16.0, 20.0);

    return Row(
      children: [
        const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Smart Canteen',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: logoTextSize,
          ),
        ),
      ],
    );
  }
}