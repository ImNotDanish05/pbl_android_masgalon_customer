import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/shared/custom_app_bar.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  // ── Controllers ──
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── OTP: 6 field terpisah ──
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // ── State ──
  bool _tokenSent = false;
  bool _isLoadingSend = false;
  bool _isLoadingVerify = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  // ── Kirim token ke email baru ──
  Future<void> _sendToken() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoadingSend = true);

    // TODO: Supabase kirim OTP ke email baru
    await Future.delayed(const Duration(seconds: 1)); // simulasi

    setState(() {
      _isLoadingSend = false;
      _tokenSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Token dikirim ke ${_emailCtrl.text}'),
        backgroundColor: const Color(0xFF1A56FF),
      ),
    );
  }

  // ── Verifikasi token 6 digit ──
  Future<void> _verifyToken() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 6 digit token terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoadingVerify = true);

    // TODO: Supabase verifyOtp
    await Future.delayed(const Duration(seconds: 1)); // simulasi

    setState(() => _isLoadingVerify = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email berhasil diubah!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  // ── Kirim ulang token ──
  void _resendToken() {
    for (final c in _otpCtrls) c.clear();
    _otpFocusNodes[0].requestFocus();
    _sendToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: 'Ubah Email',
        showBackButton: true,
        showNotifications: false,
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Header section ──
            Row(
              children: const [
                Icon(Icons.email_outlined, size: 16, color: Color(0xFF1A56FF)),
                SizedBox(width: 6),
                Text(
                  'UBAH EMAIL',
                  style: TextStyle(
                    color: Color(0xFF1A56FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Card form ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Input email baru ──
                    const Text(
                      'Email Baru',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Masukkan email baru',
                        hintStyle: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF0F0F0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD92D20),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A56FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
                        if (!emailRegex.hasMatch(v))
                          return 'Format email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Tombol Kirim Token ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoadingSend ? null : _sendToken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A56FF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF1A56FF,
                          ).withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoadingSend
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _tokenSent
                                    ? 'Kirim Ulang Token'
                                    : 'Kirim Token',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (_tokenSent) ...[
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      const SizedBox(height: 24),

                      // ── Input OTP 6 digit ──
                      const Text(
                        'Token 6-Digit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildOtpFields(),
                      const SizedBox(height: 20),

                      // ── Tombol Verifikasi Token ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoadingVerify ? null : _verifyToken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A56FF),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF1A56FF,
                            ).withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoadingVerify
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Verifikasi Token',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Kirim ulang ──
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Tidak menerima kode?',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _resendToken,
                              child: const Text(
                                'Kirim Ulang token',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1A56FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: 6 kotak OTP terpisah
  // ─────────────────────────────────────────────
  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          height: 52,
          child: TextFormField(
            controller: _otpCtrls[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF0F0F0),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1A56FF),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                // Auto-focus ke kotak berikutnya
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                // Backspace → kembali ke kotak sebelumnya
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
