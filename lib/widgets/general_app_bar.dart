import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;

  // 1. TAMBAHAN 2 PARAMETER BARU
  final IconData leadingIcon;
  final bool centerTitle;

  const GeneralAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor = Colors.white,
    this.onBackPressed,
    // 2. BERIKAN NILAI DEFAULT
    this.leadingIcon = Icons.arrow_back, // Default tetap panah
    this.centerTitle = false, // Default tetap rata kiri
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle, // 3. MASUKKAN VARIABELNYA KE SINI
      leading: showBackButton
          ? IconButton(
              // 4. UBAH ICON MENJADI DINAMIS
              icon: Icon(leadingIcon, color: AppColors.primaryBlue),
              onPressed:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
        ),
      ),
      actions: actions,
    );
  }
}
