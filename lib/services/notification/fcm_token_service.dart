import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────
// FcmTokenService — Customer App
//
// Tanggung jawab:
//   - Upload FCM token ke tabel `fcm_tokens` di Supabase (upsert)
//   - Hapus token saat user logout (agar notif tidak dikirim ke device lama)
//
// Cara pakai:
//   Panggil uploadToken() setelah login sukses.
//   Panggil deleteToken() sebelum logout.
// ─────────────────────────────────────────────────────────────

class FcmTokenService {
  FcmTokenService._();

  static final _supabase = Supabase.instance.client;

  // ── Upload / upsert token ke Supabase ───────────────────────
  // Upsert berdasarkan (user_id, token) — aman dipanggil berkali-kali.
  static Future<void> uploadToken(String userId, String token) async {
    try {
      await _supabase.from('fcm_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': 'android',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token', // kolom unique constraint
      );
    } catch (e) {
      // Tidak crash app jika upload gagal — notifikasi tidak kritis
      debugPrint('[FCM] Gagal upload token: $e');
    }
  }

  // ── Hapus token saat logout ──────────────────────────────────
  static Future<void> deleteToken(String token) async {
    try {
      await _supabase.from('fcm_tokens').delete().eq('token', token);
    } catch (e) {
      debugPrint('[FCM] Gagal hapus token: $e');
    }
  }
}

// ignore: avoid_print
void debugPrint(String message) => print(message);
