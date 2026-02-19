import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/screen/dashboard_page.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  final bool isLogin; // Tells us if we are verifying a Login or a Signup

  const OTPVerificationPage({
    super.key, 
    required this.email, 
    this.isLogin = false
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _authService = AuthService();
  bool isLoading = false;
  
  // Controllers to capture all 6 digits
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ✅ VERIFY OTP LOGIC
  Future<void> _verifyCode() async {
    // Combine the text from all 6 boxes
    String otpCode = _otpControllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.verifyOTP(
        email: widget.email,
        token: otpCode,
        // If coming from login use magiclink type, otherwise use signup type
        type: widget.isLogin ? OtpType.magiclink : OtpType.signup, 
      );

      if (!mounted) return;

      // Success! Send them to the dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (route) => false, // Clears the navigation stack
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                final bool isDesktop = constraints.maxWidth > 600;
                final double contentWidth = isDesktop ? 450 : constraints.maxWidth;
                
                // 🟢 FIXED: Math adjusted to fit 6 boxes perfectly
                final double boxSize = ((contentWidth - 110) / 6).clamp(40.0, 55.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450), 
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.05),
                          
                          _buildHeader(contentWidth),
                          
                          SizedBox(height: constraints.maxHeight * 0.06),
                          
                          // 🟢 FIXED: Generates 6 boxes instead of 4
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) => 
                              _otpBox(
                                context, 
                                index: index,
                                size: boxSize,
                                first: index == 0, 
                                last: index == 5
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

  Widget _otpBox(BuildContext context, {required int index, required double size, bool first = false, bool last = false}) {
    return SizedBox(
      height: size * 1.2,
      width: size,
      child: TextField(
        controller: _otpControllers[index],
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: size * 0.45, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
          "Enter the 6-digit code sent to\n${widget.email}",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textLight, fontSize: subtitleSize)
        ),
      ],
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
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
        onPressed: isLoading ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text("Verify & Proceed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        const Text("Didn't receive a code?", style: TextStyle(color: AppColors.textLight)),
        TextButton(
          onPressed: () {
            // Add resend logic here later if needed
          },
          child: const Text("Resend Code", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}