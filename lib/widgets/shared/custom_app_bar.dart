import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../pages/notification/notification_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? titleIcon;
  final bool showBackButton;
  final bool showNotifications;
  final bool showProfileAvatar;
  final bool showLogo;
  final bool centerTitle;
  final String? profileImageUrl;
  final ImageProvider? profileImageProvider;
  final VoidCallback? onBackPressed;
  final IconData leadingIcon;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? titleWidget;
  final bool? isOnline;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleIcon,
    this.showBackButton = false,
    this.showNotifications = true,
    this.showProfileAvatar = false,
    this.showLogo = true,
    this.centerTitle = false,
    this.profileImageUrl,
    this.profileImageProvider,
    this.onBackPressed,
    this.leadingIcon = Icons.arrow_back,
    this.actions,
    this.backgroundColor = Colors.white,
    this.titleWidget,
    this.isOnline,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: NotificationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final imageProvider =
        profileImageProvider ??
        (profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? NetworkImage(profileImageUrl!)
            : null);

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0.5,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 16,
      leadingWidth: showBackButton ? 50 : 16,
      leading: showBackButton
          ? IconButton(
              icon: Icon(leadingIcon, color: AppColors.darkBlue),
              onPressed:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
            )
          : null,
      title: titleWidget != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[const _AppLogo(), const SizedBox(width: 8)],
                Flexible(child: titleWidget!),
              ],
            )
          : (title != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showLogo) ...[
                        const _AppLogo(),
                        const SizedBox(width: 8),
                      ],
                      if (titleIcon != null) ...[
                        Icon(titleIcon, color: AppColors.darkBlue, size: 22),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          title!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : null),
      actions: [
        ...?actions,
        if (isLoggedIn && showNotifications)
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () => _showNotifications(context),
          ),
        if (showProfileAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                if (isOnline != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline! ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    // Langsung tampilkan SVG-nya tanpa Container lingkaran biru
    return SvgPicture.asset(
      'assets/icons/logo_masgalon.svg',
      height: 36, // Besarkan ukurannya biar proporsional dengan tinggi AppBar
      // width-nya nggak perlu diisi biar dia menyesuaikan otomatis (proporsional)
    );
  }
}