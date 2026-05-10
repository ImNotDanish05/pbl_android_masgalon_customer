import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../../core/constants/app_colors.dart';
import 'input_field.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          InputField(
            label: 'MASUKKAN EMAIL',
            hint: 'nama@email.com',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password field
          InputField(
            label: 'PASSWORD',
            hint: '••••••••',
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            labelTrailing: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text(
                'Lupa Password?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),

          const SizedBox(height: 28),

          // Login button
          GFButton(
            onPressed: widget.isLoading ? null : widget.onLogin,
            text: widget.isLoading ? '' : 'Masuk',
            icon: widget.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
            color: AppColors.primaryBlue,
            textColor: Colors.white,
            size: GFSize.LARGE,
            fullWidthButton: true,
            shape: GFButtonShape.standard,
            borderShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final VoidCallback onRegister;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.onRegister,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Username field
          InputField(
            label: 'Username',
            hint: 'Masukkan Username',
            controller: widget.usernameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 2. Email field
          LoginInputField(
            label: 'Email',
            hint: 'contoh@email.com',
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 3. Password field
          InputField(
            label: 'Kata Sandi',
            hint: 'Min. 8 karakter',
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Kata sandi minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 4. Confirm Password field
          InputField(
            label: 'Konfirmasi Kata Sandi',
            hint: 'Ulangi kata sandi',
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              child: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi kata sandi tidak boleh kosong';
              }
              // Membandingkan dengan password sebelumnya
              if (value != widget.passwordController.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // 5. Register button
          GFButton(
            onPressed: widget.isLoading ? null : widget.onRegister,
            text: widget.isLoading ? '' : 'Daftar',
            icon: widget.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
            color: AppColors.primaryBlue,
            textColor: Colors.white,
            size: GFSize.LARGE,
            fullWidthButton: true,
            shape: GFButtonShape.standard,
            borderShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
