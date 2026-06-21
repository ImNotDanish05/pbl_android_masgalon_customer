import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // 1. Sign In
  Future<AuthCustomer> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Login gagal. User tidak ditemukan.');
    }

    // Check role from users table — must be 'Customer'
    final userData = await _supabase
        .from('users')
        .select('role, avatar_url')
        .eq('id', response.user!.id)
        .single();

    final role = userData['role'] as String?;
    final avatarUrl = userData['avatar_url'] as String?;

    if (role != 'Customer') {
      await _supabase.auth.signOut();
      throw const AuthException('Akun ini bukan akun customer.');
    }

    // Fetch customer data (username & saldo)
    final customerData = await _supabase
        .from('customers')
        .select('username, saldo_abunemen')
        .eq('user_id', response.user!.id)
        .single();

    return AuthCustomer(
      id: response.user!.id,
      email: response.user!.email ?? '',
      username: customerData['username'] as String,
      avatarUrl: avatarUrl,
      saldoAbunemen: customerData['saldo_abunemen'] != null
          ? int.tryParse(customerData['saldo_abunemen'].toString()) ?? 0
          : 0,
    );
  }

  // 2. Sign Up
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registrasi gagal. User tidak ditemukan.');
    }

    // Check if already fully registered in users table
    final existingUser = await _supabase
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existingUser != null) {
      await _supabase.auth.signOut();
      throw const AuthException('Email sudah terdaftar. Silakan login.');
    }

    return user;
  }

  // 3. Resend OTP Signup
  Future<void> resendRegisterOtp({required String email}) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  // 4. Verify OTP Signup
  Future<void> verifyRegisterOtp({
    required String email,
    required String token,
    required String username,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );

    // Insert into users
    await _supabase.from('users').insert({
      'id': _supabase.auth.currentUser!.id,
      'email': email,
      'role': 'Customer',
    });

    // Insert into customers
    await _supabase.from('customers').insert({
      'user_id': _supabase.auth.currentUser!.id,
      'username': username,
    });
  }

  // 5. Send Password Reset
  Future<void> sendPasswordReset({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // 6. Verify OTP Recovery
  Future<void> verifyResetOtp({
    required String email,
    required String token,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  // 7. Update Password
  Future<void> updatePassword({required String newPassword}) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // 8. Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // 9. Restore Session
  Future<AuthCustomer?> restoreSession(Session session) async {
    // Check role
    final userData = await _supabase
        .from('users')
        .select('role, avatar_url')
        .eq('id', session.user.id)
        .single();

    final role = userData['role'] as String;
    final avatarUrl = userData['avatar_url'] as String?;

    if (role != 'Customer') {
      await _supabase.auth.signOut();
      return null;
    }

    // Fetch customer data
    final customerData = await _supabase
        .from('customers')
        .select('username, saldo_abunemen')
        .eq('user_id', session.user.id)
        .single();

    return AuthCustomer(
      id: session.user.id,
      email: session.user.email ?? '',
      username: customerData['username'] as String,
      avatarUrl: avatarUrl,
      saldoAbunemen: customerData['saldo_abunemen'] != null
          ? int.tryParse(customerData['saldo_abunemen'].toString()) ?? 0
          : 0,
    );
  }
}
