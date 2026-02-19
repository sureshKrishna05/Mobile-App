import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/otp_verification_page.dart';
import 'package:smartcanteen/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = AuthService();
  
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ SUPABASE SIGNUP LOGIC (Routes to OTP Page)
  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (!mounted) return;

      // Navigate to OTP screen for Signup Verification
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            email: email, 
            isLogin: false, // Tells the OTP screen this is a signup
          )
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

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
                final bool isDesktop = constraints.maxWidth > 800;
                final bool isTablet = constraints.maxWidth >= 600 && constraints.maxWidth <= 800;
                
                final double horizontalPadding = isDesktop ? constraints.maxWidth * 0.15 : (isTablet ? 60 : 25);
                final double verticalSpacing = (constraints.maxHeight * 0.04).clamp(20.0, 50.0);

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                        
                        Container(
                          constraints: const BoxConstraints(maxWidth: 450), 
                          padding: EdgeInsets.all(isDesktop ? 40 : 30), 
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
                                  fontSize: (constraints.maxWidth * 0.07).clamp(26.0, 32.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              _buildField(
                                label: "Username", 
                                icon: Icons.alternate_email,
                                controller: _usernameController
                              ),
                              const SizedBox(height: 15),
                              
                              _buildField(
                                label: "Email", 
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                isEmail: true,
                              ),
                              const SizedBox(height: 15),
                              
                              _buildField(
                                label: "Password", 
                                icon: Icons.lock_outlined, 
                                controller: _passwordController,
                                isPass: true
                              ),
                              const SizedBox(height: 15),
                              
                              _buildField(
                                label: "Confirm Password", 
                                icon: Icons.lock_reset_outlined, 
                                controller: _confirmPasswordController,
                                isPass: true
                              ),
                              const SizedBox(height: 30),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _signUp, 
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: isLoading 
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                      : const Text("Register Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildField({
    required String label, 
    required IconData icon, 
    required TextEditingController controller,
    bool isPass = false,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
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
    final double logoTextSize = (maxWidth * 0.04).clamp(16.0, 20.0);
    return Row(
      children: [
        const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          'Smart Canteen',
          style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: logoTextSize),
        ),
      ],
    );
  }
}