import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart'; // 👈 1. Jangan lupa import modelnya

class StatusBadge extends StatelessWidget {
  final OrderStatus status; // 👈 2. Ubah tipe datanya menjadi OrderStatus

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String statusText;

    // 3. Logika menentukan warna dan teks menggunakan Switch
    // Ini dijamin 100% aman karena Flutter akan protes kalau ada status yang terlewat!
    switch (status) {
      case OrderStatus.selesai:
        bgColor = const Color(0xFFDCFCE7); // Hijau muda
        textColor = const Color(0xFF166534); // Hijau tua
        statusText = 'SELESAI';
        break;
      case OrderStatus.tolak:
        bgColor = const Color(0xFFFEE2E2); // Merah muda
        textColor = const Color(0xFF991B1B); // Merah tua
        statusText = 'DITOLAK';
        break;
      case OrderStatus.diantar:
        bgColor = const Color(0xFFFFEDD5); // Oranye muda
        textColor = const Color(0xFFEA580C); // Oranye tua
        statusText = 'DIANTAR';
        break;
      case OrderStatus.mencariKurir:
        bgColor = AppColors.lightBlue;
        textColor = AppColors.primaryBlue;
        statusText = 'MENCARI KURIR';
        break;
      case OrderStatus.menungguKurir:
        bgColor = AppColors.lightBlue;
        textColor = AppColors.primaryBlue;
        statusText = 'MENUNGGU KURIR';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Bentuk pil (melengkung penuh)
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}