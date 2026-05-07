import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    // Logika menentukan warna berdasarkan kata kunci status
    final statusUpper = status.toUpperCase();

    if (statusUpper.contains('SELESAI')) {
      bgColor = const Color(0xFFDCFCE7); // Hijau muda
      textColor = const Color(0xFF166534); // Hijau tua
    } else if (statusUpper.contains('BATAL')) {
      bgColor = const Color(0xFFFEE2E2); // Merah muda
      textColor = const Color(0xFF991B1B); // Merah tua
    } else if (statusUpper.contains('KIRIM') || statusUpper.contains('PROSES')) {
      bgColor = const Color(0xFFFFEDD5); // Oranye muda
      textColor = const Color(0xFFEA580C); // Oranye tua
    } else {
      // Default (Misal: AKTIF / PENDING)
      bgColor = AppColors.lightBlue;
      textColor = AppColors.primaryBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Bentuk pil (melengkung penuh)
      ),
      child: Text(
        statusUpper,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}