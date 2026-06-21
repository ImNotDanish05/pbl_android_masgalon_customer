import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import 'login_token_verifikasi.dart';

final lupaPasswordLoadingProvider = StateProvider<bool>((ref) => false);
final lupaPasswordErrorProvider = StateProvider<String?>((ref) => null);

class LupaPasswordScreen extends ConsumerStatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  ConsumerState<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends ConsumerState<LupaPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendToken() async {
    ref.read(lupaPasswordErrorProvider.notifier).state = null;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ref.read(lupaPasswordErrorProvider.notifier).state =
          'Email tidak boleh kosong.';
      return;
    }

    if (!_isValidEmail(email)) {
      ref.read(lupaPasswordErrorProvider.notifier).state =
          'Format email tidak valid.';
      return;
    }

    ref.read(lupaPasswordLoadingProvider.notifier).state = true;

    try {
      await ref.read(authServiceProvider).sendPasswordReset(email: email);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginTokenVerifikasiScreen(email: email),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(lupaPasswordErrorProvider.notifier).state = _authErrorMessage(
        e.message,
      );
    } on SocketException {
      if (!mounted) return;
      ref.read(lupaPasswordErrorProvider.notifier).state =
          'Tidak dapat terhubung ke jaringan. Periksa koneksi internet Anda.';
    } catch (_) {
      if (!mounted) return;
      ref.read(lupaPasswordErrorProvider.notifier).state =
          'Terjadi kesalahan saat mengirim token. Coba lagi.';
    } finally {
      if (mounted) {
        ref.read(lupaPasswordLoadingProvider.notifier).state = false;
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _authErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('user not found') ||
        lower.contains('not found') ||
        lower.contains('invalid login')) {
      return 'Email tidak ditemukan. Pastikan email sudah terdaftar.';
    }
    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('socket')) {
      return 'Tidak dapat terhubung ke jaringan. Periksa koneksi internet Anda.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return message.isNotEmpty
        ? message
        : 'Gagal mengirim token pemulihan. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(lupaPasswordLoadingProvider);
    final errorMessage = ref.watch(lupaPasswordErrorProvider);

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
                    'Lupa Password',
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
                        Icons.lock_reset_outlined,
                        size: 52,
                        color: Color(0xFF0D52A1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Lupa Kata Sandi?',
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
                        'Masukkan email akunmu untuk mendapatkan token reset password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('EMAIL'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isLoading) _sendToken();
                      },
                      decoration: _inputDecoration(
                        hint: 'Contoh: customer@email.com',
                        icon: Icons.email_outlined,
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
                        onPressed: isLoading ? null : _sendToken,
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
                                'Kirim Token',
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}

class ForgotPasswordScreen extends LupaPasswordScreen {
  const ForgotPasswordScreen({super.key});
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
