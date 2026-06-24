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
    final customer = await _authService.signIn(email: email, password: password);
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
    final customer = await _authService.restoreSession(session);
    state = customer;
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
