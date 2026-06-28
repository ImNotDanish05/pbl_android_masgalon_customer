import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/topup_model.dart';

class TopupService {
  final _supabase = Supabase.instance.client;

  // --- Fungsi Baru: Upload Bukti Transfer ke Storage ---
  Future<String> uploadBuktiTransfer(XFile imageFile) async {
    try {
      // Buat nama file unik berdasarkan waktu
      final fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'bukti_transfer/$fileName'; 

      // Baca bytes dari XFile
      final imageBytes = await imageFile.readAsBytes();

      // Proses upload ke bucket Supabase bernama 'topup_request_bukti_transfer'
      await _supabase.storage.from('topup_request_bukti_transfer').uploadBinary(path, imageBytes);

      // Ambil URL public dari gambar yang barusan diupload
      final imageUrl = _supabase.storage.from('topup_request_bukti_transfer').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      throw Exception('Gagal upload bukti transfer: $e');
    }
  }

  // --- Fungsi Mengambil URL QRIS dari Store Config ---
  Future<String?> fetchQrisImage() async {
    try {
      // Mengambil 1 data teratas dari tabel store_config
      final response = await _supabase
          .from('store_config')
          .select('qris_image')
          .limit(1)
          .single(); // Pakai single() karena datanya cuma 1 baris

      return response['qris_image'] as String?;
    } catch (e) {
      throw Exception('Gagal mengambil data QRIS: $e');
    }
  }

  // Fungsi 1: Mengirim pengajuan topup baru (INSERT)
  Future<void> submitTopupRequest(TopupRequest request) async {
    try {
      await _supabase
          .from('topup_requests')
          .insert(request.toJson());
    } catch (e) {
      throw Exception('Gagal mengirim permintaan topup: $e');
    }
  }

  // Fungsi 2: Mengambil riwayat topup milik customer yang sedang login (SELECT)
  Future<List<TopupRequest>> fetchMyTopupHistory() async {
    try {
      // Mengambil ID user yang sedang login saat ini
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) throw Exception('User belum login');

      final response = await _supabase
          .from('topup_requests')
          .select()
          .eq('customer_id', userId) // Pastikan hanya ambil punya dia sendiri
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      return response.map((data) => TopupRequest.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil riwayat topup: $e');
    }
  }
}