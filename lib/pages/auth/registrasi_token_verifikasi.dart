import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import 'login_page.dart';

final registrasiTokenLoadingProvider = StateProvider<bool>((ref) => false);
final registrasiTokenErrorProvider = StateProvider<String?>((ref) => null);

class RegistrasiTokenVerifikasiScreen extends ConsumerStatefulWidget {
  final String email;
  final String username;

  const RegistrasiTokenVerifikasiScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  ConsumerState<RegistrasiTokenVerifikasiScreen> createState() =>
      _RegistrasiTokenVerifikasiScreenState();
}

class _RegistrasiTokenVerifikasiScreenState
    extends ConsumerState<RegistrasiTokenVerifikasiScreen>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(8, (_) => TextEditingController());
    _focusNodes = List.generate(8, (_) => FocusNode());

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 24,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _startResendTimer();

    // Fokus ke kotak pertama saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyToken() async {
    ref.read(registrasiTokenErrorProvider.notifier).state = null;

    final token = _controllers.map((controller) => controller.text).join();
    if (token.length != 8) {
      ref.read(registrasiTokenErrorProvider.notifier).state =
          'Masukkan 8 digit kode verifikasi yang dikirim ke email kamu.';
      return;
    }

    ref.read(registrasiTokenLoadingProvider.notifier).state = true;

    try {
      // Verify OTP and create user/customer entries via AuthService
      await ref.read(authServiceProvider).verifyRegisterOtp(
        email: widget.email,
        token: token,
        username: widget.username,
      );

      // Navigate
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email berhasil diverifikasi! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(registrasiTokenErrorProvider.notifier).state = _authErrorMessage(
        e.message,
      );
      _shakeController.forward(from: 0);
      for (final c in _controllers) {
        c.clear();
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNodes[0].requestFocus();
      });

    } on PostgrestException catch (e) {
      if (!mounted) return;
      ref.read(registrasiTokenErrorProvider.notifier).state =
          'Gagal menyimpan data akun. Coba lagi. (${e.message})';
      _shakeController.forward(from: 0);

    } on SocketException {
      if (!mounted) return;
      ref.read(registrasiTokenErrorProvider.notifier).state =
          'Tidak dapat terhubung ke jaringan. Periksa koneksi internet kamu.';
    } catch (_) {
      if (!mounted) return;
      ref.read(registrasiTokenErrorProvider.notifier).state =
          'Terjadi kesalahan saat memverifikasi kode. Coba lagi.';
    } finally {
      if (mounted) {
        ref.read(registrasiTokenLoadingProvider.notifier).state = false;
      }
    }
  }

  String _authErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('expired')) {
      return 'Kode verifikasi sudah kedaluwarsa. Klik kirim ulang.';
    }
    if (lower.contains('invalid') ||
        lower.contains('otp') ||
        lower.contains('token')) {
      return 'Kode verifikasi salah. Periksa kembali emailmu.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return message.isNotEmpty ? message : 'Kode tidak dapat diverifikasi.';
  }

  void _handleOtpChanged(String value, int index) {
    ref.read(registrasiTokenErrorProvider.notifier).state = null;

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _fillPastedToken(digits);
      return;
    }

    if (digits.isEmpty) {
      _controllers[index].clear();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    _controllers[index].text = digits;
    _controllers[index].selection = TextSelection.collapsed(offset: 1);

    if (index == _controllers.length - 1) {
      _focusNodes[index].unfocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _verifyToken();
      });
      return;
    }

    // Loncat ke kotak berikutnya
    _focusNodes[index + 1].requestFocus();
  }

  void _fillPastedToken(String digits) {
    final tokenDigits = digits.substring(0, digits.length.clamp(0, 8));
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < tokenDigits.length ? tokenDigits[i] : '';
    }

    if (tokenDigits.length == 8) {
      _focusNodes.last.unfocus();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _verifyToken();
      });
    } else {
      _focusNodes[tokenDigits.length].requestFocus();
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendToken() async {
    if (!_canResend) return;
    try {
      await ref.read(authServiceProvider).resendRegisterOtp(
        email: widget.email,
      );
      _startResendTimer();
      for (final c in _controllers) {
        c.clear();
      }
      if (mounted) _focusNodes[0].requestFocus();
    } catch (_) {
      if (mounted) {
        ref.read(registrasiTokenErrorProvider.notifier).state =
            'Gagal mengirim ulang kode verifikasi. Coba lagi.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(registrasiTokenLoadingProvider);
    final errorMessage = ref.watch(registrasiTokenErrorProvider);

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
                    'Verifikasi Email',
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
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 52,
                      color: Color(0xFF0D52A1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verifikasi Email Kamu',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kode verifikasi 8 digit telah dikirim ke ${widget.email}. '
                      'Cek inbox atau folder spam kamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value *
                                ((_shakeController.value < 0.5) ? 1 : -1),
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          8, //perubahan jumlah kotak
                          (index) => _OtpBox(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            enabled: !isLoading,
                            onChanged: (value) =>
                                _handleOtpChanged(value, index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _canResend
                          ? TextButton(
                              onPressed: _resendToken,
                              child: const Text(
                                'Kirim Ulang Kode',
                                style: TextStyle(
                                  color: Color(0xFF0D52A1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              'Kirim ulang dalam $_resendCountdown detik',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
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
                        onPressed: isLoading ? null : _verifyToken,
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
                                'Verifikasi Email',
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
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.zero,
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
            borderSide: const BorderSide(color: Color(0xFF0D52A1), width: 1.5),
          ),
        ),
        onChanged: onChanged,
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
