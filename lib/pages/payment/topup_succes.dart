import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../widgets/shared/general_app_bar.dart';

class TopUpSuccessPage extends StatelessWidget {
  const TopUpSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background terang
      appBar: GeneralAppBar(
        title: 'Konfirmasi Pembayaran',
        leadingIcon: Icons.close,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        onBackPressed: () => context.goNamed('home'),
      ),
      body: Center(
        // Menggunakan Center agar konten tepat di tengah layar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Ikon Centang Biru Besar
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),

              const SizedBox(height: 32),

              // 2. Judul
              Text(
                DummyData.successTitle,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 16),

              // 3. Deskripsi
              Text(
                DummyData.successSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
              ),

              // Ruang kosong untuk mendorong tombol ke bawah
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      // Tombol Kembali ke Beranda murni menggunakan TextButton
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: TextButton(
            onPressed: () => context.goNamed('home'), // Kembali ke menu utama
            child: Text(
              'Kembali ke Beranda',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
