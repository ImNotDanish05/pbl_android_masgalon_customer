import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/supabase_client.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/header.dart';
import '../../widgets/auth/login_welcome_section.dart';
import '../../widgets/shared/form.dart';
import '../../widgets/shared/bottom_navbar.dart';

// ================================================
// PROVIDERS — loading & error state
// ================================================
final loginPageLoadingProvider = StateProvider<bool>((ref) => false);
final loginPageErrorProvider = StateProvider<String?>((ref) => null);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    ref.read(loginPageErrorProvider.notifier).state = null;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validate empty fields
    if (email.isEmpty || password.isEmpty) {
      ref.read(loginPageErrorProvider.notifier).state =
          'Email dan password tidak boleh kosong.';
      return;
    }

    ref.read(loginPageLoadingProvider.notifier).state = true;

    try {
      // 2. Sign in with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        ref.read(loginPageErrorProvider.notifier).state =
            'Login gagal. Coba lagi.';
        return;
      }

      // 3. Check role from users table — must be 'Customer'
      final userData = await supabase
          .from('users')
          .select('role')
          .eq('id', response.user!.id)
          .single();

      final role = userData['role'] as String?;

      // 4. If role != 'Customer' → signOut + show error
      if (role != 'Customer') {
        await supabase.auth.signOut();
        if (!mounted) return;
        ref.read(loginPageErrorProvider.notifier).state =
            'Akun ini bukan akun customer.';
        return;
      }

      // 5. Fetch customer data (username & saldo)
      final customerData = await supabase
          .from('customers')
          .select('username, saldo_abunemen')
          .eq('user_id', response.user!.id)
          .single();

      // 6. Store into authCustomerProvider
      ref.read(authCustomerProvider.notifier).state = AuthCustomer(
        id: response.user!.id,
        email: response.user!.email ?? '',
        username: customerData['username'] as String,
        saldoAbunemen: customerData['saldo_abunemen'] as int? ?? 0,
      );

      // 7. Navigate to HomePage
      if (!mounted) return;
      context.go('/home');
    } on AuthException catch (e) {
      // Catch AuthException → show error in Bahasa Indonesia
      if (!mounted) return;
      ref.read(loginPageErrorProvider.notifier).state =
          _translateAuthError(e.message);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ref.read(loginPageErrorProvider.notifier).state =
          'Gagal mengambil data akun. Coba lagi. (${e.message})';
    } on SocketException {
      if (!mounted) return;
      ref.read(loginPageErrorProvider.notifier).state =
          'Tidak dapat terhubung ke jaringan. Periksa koneksi internet kamu.';
    } catch (e) {
      if (!mounted) return;
      ref.read(loginPageErrorProvider.notifier).state =
          'Terjadi kesalahan: ${e.toString()}';
    } finally {
      if (mounted) {
        ref.read(loginPageLoadingProvider.notifier).state = false;
      }
    }
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials') ||
        lower.contains('email not confirmed')) {
      return 'Email atau password salah. Periksa kembali dan coba lagi.';
    }
    if (lower.contains('user not found')) {
      return 'Akun tidak ditemukan. Pastikan email sudah terdaftar.';
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket')) {
      return 'Tidak dapat terhubung. Periksa koneksi internet kamu.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return message.isNotEmpty ? message : 'Login gagal. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginPageLoadingProvider);
    final errorMessage = ref.watch(loginPageErrorProvider);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const LoginHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    const LoginWelcomeSection(),
                    const SizedBox(height: 36),
                    LoginForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: isLoading,
                      onLogin: _handleLogin,
                    ),
                    // Error box below the form
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBox(message: errorMessage),
                    ],
                    const SizedBox(height: 12),
                    // "Lupa kata sandi?" link
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push('/forgot-password'),
                        child: const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSignUpRow(),
                    const SizedBox(height: 40),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            LoginBottomNavBar(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                if (index == 1) {
                  context.go('/register');
                } else {
                  setState(() => _selectedTabIndex = index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        GestureDetector(
          onTap: () => context.go('/register'),
          child: const Text(
            'Daftar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
