import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/shared/rupiah_format.dart'; 
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/shared/custombutton.dart';

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const PaymentSuccessPage({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari transactionData
    final int totalBayar = transactionData['totalBayar'] ?? 0;
    final String paymentMethod = transactionData['metodePembayaran'] ?? '-';
    final String deliveryType = transactionData['tipePengiriman'] ?? '-';
    
    // Bikin format tanggal hari ini secara manual (tanpa package tambahan)
    final now = DateTime.now();
    final String paymentDate = '${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GeneralAppBar(
        title: 'Konfirmasi Pembayaran',
        leadingIcon: Icons.close, 
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        onBackPressed: () => context.goNamed('home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.darkBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 80),
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Pembayaran Berhasil!',
              style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Terima kasih! Pesanan Anda sedang diproses dan akan segera diantar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey.withOpacity(0.8)),
              ),
            ),

            const SizedBox(height: 40),

            // 3. Kartu Detail Transaksi (Sudah pakai data asli)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DETAIL TRANSAKSI',
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textGrey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'Lunas',
                          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('ID Pesanan', 'Diproses'), // ID diset diproses dulu karena nunggu dari DB
                  _buildInfoRow('Metode Pembayaran', paymentMethod), // 👈 Pakai data asli
                  _buildInfoRow('Tanggal', paymentDate), // 👈 Tanggal otomatis hari ini
                  const Divider(height: 32, thickness: 1, color: Color(0xFFF3F4F6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Bayar', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                      Text(
                        totalBayar.toRupiah, // 👈 Pakai data asli
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Kartu Info Pengantaran (Sudah pakai data asli)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, color: Colors.white, size: 30),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deliveryType, // 👈 Pakai data asli
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      Text(
                        'Menunggu konfirmasi kurir', // Subtitle disesuaikan
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 5. Tombol Aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Lacak Pesanan',
                    icon: Icons.local_shipping_outlined,
                    onPressed: () => context.pushNamed('track-order'),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Kembali ke Beranda',
                    isOutlined: true,
                    onPressed: () => context.goNamed('home'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}