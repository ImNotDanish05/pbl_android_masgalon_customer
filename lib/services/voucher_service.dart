import 'package:supabase_flutter/supabase_flutter.dart';
// Sesuaikan import ini jika file modelmu ada di tempat lain
import '../models/profile_model.dart'; 

class VoucherService {
  final _supabase = Supabase.instance.client;

  Future<List<VoucherModel>> ambilDaftarVoucher() async {
    try {
      // 1. Ambil ID customer yang sedang login
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('vouchers')
          .select('*')
          .eq('customer_id', userId) 
          .eq('is_used', false);    

      // 3. Terjemahkan jadi list model
      return response.map((json) => VoucherModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data voucher: $e');
    }
  }
}