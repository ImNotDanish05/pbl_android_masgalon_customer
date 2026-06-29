import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';

class EstimateCard extends StatelessWidget {
  final Map<String, dynamic> detailData; // 👈 Tambahkan penangkap data
  final LatLng? courierLocation;
  final LatLng? targetLocation;

  const EstimateCard({
    super.key,
    required this.detailData,
    this.courierLocation,
    this.targetLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Mengecek status pesanan untuk menyesuaikan estimasi
    final status = detailData['status']?.toString() ?? '';
    String estimasiWaktu = 'Menunggu Kurir';
    String estimasiJarak = '-';

    if (status == 'Diantar') {
      if (courierLocation != null && targetLocation != null) {
        final double distanceInMeters =
            const Distance().distance(courierLocation!, targetLocation!);

        if (distanceInMeters < 1000) {
          estimasiJarak = '± ${distanceInMeters.round()} m';
        } else {
          estimasiJarak =
              '± ${(distanceInMeters / 1000).toStringAsFixed(1)} KM';
        }

        // Estimasi waktu: asumsi kecepatan rata-rata motor di pemukiman 24km/jam (~400 meter per menit)
        final int minutes = (distanceInMeters / 400).round();
        if (minutes < 1) {
          estimasiWaktu = 'Hampir Sampai';
        } else {
          estimasiWaktu = '$minutes - ${minutes + 2} Menit';
        }
      } else {
        estimasiWaktu = 'Sedang Jalan';
        estimasiJarak = '-';
      }
    } else if (status == 'Selesai') {
      estimasiWaktu = 'Telah Tiba';
      estimasiJarak = '0 KM';
    }

    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time_filled,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMASI KEDATANGAN',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
                Text(
                  estimasiWaktu, // 👈 Pakai variabel dinamis
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'JARAK',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                estimasiJarak, // 👈 Pakai variabel dinamis
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
