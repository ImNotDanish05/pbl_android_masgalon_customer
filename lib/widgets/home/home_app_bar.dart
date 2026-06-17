import '../shared/custom_app_bar.dart';

class MainAppBar extends CustomAppBar {
  const MainAppBar({super.key, bool showNotifications = true})
    : super(
        title: 'Mas Galon',
        showBackButton: false,
        showNotifications: showNotifications,
      );
}
