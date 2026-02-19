import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Access the Supabase client instance
  final _supabase = Supabase.instance.client;

  // ==========================================
  // 1. SIGN IN WITH PASSWORD
  // ==========================================
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ==========================================
  // 2. SIGN UP (Sends 6-digit OTP to email)
  // ==========================================
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data, // Used to pass the custom 'username'
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data, 
    );
  }

  // ==========================================
  // 3. SEND LOGIN OTP (For Passwordless Login)
  // ==========================================
  Future<void> sendLoginOTP({
    required String email,
  }) async {
    await _supabase.auth.signInWithOtp(
      email: email,
    );
  }

  // ==========================================
  // 4. VERIFY 6-DIGIT OTP (For BOTH Signup and Login)
  // ==========================================
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type, // Must be OtpType.signup OR OtpType.magiclink
  }) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  // ==========================================
  // 5. SIGN OUT
  // ==========================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ==========================================
  // 6. GET CURRENT USER
  // ==========================================
  User? get currentUser => _supabase.auth.currentUser;
}