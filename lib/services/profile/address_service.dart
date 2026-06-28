import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile_model.dart';

class AddressService {
  final _supabase = Supabase.instance.client;

  // ==========================================
  // 1. READ (Ambil Daftar Alamat Milik User Ini)
  // ==========================================
  Future<List<AddressModel>> ambilDaftarAlamat() async {
    try {
      final userId = _supabase.auth.currentUser!.id; // Ambil ID user yang login

      final response = await _supabase
          .from('customer_addresses')
          .select('*')
          .eq('customer_id', userId)
          .order(
            'is_main',
            ascending: false,
          ); // Urutkan: Yang utama taruh paling atas!

      // Masak JSON jadi List<AddressModel>
      return response.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data alamat: $e');
    }
  }

  // ==========================================
  // 2. CREATE (Tambah Alamat Baru)
  // ==========================================
  Future<void> tambahAlamat({
    required String label,
    required String detail,
    required double lat,
    required double long,
    required bool isUtama,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      // Kalau ini diset jadi utama, matikan alamat utama yang lama
      if (isUtama) await _resetAlamatUtama(userId);

      await _supabase.from('customer_addresses').insert({
        'customer_id': userId,
        'label': label,
        'detail_alamat': detail,
        'lat': lat,
        'long': long,
        'is_main': isUtama,
      });
    } catch (e) {
      throw Exception('Gagal menambah alamat: $e');
    }
  }

  Future<void> ubahAlamat({
    required String idAlamat,
    required String label,
    required String detail,
    required double lat,
    required double long,
    required bool isUtama,
  }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      if (isUtama) await _resetAlamatUtama(userId);

      await _supabase
          .from('customer_addresses')
          .update({
            'label': label,
            'detail_alamat': detail,
            'lat': lat,
            'long': long,
            'is_main': isUtama,
          })
          .eq('id', idAlamat); // Hanya ubah baris yang ID-nya cocok
    } catch (e) {
      throw Exception('Gagal mengubah alamat: $e');
    }
  }

  Future<void> hapusAlamat(String idAlamat) async {
    try {
      await _supabase.from('customer_addresses').delete().eq('id', idAlamat);
    } catch (e) {
      throw Exception('Gagal menghapus alamat: $e');
    }
  }

  Future<void> _resetAlamatUtama(String userId) async {
    await _supabase
        .from('customer_addresses')
        .update({'is_main': false})
        .eq('customer_id', userId);
  }

  Future<Map<String, dynamic>?> ambilAlamatUtama() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      
      final data = await _supabase
          .from('customer_addresses')
          .select('*')
          .eq('customer_id', userId)
          .eq('is_main', true)
          .maybeSingle(); // Mengembalikan data atau null jika tidak ada

      if (data == null) return null;
      
      return data; 
    } catch (e) {
      throw Exception('Gagal mengambil alamat utama: $e');
    }
  }
}
