import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon; // Tambahan parameter ikon (opsional)
  final String? actionText; // Teks tombol kanan bisa di-custom (opsional)
  final VoidCallback? onActionTap; // Pengganti onLihatSemua

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Jika ada icon, tampilkan di sebelah kiri
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.textDark), // Warna ikon bisa kamu sesuaikan
              const SizedBox(width: 8),
            ],
            
            // 2. Expanded pada title agar teks panjang tidak error (overflow)
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16, // Sedikit dikecilkan ke 16 agar pas jika berdampingan dengan icon
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
            ),

            // 3. Jika actionText & onActionTap diisi, tampilkan tombol aksi
            if (actionText != null && onActionTap != null)
              TextButton(
                onPressed: onActionTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerRight,
                ),
                child: Text(
                  actionText!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
          ],
        ),
        
        // 4. Jika ada subtitle, tampilkan di bawah judul
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            // Agar sejajar dengan judul, beri jarak kiri ekstra jika ada ikon
            padding: EdgeInsets.only(left: icon != null ? 28.0 : 0.0),
            child: Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textGrey,
              ),
            ),
          ),
        ],
      ],
    );
  }
}