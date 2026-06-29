import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_client.dart';
import 'providers/auth_provider.dart';
import 'route/routes.dart';
import 'services/notification/notification_service.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
const _requiredEnvKeys = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? envError;
  try {
    await dotenv.load(fileName: '.env');
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

  if (envError != null) {
    runApp(_EnvErrorApp(message: envError!));
    return;
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.init(navigatorKey);
  } catch (e, st) {
    debugPrint('? Firebase/Notification init gagal: $e');
    debugPrint('$st');
  }

  runApp(const ProviderScope(child: MyApp()));
}

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
