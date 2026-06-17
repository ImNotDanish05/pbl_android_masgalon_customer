import 'package:go_router/go_router.dart';

import '../pages/auth/login_page.dart';
import '../pages/auth/registrasi.dart';
import '../pages/auth/lupa_password.dart';
import '../pages/auth/login_token_verifikasi.dart';
import '../pages/auth/registrasi_token_verifikasi.dart';
import '../pages/auth/ganti_password.dart';
import '../pages/auth/success_screen.dart';
import '../pages/home/home_page.dart';
import '../pages/order/detail_orders.dart';
import '../pages/order/history_order.dart';
import '../pages/order/orders_page.dart';
import '../pages/order/checkout_page.dart';
import '../pages/order/confirm_orders.dart';
import '../pages/order/succes_confirm.dart';
import '../pages/payment/upload_saldo.dart';
import '../pages/payment/topup_succes.dart';
import '../pages/payment/qr_page.dart';
import '../pages/order/track_order_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/address_form_page.dart';
import '../pages/topup/topup_page.dart';
import '../pages/order/voucher_page.dart';
import '../pages/chat/chat_page.dart';
import '../services/supabase_client.dart';
import '../pages/chat/chat_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/register/verify' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/forgot-password/verify' ||
          state.matchedLocation == '/change-password' ||
          state.matchedLocation == '/success';

      // If logged in and on an auth page → redirect to home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }

      // If not logged in and trying to access a protected page → redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // No redirect needed
      return null;
    },
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
        path: '/register/verify',
        name: 'register-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return RegistrasiTokenVerifikasiScreen(
            email: extra['email'] ?? '',
            username: extra['username'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const LupaPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password/verify',
        name: 'forgot-password-verify',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return LoginTokenVerifikasiScreen(email: email);
        },
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const GantiPasswordScreen(),
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
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'edit-address',
        builder: (context, state) => const AddressFormPage(),
      ),
      GoRoute(
        path: '/topup',
        name: 'topup',
        builder: (context, state) => const TopUpPage(),
      ),
      GoRoute(
        path: '/voucher',
        name: 'voucher',
        builder: (context, state) => const VoucherPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      // GoRoute(
      //   path: '/chat/detail',
      //   name: 'chat-detail',
      //   builder: (context, state) => const ChatDetailPage(),
      // ),
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
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessPage(transactionData: data);
        }
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
