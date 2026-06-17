import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: kToolbarHeight,
      child: CustomAppBar(
        title: 'Mas Galon',
        showBackButton: false,
        showNotifications: false,
      ),
    );
  }
}
