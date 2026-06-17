import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/custom_app_bar.dart';
import 'edit_email_page.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  // ── State collapsible password ──
  bool _isPasswordExpanded = false;

  // ── Controllers ──
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // ── Obscure toggle ──
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // ── Form key ──
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submitChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Hubungkan ke Supabase Auth
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil diperbarui!'),
        backgroundColor: Color(0xFF1A56FF),
      ),
    );

    _currentPassCtrl.clear();
    _newPassCtrl.clear();
    _confirmPassCtrl.clear();
    setState(() => _isPasswordExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: 'Keamanan Akun',
        showBackButton: true,
        showNotifications: false,
        centerTitle: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Email ──
            _buildSectionHeader(icon: Icons.email_outlined, label: 'EMAIL'),
            const SizedBox(height: 8),
            _buildEmailCard(),
            const SizedBox(height: 24),

            // ── Section: Keamanan ──
            _buildSectionHeader(icon: Icons.shield_outlined, label: 'KEAMANAN'),
            const SizedBox(height: 8),
            _buildPasswordCard(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Section Header (ikon + label biru)
  // ─────────────────────────────────────────────
  Widget _buildSectionHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1A56FF)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A56FF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Email Card (tampil email + tombol ubah)
  // ─────────────────────────────────────────────
  Widget _buildEmailCard() {
    // 👇 1. Ambil email dari provider
    final customerEmail =
        ref.watch(authCustomerProvider)?.email ?? 'Email tidak ditemukan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 👇 2. Hapus 'const' dan ganti teksnya jadi variabel customerEmail
              Text(
                customerEmail,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangeEmailPage()),
                  );
                },
                child: const Text(
                  'Ubah Email',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A56FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'BELUM DIVERIFIKASI',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFD92D20),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget: Password Card (collapsible)
  // ─────────────────────────────────────────────
  Widget _buildPasswordCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header tombol expand/collapse ──
          InkWell(
            onTap: () =>
                setState(() => _isPasswordExpanded = !_isPasswordExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perbarui Kata Sandi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    _isPasswordExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // ── Form expand ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: _isPasswordExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 16),

                            // Kata Sandi Saat Ini
                            _buildLabel('Kata Sandi Saat Ini'),
                            const SizedBox(height: 6),
                            _buildPasswordField(
                              controller: _currentPassCtrl,
                              hint: '••••••••',
                              obscure: _obscureCurrent,
                              onToggle: () => setState(
                                () => _obscureCurrent = !_obscureCurrent,
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Kata Sandi Baru
                            _buildLabel('Kata Sandi Baru'),
                            const SizedBox(height: 6),
                            _buildPasswordField(
                              controller: _newPassCtrl,
                              hint: '••••••••',
                              obscure: _obscureNew,
                              onToggle: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Wajib diisi';
                                if (v.length < 8) return 'Minimal 8 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Konfirmasi Kata Sandi Baru
                            _buildLabel('Konfirmasi Kata Sandi Baru'),
                            const SizedBox(height: 6),
                            _buildPasswordField(
                              controller: _confirmPassCtrl,
                              hint: '••••••••',
                              obscure: _obscureConfirm,
                              onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Wajib diisi';
                                if (v != _newPassCtrl.text)
                                  return 'Kata sandi tidak cocok';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Lupa Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: navigasi ke halaman lupa password
                                },
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Color(0xFF1A56FF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tombol Simpan
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitChangePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A56FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2),
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
          borderSide: const BorderSide(color: Color(0xFFD92D20)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD92D20)),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.black38,
            size: 18,
          ),
        ),
      ),
    );
  }
}
