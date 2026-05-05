import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  void _checkPassword(String value) {
    setState(() {
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSymbol = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    int strengthCount = (_hasUppercase ? 1 : 0) + (_hasNumber ? 1 : 0) + (_hasSymbol ? 1 : 0);
    String strengthText = strengthCount == 0 ? "Lemah" : strengthCount == 1 ? "Sedang" : strengthCount == 2 ? "Kuat" : "Sangat Kuat";
    Color strengthColor = strengthCount <= 1 ? Colors.red : strengthCount == 2 ? Colors.orange : Colors.green;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Atur Ulang Sandi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Atur Ulang\nKeamanan Akun', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2)),
                    const SizedBox(height: 12),
                    Text('Demi keamanan, buat kata sandi baru yang kuat untuk memudahkan akses.', style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                    const SizedBox(height: 24),
                    Text('Kata Sandi Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _isObscure1,
                      onChanged: _checkPassword,
                      decoration: InputDecoration(
                        hintText: 'Min. 8 Karakter',
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure1 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _isObscure1 = !_isObscure1),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('KEKUATAN SANDI', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        Text(strengthText, style: TextStyle(fontSize: 12, color: strengthColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strengthCount >= 1 ? strengthColor : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strengthCount >= 2 ? strengthColor : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(width: 4),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strengthCount == 3 ? strengthColor : Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Konfirmasi Kata Sandi Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _isObscure2,
                      decoration: InputDecoration(
                        hintText: 'Ulangi kata sandi',
                        filled: true,
                        fillColor: Colors.grey[50],
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure2 ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _isObscure2 = !_isObscure2),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildConditionItem('Huruf Besar', _hasUppercase),
                        const SizedBox(width: 8),
                        _buildConditionItem('Angka', _hasNumber),
                        const SizedBox(width: 8),
                        _buildConditionItem('Simbol (@#)', _hasSymbol),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SuccessScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Simpan & Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildConditionItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: isMet ? Colors.green : Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: isMet ? Colors.green : Colors.grey)),
      ],
    );
  }
}
