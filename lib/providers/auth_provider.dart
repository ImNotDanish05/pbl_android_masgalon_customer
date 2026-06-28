import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth/auth_service.dart';

// Model data customer yang sedang login
class AuthCustomer {
  final String id;
  final String email;
  final String username;
  final int saldoAbunemen;
  final String? avatarUrl;

  const AuthCustomer({
    required this.id,
    required this.email,
    required this.username,
    required this.saldoAbunemen,
    this.avatarUrl,
  });

  // Buat copy dengan nilai yang diupdate
  // (berguna saat saldo berubah tanpa harus login ulang)
  AuthCustomer copyWith({
    String? id,
    String? email,
    String? username,
    int? saldoAbunemen,
    String? avatarUrl,
  }) {
    return AuthCustomer(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      saldoAbunemen: saldoAbunemen ?? this.saldoAbunemen,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Notifier untuk mengelola status auth
class AuthCustomerNotifier extends StateNotifier<AuthCustomer?> {
  final AuthService _authService;

  AuthCustomerNotifier(this._authService) : super(null);

  // Aksi login
  Future<void> login(String email, String password) async {
    final customer = await _authService.signIn(
      email: email,
      password: password,
    );

    // Kalau profile gagal di-fetch → jangan set state
    if (customer == null || customer.id.isEmpty) {
      debugPrint('❌ Login berhasil tapi profile null');
      await _authService.signOut();
      state = null;
      return;
    }
    state = customer;
  }

  // Aksi logout
  Future<void> logout() async {
    await _authService.signOut();
    state = null;
  }

  // Aksi update data customer secara manual
  void updateCustomer(AuthCustomer? customer) {
    state = customer;
  }

  // Aksi update saldo saja
  void updateSaldo(int newSaldo) {
    if (state != null) {
      state = state!.copyWith(saldoAbunemen: newSaldo);
    }
  }

  // Aksi update profil (username & avatar)
  void updateProfile({String? username, String? avatarUrl}) {
    if (state != null) {
      state = state!.copyWith(
        username: username ?? state!.username,
        avatarUrl: avatarUrl ?? state!.avatarUrl,
      );
    }
  }

  // Aksi restore session saat startup
  Future<void> restoreSession(Session session) async {
    try {
      final customer = await _authService.restoreSession(session);

      // Profile null atau ID kosong → paksa logout
      if (customer == null || customer.id.isEmpty) {
        debugPrint('⚠️ Session ada tapi profile null → auto logout');
        await _authService.signOut();
        state = null;
        return;
      }

      state = customer;
      debugPrint('✅ Session restored: ${customer.username}');
    } catch (e) {
      debugPrint('❌ Gagal restore session: $e → auto logout');
      await _authService.signOut();
      state = null;
    }
  }

  // Refresh data dari DB tanpa logout
  Future<void> refreshProfile() async {
    if (state == null) return;
    try {
      final supabase = Supabase.instance.client;
      
      // Fetch data terbaru
      final userData = await supabase
          .from('users')
          .select('avatar_url')
          .eq('id', state!.id)
          .single();

      final customerData = await supabase
          .from('customers')
          .select('username, saldo_abunemen')
          .eq('user_id', state!.id)
          .single();

      // Update state tanpa logout
      state = state!.copyWith(
        username: customerData['username'] as String,
        avatarUrl: userData['avatar_url'] as String?,
        saldoAbunemen: customerData['saldo_abunemen'] != null
            ? int.tryParse(customerData['saldo_abunemen'].toString()) ?? 0
            : 0,
      );
      debugPrint('✅ Profile refreshed: ${state!.username}');
    } catch (e) {
      debugPrint('⚠️ Gagal refresh profile: $e');
      // Jangan logout, biarkan data lama tetap tampil
    }
  }
}

// Provider utama — null berarti belum login
final authCustomerProvider =
    StateNotifierProvider<AuthCustomerNotifier, AuthCustomer?>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthCustomerNotifier(authService);
    });

// Provider helper
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authCustomerProvider) != null;
});

final currentUsernameProvider = Provider<String?>((ref) {
  return ref.watch(authCustomerProvider)?.username;
});

final currentSaldoProvider = Provider<int?>((ref) {
  return ref.watch(authCustomerProvider)?.saldoAbunemen;
});
