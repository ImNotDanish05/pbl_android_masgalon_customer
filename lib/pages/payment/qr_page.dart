import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../widgets/general_app_bar.dart';
import '../../widgets/custombutton.dart';

class TopUpQrPage extends StatelessWidget {
  const TopUpQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Latar sedikit keabuan seperti desain
      appBar: const GeneralAppBar(title: 'Top Up Saldo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. QR Code Area (Bisa diganti image asset atau package qr_flutter nanti)
            Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              // Dummy icon QR Code
              child: const Icon(
                Icons.qr_code_2,
                size: 200,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 32),

            // 2. Kotak Cara Pembayaran
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9), // Abu-abu sedikit kebiruan
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cara Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Looping instruksi dari file dummy
                  ...DummyData.paymentInstructions.map((instruction) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 8), // Indentasi
                          Expanded(
                            child: Text(
                              instruction,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textGrey,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      // 3. Tombol Melayang di Bawah
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'Sudah Bayar, Unggah Bukti',
                icon: Icons.upload_file, // Ikon opsional
                onPressed: () {
                  // Lanjut ke halaman Upload Bukti
                  // context.pushNamed('upload-receipt');
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
                child: Text(
                  'Kembali',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
