import 'package:supabase_flutter/supabase_flutter.dart';

class KatalogService {
  final supabase = Supabase.instance.client;

  // 1. Ambil Produk Galon (Mencari produk yang namanya mengandung kata 'galon')
  Future<List<Map<String, dynamic>>> ambilDaftarProduk() async {
    try {
      final response = await supabase
          .from('products')
          .select('*')
          .eq('is_active', true); // Pastikan produknya aktif

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data galon: $e');
    }
  }

  // 2. Ambil Produk Gas (Mencari produk yang namanya mengandung kata 'gas')
  Future<List<Map<String, dynamic>>> ambilDaftarGas() async {
    try {
      final response = await supabase
          .from('products')
          .select('*')
          .ilike('nama', '%gas%') // Mencari nama yang ada kata "gas"
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil data gas: $e');
    }
  }
}
