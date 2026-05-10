import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/supabase_client.dart';
import '../../widgets/shared/header.dart';
import '../../widgets/shared/bottom_navbar.dart';
import '../../widgets/shared/form.dart';
import 'login_page.dart';

// ================================================
// PROVIDERS — loading & error state
// ================================================
final registrasiLoadingProvider = StateProvider<bool>((ref) => false);
final registrasiErrorProvider = StateProvider<String?>((ref) => null);

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _selectedTabIndex = 1;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Clear previous error
    ref.read(registrasiErrorProvider.notifier).state = null;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validate: no empty fields
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ref.read(registrasiErrorProvider.notifier).state =
          'Semua field harus diisi.';
      return;
    }

    // 2. Validate: password == confirmPassword
    if (password != confirmPassword) {
      ref.read(registrasiErrorProvider.notifier).state =
          'Kata sandi dan konfirmasi kata sandi tidak sama.';
      return;
    }

    // 3. Validate: password >= 8 characters
    if (password.length < 8) {
      ref.read(registrasiErrorProvider.notifier).state =
          'Password minimal 8 karakter.';
      return;
    }

    ref.read(registrasiLoadingProvider.notifier).state = true;

    try {
      // 4. Call supabase.auth.signUp
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        ref.read(registrasiErrorProvider.notifier).state =
            'Registrasi gagal. Coba lagi.';
        return;
      }

      // 5. Insert to users table
      await supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'role': 'Customer',
      });

      // 6. Insert to customers table
      await supabase.from('customers').insert({
        'user_id': user.id,
        'username': username,
      });

      // 7. On success → navigate to LoginPage with success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      // 8. Catch AuthException → show error in Bahasa Indonesia
      if (!mounted) return;
      ref.read(registrasiErrorProvider.notifier).state =
          _translateAuthError(e.message);
    } catch (_) {
      if (!mounted) return;
      ref.read(registrasiErrorProvider.notifier).state =
          'Tidak dapat terhubung. Periksa koneksi internet kamu.';
    } finally {
      if (mounted) {
        ref.read(registrasiLoadingProvider.notifier).state = false;
      }
    }
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('user already registered') ||
        lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'Email sudah terdaftar.';
    }
    if (lower.contains('password should be at least') ||
        lower.contains('password must be')) {
      return 'Password minimal 8 karakter.';
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket')) {
      return 'Tidak dapat terhubung. Periksa koneksi internet kamu.';
    }
    if (lower.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    return message.isNotEmpty ? message : 'Registrasi gagal. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registrasiLoadingProvider);
    final errorMessage = ref.watch(registrasiErrorProvider);

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nikmati kemudahan pesan galon kapan saja, langsung ke pintu kamu.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 30),

                    RegisterForm(
                      formKey: _formKey,
                      usernameController: _usernameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      isLoading: isLoading,
                      onRegister: _handleRegister,
                    ),

                    // Error box below the form
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBox(message: errorMessage),
                    ],

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          ),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            LoginBottomNavBar(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
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
