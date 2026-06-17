import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_app_bar.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final VoidCallback? onBackPressed;
  final IconData leadingIcon;
  final bool centerTitle;
  final bool showNotifications;

  const GeneralAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor = Colors.white,
    this.onBackPressed,
    this.leadingIcon = Icons.arrow_back,
    this.centerTitle = false,
    this.showNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: showBackButton,
      showNotifications: showNotifications,
      leadingIcon: leadingIcon,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      actions: actions,
      onBackPressed:
          onBackPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            }
          },
      titleWidget: null,
    );
  }
}
