import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_strength/password_strength.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_client.dart';
import '../../widgets/auth/auth_background.dart';
import 'success_screen.dart';

final gantiPasswordLoadingProvider = StateProvider<bool>((ref) => false);
final gantiPasswordErrorProvider = StateProvider<String?>((ref) => null);

class GantiPasswordScreen extends ConsumerStatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  ConsumerState<GantiPasswordScreen> createState() =>
      _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends ConsumerState<GantiPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = estimatePasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveNewPassword() async {
    ref.read(gantiPasswordErrorProvider.notifier).state = null;

    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ref.read(gantiPasswordErrorProvider.notifier).state =
          'Password baru dan konfirmasi password tidak boleh kosong.';
      return;
    }

    if (newPassword.length < 8) {
      ref.read(gantiPasswordErrorProvider.notifier).state =
          'Password baru minimal harus 8 karakter.';
      return;
    }

    if (newPassword != confirmPassword) {
      ref.read(gantiPasswordErrorProvider.notifier).state =
          'Konfirmasi password tidak sama dengan password baru.';
      return;
    }

    ref.read(gantiPasswordLoadingProvider.notifier).state = true;

    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(gantiPasswordErrorProvider.notifier).state = _authErrorMessage(
        e.message,
      );
    } on SocketException {
      if (!mounted) return;
      ref.read(gantiPasswordErrorProvider.notifier).state =
          'Tidak dapat terhubung ke jaringan. Periksa koneksi internet Anda.';
    } catch (_) {
      if (!mounted) return;
      ref.read(gantiPasswordErrorProvider.notifier).state =
          'Terjadi kesalahan saat menyimpan password baru. Coba lagi.';
    } finally {
      if (mounted) {
        ref.read(gantiPasswordLoadingProvider.notifier).state = false;
      }
    }
  }

  String _authErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('session') || lower.contains('jwt')) {
      return 'Sesi pemulihan sudah berakhir. Ulangi proses lupa password.';
    }
    if (lower.contains('password')) {
      return 'Password baru belum memenuhi ketentuan keamanan.';
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket')) {
      return 'Tidak dapat terhubung ke jaringan. Periksa koneksi internet Anda.';
    }
    return message.isNotEmpty
        ? message
        : 'Gagal menyimpan password baru. Coba lagi.';
  }

  Widget _buildPasswordStrengthIndicator() {
    String label = '';
    Color barColor = Colors.red;

    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_passwordStrength < 0.34) {
      label = 'Tidak Aman';
      barColor = Colors.red;
    } else if (_passwordStrength < 0.67) {
      label = 'Sedang';
      barColor = Colors.orange;
    } else {
      label = 'Aman';
      barColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _passwordStrength * MediaQuery.of(context).size.width * 0.55,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: barColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(gantiPasswordLoadingProvider);
    final errorMessage = ref.watch(gantiPasswordErrorProvider);

    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF0D52A1),
                    ),
                  ),
                  Text(
                    'Ganti Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D52A1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(
                        Icons.password_outlined,
                        size: 52,
                        color: Color(0xFF0D52A1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Buat Password Baru',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Gunakan minimal 8 karakter agar akunmu tetap aman.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('PASSWORD BARU'),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: _passwordController,
                      hint: 'Minimal 8 karakter',
                      obscureText: _isPasswordHidden,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      onToggle: () => setState(
                        () => _isPasswordHidden = !_isPasswordHidden,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 12),
                    _buildLabel('KONFIRMASI PASSWORD BARU'),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Ulangi password baru',
                      obscureText: _isConfirmPasswordHidden,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!isLoading) _saveNewPassword();
                      },
                      onToggle: () => setState(
                        () => _isConfirmPasswordHidden =
                            !_isConfirmPasswordHidden,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBox(message: errorMessage),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveNewPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D52A1),
                          disabledBackgroundColor: const Color(
                            0xFF0D52A1,
                          ).withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Simpan Password Baru',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }
}

class ResetPasswordScreen extends GantiPasswordScreen {
  const ResetPasswordScreen({super.key});
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscureText,
    required this.enabled,
    required this.textInputAction,
    required this.onToggle,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D52A1)),
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
