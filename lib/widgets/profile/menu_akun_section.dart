import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/profile/security_page.dart';

class MenuAkunSection extends StatelessWidget {
  final VoidCallback onKeluar;
  final VoidCallback onTap;

  const MenuAkunSection({
    super.key,
    required this.onKeluar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Akun',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Riwayat Transaksi
        _MenuItem(
          icon: Icons.history,
          iconBgColor: const Color(0xFFEBF2FF),
          iconColor: const Color(0xFF0D52A1),
          title: 'Riwayat Transaksi',
          subtitle: 'Lihat semua pesanan sebelumnya',
          onTap: onTap,
          showArrow: true,
        ),
        const SizedBox(height: 10),

        // 👇 MENU KEAMANAN AKUN (Gabungan Email & Password) 👇
        _MenuItem(
          icon: Icons.shield_outlined,
          iconBgColor: const Color(0xFFE5F7ED), // Warna hijau soft
          iconColor: const Color(0xFF4CAF50),
          title: 'Keamanan Akun',
          subtitle: 'Ubah email dan perbarui kata sandi Anda',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecurityPage()),
            );
          },
          showArrow: true,
        ),
        const SizedBox(height: 10),

        // Keluar
        _MenuItem(
          icon: Icons.logout,
          iconBgColor: const Color(0xFFFFEBEB),
          iconColor: Colors.redAccent,
          title: 'Keluar',
          titleColor: Colors.redAccent,
          onTap: onKeluar,
          showArrow: false,
        ),
      ],
    );
  }
}

// Widget _MenuItem tidak ada yang diubah, tetap pakai punyamu
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _MenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.subtitle,
    required this.onTap,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
