import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Provider utama — null berarti belum login
final authCustomerProvider = StateProvider<AuthCustomer?>((ref) => null);

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
