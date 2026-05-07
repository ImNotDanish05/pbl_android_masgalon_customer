import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/dummy_track.dart';

class EstimateCard extends StatelessWidget {
  const EstimateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Margin diatur agar rapi di atas layar
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      // Padding diperkecil agar tingginya ringkas seperti CustomButton
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
          // Ikon Jam
          Container(
            padding: const EdgeInsets.all(
              10,
            ), // Padding ikon dikecilkan sedikit
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

          // Waktu Estimasi
          Expanded(
            child: Column(
              // 🔴 INI KUNCI UTAMANYA: Mencegah kotak melar ke bawah
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
                  TrackOrderDummy.estimateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),

          // Garis Pembatas
          Container(
            height: 36, // Tinggi garis dibatasi secara eksplisit
            width: 1,
            color: Colors.grey.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Jarak
          Column(
            // 🔴 KUNCI UTAMA JUGA DI SINI
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
                TrackOrderDummy.distance,
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
