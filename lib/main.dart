import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'route/routes.dart';

// ─────────────────────────────────────────────────────────────
// Required keys that MUST be present in .env
// ─────────────────────────────────────────────────────────────
const _requiredEnvKeys = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Try to load .env ──────────────────────────────────
  String? envError;
  try {
    await dotenv.load(fileName: '.env');

    // ── 2. Validate required keys are not empty ────────────
    for (final key in _requiredEnvKeys) {
      final value = dotenv.env[key];
      if (value == null || value.trim().isEmpty) {
        envError =
            'Key "$key" tidak ditemukan atau kosong di file .env.\n\n'
            'Pastikan file .env berisi:\n'
            'SUPABASE_URL=https://xxxx.supabase.co\n'
            'SUPABASE_ANON_KEY=eyJhbGci...';
        break;
      }
    }
  } catch (e) {
    envError =
        'File .env tidak ditemukan!\n\n'
        'Buat file .env di root project (sejajar pubspec.yaml) '
        'dengan isi:\n\n'
        'SUPABASE_URL=https://xxxx.supabase.co\n'
        'SUPABASE_ANON_KEY=eyJhbGci...\n\n'
        'Lalu jalankan ulang aplikasi.';
  }

  // ── 3. If .env is broken → show error app, stop here ────
  if (envError != null) {
    runApp(_EnvErrorApp(message: envError!));
    return;
  }

  // ── 4. Init Supabase ────────────────────────────────────
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

// ─────────────────────────────────────────────────────────────
// Error app shown when .env is missing or incomplete
// ─────────────────────────────────────────────────────────────
class _EnvErrorApp extends StatelessWidget {
  final String message;
  const _EnvErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mas Galon — Config Error',
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF1F1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 52,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Konfigurasi Tidak Lengkap',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Setelah membuat file .env, jalankan ulang aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main app (only reached when .env is valid)
// ─────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mas Galon',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D52A1),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: AppRouter.router,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Startup: session check lives in GoRouter redirect (see routes.dart)
// This splash widget is shown at /startup before the redirect fires
// ─────────────────────────────────────────────────────────────
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
      // Restore ke provider using notifier
      await ref.read(authCustomerProvider.notifier).restoreSession(session);

      final restoredCustomer = ref.read(authCustomerProvider);
      if (restoredCustomer == null) {
        _goToLogin();
        return;
      }

      debugPrint('========================================');
      debugPrint('🔄 SESSION RESTORED');
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
