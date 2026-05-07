import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon; // Opsional: Jika butuh ikon
  final bool isOutlined; // Opsional: Ubah jadi true untuk tombol "Kembali ke Beranda"

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    // Logika penentuan warna berdasarkan tipe tombol
    final Color bgColor = isOutlined ? Colors.white : AppColors.primaryBlue;
    final Color textColor = isOutlined ? AppColors.primaryBlue : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 56, // Sesuai dengan ukuran di kodemu
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0, // Dibuat 0 agar flat dan modern
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // Jika isOutlined true, beri garis tepi biru
            side: isOutlined
                ? const BorderSide(color: AppColors.primaryBlue, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan ikon HANYA jika ikonnya diisi
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}