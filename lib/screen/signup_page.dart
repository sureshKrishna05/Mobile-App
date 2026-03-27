import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smartcanteen/theme/app_color.dart';
import 'package:smartcanteen/screen/otp_verification_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // ✅ FIX 1: Proper controllers for all fields
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ✅ FIX 2: Real Supabase signup call
  Future<void> _handleSignup() async {
    final username = _usernameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    // Validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // ✅ FIX 3: Register with Supabase Auth and pass full_name as metadata
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': username},
      );

      if (!mounted) return;

      if (response.user != null) {
        // ✅ FIX 4: Insert profile row after successful signup
        await Supabase.instance.client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': username,
          'role': 'student',
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OTPVerificationPage(email: email),
          ),
        );
      } else {
        setState(
            () => _errorMessage = 'Signup failed. Please try again.');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                final bool isTablet = constraints.maxWidth >= 600 &&
                    constraints.maxWidth <= 800;
                final double horizontalPadding = isDesktop
                    ? constraints.maxWidth * 0.15
                    : (isTablet ? 60 : 25);
                final double verticalSpacing =
                    (constraints.maxHeight * 0.04).clamp(20.0, 50.0);

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: AppColors.textDark),
                              onPressed: () => Navigator.pop(context),
                            ),
                            _buildSmallLogo(constraints.maxWidth),
                          ],
                        ),
                        SizedBox(height: verticalSpacing),
                        Container(
                          constraints:
                              const BoxConstraints(maxWidth: 450),
                          padding:
                              EdgeInsets.all(isDesktop ? 40 : 30),
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
                                  fontSize: (constraints.maxWidth * 0.07)
                                      .clamp(26.0, 32.0),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // ✅ FIX 5: All fields have controllers
                              _buildField("Username",
                                  Icons.alternate_email, _usernameController),
                              const SizedBox(height: 15),
                              _buildField("Email", Icons.email_outlined,
                                  _emailController,
                                  inputType: TextInputType.emailAddress),
                              const SizedBox(height: 15),
                              _buildField("Password",
                                  Icons.lock_outlined, _passwordController,
                                  isPass: true),
                              const SizedBox(height: 15),
                              _buildField("Confirm Password",
                                  Icons.lock_reset_outlined, _confirmController,
                                  isPass: true),

                              // ✅ FIX 6: Error message display
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.red, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(_errorMessage!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12)),
                                    ),
                                  ]),
                                ),
                              ],

                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading ? null : _handleSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : const Text(
                                          "Register Now",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: const TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: "Login",
                                          style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold),
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

  Widget _buildField(
      String label, IconData icon, TextEditingController controller,
      {bool isPass = false,
      TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: inputType,
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