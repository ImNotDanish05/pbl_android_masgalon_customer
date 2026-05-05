import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/registrasi.dart';
import 'pages/auth/lupa_password.dart';
import 'pages/auth/token_verifikasi.dart';
import 'pages/auth/ganti_password.dart';
import 'pages/auth/success_screen.dart';
import 'pages/home/home_page.dart';
import 'pages/orders/checkout_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mas Galon',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/token-verification': (context) => const TokenVerificationScreen(),
        '/change-password': (context) => const ResetPasswordScreen(),
        '/success': (context) => const SuccessScreen(),
        '/home': (context) => const HomePage(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}