import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  // 1. Fungsi untuk Upload Foto Profil
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Nama file unik, disimpan di folder dengan ID user
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      // Baca file sebagai bytes
      final bytes = await imageFile.readAsBytes();

      // Pastikan bucket 'avatars' sudah ada di Storage dan diset Public
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      // Ambil URL public
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload foto profil: $e');
    }
  }

  // 1b. Fungsi untuk Upload Foto Profil dari Bytes (Web Compatible)
  Future<String> uploadAvatarBytes(Uint8List imageBytes) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Nama file unik, disimpan di folder dengan ID user
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      // Upload bytes langsung
      await _supabase.storage.from('avatars').uploadBinary(
        path,
        imageBytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      // Ambil URL public
      return _supabase.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload foto profil: $e');
    }
  }

  // 2. Fungsi untuk Update Username & Avatar URL di tabel users dan customers
  Future<void> updateCustomerProfile({required String username, String? avatarUrl}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Update tabel USERS (untuk auth & avatar)
      final Map<String, dynamic> usersUpdateData = {
        'username': username,
      };
      if (avatarUrl != null) {
        usersUpdateData['avatar_url'] = avatarUrl;
      }

      await _supabase
          .from('users')
          .update(usersUpdateData)
          .eq('id', userId)
          .eq('role', 'Customer');

      // Update tabel CUSTOMERS (untuk data customer)
      await _supabase
          .from('customers')
          .update({'username': username})
          .eq('user_id', userId);

    } catch (e) {
      throw Exception('Gagal update profil: $e');
    }
  }
}