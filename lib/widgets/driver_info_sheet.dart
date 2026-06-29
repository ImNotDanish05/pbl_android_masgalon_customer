import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/order_model.dart'; // 👈 Import Model
import 'shared/rupiah_format.dart';

class DriverInfoSheet extends StatelessWidget {
  final Map<String, dynamic> detailData; // Untuk isi data layar
  final OrderModel order; // Untuk dilempar saat tombol Rincian diklik

  const DriverInfoSheet({
    super.key,
    required this.detailData,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Ekstrak Data Kurir
    final courierData = detailData['couriers'];
    final userData = courierData != null ? courierData['users'] : null;
    final driverName =
        userData?['username'] ??
        courierData?['nama_asli'] ??
        'Mencari Kurir...';
    final avatarUrl = userData?['avatar_url']?.toString() ?? '';
    final isKurirAda = courierData != null;

    // 2. Ekstrak Data Pesanan
    final itemsData = detailData['order_items'] as List<dynamic>? ?? [];
    // Menggabungkan semua nama produk menjadi 1 kalimat (Contoh: "Galon, Gas 3kg")
    String orderItemNames = itemsData
        .map((item) => item['products']['nama'])
        .join(', ');
    if (orderItemNames.isEmpty) orderItemNames = 'Pesanan';

    final totalHarga = (detailData['total_harga'] as num?)?.toInt() ?? 0;
    final statusText = (detailData['status']?.toString() ?? '')
        .replaceAll('_', ' ')
        .toUpperCase();
    final metodePembayaran = detailData['metode_pembayaran'] ?? 'Tunai';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Profil Driver
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.lightBlue,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: AppColors.primaryBlue)
                        : null,
                  ),
                  if (isKurirAda) // Hanya munculkan titik hijau kalau kurirnya sudah ada
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      isKurirAda ? 'Kurir Mas Galon' : 'Sistem',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Kotak Info (Isi Pesanan & Status Kurir)
          Row(
            children: [
              _buildInfoBox(
                icon: Icons.inventory_2_outlined,
                title: 'ISI PESANAN',
                content: orderItemNames,
                subContent:
                    'Total: ${totalHarga.toRupiah}', // Pastikan ekstensi .toRupiah ini ada di file rupiah_format.dart
              ),
              const SizedBox(width: 16),
              _buildInfoBox(
                icon: Icons.local_shipping_outlined,
                title: 'STATUS KURIR',
                content: statusText,
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFF3F4F6), thickness: 1.5),
          ),

          // 3. Footer Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'METODE PEMBAYARAN',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        metodePembayaran,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // 👇 Pindah ke detail sambil bawa tas ekstra
                  context.push('/orders/detail', extra: order);
                },
                child: Text(
                  'Rincian Pesanan >',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk kotak info abu-abu
  Widget _buildInfoBox({
    required IconData icon,
    required String title,
    required String content,
    String? subContent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primaryBlue),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              maxLines:
                  1, // Agar nama barang tidak merusak layout jika kepanjangan
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (subContent != null) ...[
              const SizedBox(height: 8),
              Text(
                subContent,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
