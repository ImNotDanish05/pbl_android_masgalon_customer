import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../route/routes.dart';
import '../../services/supabase_client.dart';

class StartupPage extends ConsumerStatefulWidget {
  const StartupPage({super.key});

  @override
  ConsumerState<StartupPage> createState() => StartupPageState();
}

class StartupPageState extends ConsumerState<StartupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final session = supabase.auth.currentSession;

    if (session == null) {
      _goToLogin();
      return;
    }

    try {
      await ref.read(authCustomerProvider.notifier).restoreSession(session);

      final restoredCustomer = ref.read(authCustomerProvider);
      if (restoredCustomer == null) {
        _goToLogin();
        return;
      }

      debugPrint('========================================');
      debugPrint('✅ SESSION RESTORED');
      debugPrint('ID       : ${restoredCustomer.id}');
      debugPrint('Email    : ${restoredCustomer.email}');
      debugPrint('Username : ${restoredCustomer.username}');
      debugPrint('Saldo    : ${restoredCustomer.saldoAbunemen}');
      debugPrint('========================================');

      if (!mounted) return;
      AppRouter.router.go('/home');
    } catch (_) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    AppRouter.router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF0D52A1))),
    );
  }
}
