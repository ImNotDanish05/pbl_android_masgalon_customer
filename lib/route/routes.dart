import 'package:go_router/go_router.dart';

// Import semua halaman Auth
import '../pages/auth/login_page.dart';
import '../pages/auth/registrasi.dart';
import '../pages/auth/lupa_password.dart';
import '../pages/auth/token_verifikasi.dart';
import '../pages/auth/ganti_password.dart';
import '../pages/auth/success_screen.dart';
import '../pages/home/home_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Halaman pertama kali aplikasi dibuka
    routes: [
      //Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/token-verification',
        name: 'token-verification',
        builder: (context, state) => const TokenVerificationScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) => const SuccessScreen(),
      ),

      //Dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(), 
      ),
    ],
  );
}