import 'package:go_router/go_router.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/registrasi.dart';
import '../pages/auth/lupa_password.dart';
import '../pages/auth/token_verifikasi.dart';
import '../pages/auth/ganti_password.dart';
import '../pages/auth/success_screen.dart';
import '../pages/home/home_page.dart';
import '../pages/orders/detail_orders.dart';
import '../pages/orders/history-order.dart';
import '../pages/orders/orders_page.dart';
import '../pages/orders/checkout_page.dart';
import '../pages/orders/confirm_orders.dart';
import '../pages/orders/succes_confirm.dart';
import '../pages/payment/upload_saldo.dart';
import '../pages/payment/topup_succes.dart';
import '../pages/payment/qr_page.dart';
import '../pages/orders/track_order_page.dart';

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
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: '/orders/history',
        name: 'order-history',
        builder: (context, state) => const HistoryOrderPage(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/confirm-order',
        name: 'confirm-order',
        builder: (context, state) => const ConfirmOrderPage(),
      ),
      GoRoute(
        path: '/orders/detail',
        name: 'order-detail',
        builder: (context, state) => const OrderDetailPage(),
      ),
      GoRoute(
        path: '/orders-success',
        name: 'orders-success',
        builder: (context, state) => const PaymentSuccessPage(),
      ),
      GoRoute(
        path: '/upload-receipt',
        name: 'upload-receipt',
        builder: (context, state) => const UploadReceiptPage(),
      ),
      GoRoute(
        path: '/topup-success',
        name: 'topup-success',
        builder: (context, state) => const TopUpSuccessPage(),
      ),
      GoRoute(
        path: '/qr-code',
        name: 'qr-code',
        builder: (context, state) => const TopUpQrPage(),
      ),
      GoRoute(
        path: '/track-order',
        name: 'track-order',
        builder: (context, state) => const TrackOrderPage(),
      ),
    ],
  );
}
