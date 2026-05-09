import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'ganti_password.dart';

class TokenVerificationScreen extends StatefulWidget {
  const TokenVerificationScreen({super.key});

  @override
  State<TokenVerificationScreen> createState() =>
      _TokenVerificationScreenState();
}

class _TokenVerificationScreenState extends State<TokenVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // @override
  // void initState() {
  //   super.initState();
  //   for (var i = 0; i < _focusNodes.length; i++) {
  //     _focusNodes[i].addListener(() {
  //       if (_focusNodes[i].hasFocus) {
  //         final firstEmpty = _controllers.indexWhere(
  //           (controller) => controller.text.isEmpty,
  //         );
  //         if (firstEmpty >= 0 && firstEmpty < i) {
  //           FocusScope.of(context).requestFocus(_focusNodes[firstEmpty]);
  //         }
  //       }
  //     });
  //   }
  // }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
  if (value.isEmpty) return;

  final firstEmpty = _controllers.indexWhere(
    (controller) => controller.text.isEmpty,
  );

  if (firstEmpty != -1 && index > firstEmpty) {
    _controllers[index].clear();
    return;
  }

  if (value.length > 1) {
    final chars = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    for (var offset = 0;
        offset < chars.length && index + offset < _controllers.length;
        offset++) {
      _controllers[index + offset].text = chars[offset];
    }

    final nextIndex =
        (index + chars.length).clamp(0, _controllers.length - 1);
    FocusScope.of(context).requestFocus(_focusNodes[nextIndex]);
    return;
  }

  if (index + 1 < _focusNodes.length) {
    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
  } else {
    _focusNodes[index].unfocus();
  }
} // ← INI WAJIB ADA

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkBlue,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Verifikasi Token',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: AppColors.darkBlue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verifikasi Token',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Masukkan 6 digit token yang sudah dikirim ke email Anda untuk melanjutkan pengaturan ulang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 48,
                          height: 60,
                          child: KeyboardListener(
                            focusNode:
                                FocusNode(), // Focus node ekstra untuk mendeteksi event keyboard
                            onKeyEvent: (KeyEvent event) {
                              // Deteksi jika tombol ditekan (bukan dilepas) dan tombol itu adalah Backspace
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.backspace) {
                                if (_controllers[index].text.isNotEmpty) {
                                  // Hapus isi di box sekarang
                                  _controllers[index].clear();
                                } else if (index > 0) {
                                  // Pindah ke kiri dan hapus
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_focusNodes[index - 1]);
                                  _controllers[index - 1].clear();
                                }
                              }
                            },
                            child: TextFormField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]'),
                                ),
                              ],
                              maxLength: 1,
                              textInputAction: index < 5
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ),
                              onTap: () {},
                              onChanged: (value) => _onChanged(value, index),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Verifikasi Token',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak menerima kode?',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Kirim Ulang Kode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
