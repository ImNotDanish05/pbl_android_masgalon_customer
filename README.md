# Mas Galon Customer — Flutter App

## Auth & Session Management

### How login works
1. User inputs email + password
2. `supabase.auth.signInWithPassword()` is called
3. Role is checked from `public.users` table — must be 'Customer'
4. Username & saldo fetched from `public.customers` table
5. All data stored in `authCustomerProvider`

### How session is stored
Supabase automatically persists session token in
SharedPreferences on Android. User stays logged in
even after closing the app.

When app restarts:
1. `main.dart` checks `supabase.auth.currentSession`
2. If session exists → fetch role + customer data
3. Restore to `authCustomerProvider`
4. Navigate to HomePage

### How to use customer data on any page
```dart
// Ambil semua data customer
final customer = ref.watch(authCustomerProvider);

// Ambil username saja
final username = ref.watch(currentUsernameProvider);

// Ambil saldo saja
final saldo = ref.watch(currentSaldoProvider);

// Cek apakah sudah login
final isLoggedIn = ref.watch(isLoggedInProvider);

// Contoh penggunaan
Text('Halo, ${customer?.username}!');
Text('Saldo: Rp ${customer?.saldoAbunemen}');
```

### How to update saldo tanpa login ulang
```dart
// Saat saldo berubah (setelah topup diverifikasi):
final current = ref.read(authCustomerProvider);
if (current != null) {
  ref.read(authCustomerProvider.notifier).state =
    current.copyWith(saldoAbunemen: newSaldo);
}
```

### How to logout
```dart
await supabase.auth.signOut();
ref.read(authCustomerProvider.notifier).state = null;
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginPage()),
  (route) => false,
);
```

## File Structure
```
lib/
├── providers/
│   └── auth_provider.dart     ← AuthCustomer model + providers
├── services/
│   └── supabase_client.dart   ← Supabase client instance
├── pages/
│   ├── auth/
│   │   └── login_page.dart    ← Login screen
│   └── home/
│       └── home_page.dart     ← Home screen (post-login)
└── main.dart                  ← Session restore on startup
```
