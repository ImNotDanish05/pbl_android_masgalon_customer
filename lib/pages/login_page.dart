import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../constants/app_colors.dart';
import '../widgets/login_header.dart';
import '../widgets/login_welcome_section.dart';
import '../widgets/login_form.dart';
import '../widgets/gallon_illustration.dart';
import '../widgets/login_bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      if (mounted) {
        GFToast.showToast(
          'Berhasil masuk! Selamat datang kembali.',
          context,
          toastPosition: GFToastPosition.BOTTOM,
          backgroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      isLoading: _isLoading,
                      onLogin: _handleLogin,
                    ),
                    const SizedBox(height: 20),
                    _buildSignUpRow(),
                    const SizedBox(height: 40),
                    const GallonIllustration(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            LoginBottomNavBar(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) =>
                  setState(() => _selectedTabIndex = index),
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
          onTap: () {
            // Navigate to register page
          },
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
