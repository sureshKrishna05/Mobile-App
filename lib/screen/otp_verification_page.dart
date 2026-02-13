import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/screen/dashboard_page.dart';
import 'package:smartcanteen/theme/app_color.dart';

class OTPVerificationPage extends StatelessWidget {
  const OTPVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Fluid sizing calculations
                final bool isDesktop = constraints.maxWidth > 600;
                // Caps the form width at 450px for desktop, otherwise uses screen width minus padding
                final double contentWidth = isDesktop ? 450 : constraints.maxWidth;
                // Calculates OTP box size dynamically, clamped between 50 and 70 pixels
                final double boxSize = ((contentWidth - 100) / 4).clamp(50.0, 70.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450), // Prevents ultra-wide stretching
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05), // Responsive spacing
                          
                          _buildHeader(contentWidth),
                          
                          SizedBox(height: constraints.maxHeight * 0.06),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (index) => 
                              _otpBox(
                                context, 
                                size: boxSize,
                                first: index == 0, 
                                last: index == 3
                              )
                            ),
                          ),
                          
                          SizedBox(height: constraints.maxHeight * 0.06),
                          
                          _buildVerifyButton(context),
                          const SizedBox(height: 30),
                          _buildResendSection(),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(BuildContext context, {required double size, bool first = false, bool last = false}) {
    return SizedBox(
      height: size * 1.2,
      width: size,
      child: TextField(
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        // Font size scales with the box size
        style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && !last) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.5, -0.3),
          radius: 1.2,
          colors: [AppColors.bgRadialStart, AppColors.bgRadialEnd],
        ),
      ),
    );
  }

  Widget _buildHeader(double width) {
    // Fluid typography
    final double titleSize = (width * 0.08).clamp(26.0, 32.0);
    final double subtitleSize = (width * 0.04).clamp(14.0, 16.0);

    return Column(
      children: [
        Text(
          "Verify Email",
          style: GoogleFonts.poppins(fontSize: titleSize, fontWeight: FontWeight.bold, color: AppColors.textDark)
        ),
        const SizedBox(height: 10),
        Text(
          "Enter the 4-digit code sent to your mail.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight, fontSize: subtitleSize)
        ),
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60, // Fixed height is fine here since width is constrained
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3), 
            blurRadius: 12, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text("Verify & Proceed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        const Text("Didn't receive a code?", style: TextStyle(color: AppColors.textLight)),
        TextButton(
          onPressed: () {},
          child: const Text("Resend Code", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}