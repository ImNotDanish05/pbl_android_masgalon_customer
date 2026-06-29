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

      final String? path = response['qris_image'] as String?;
      if (path == null || path.isEmpty) return null;

      if (path.startsWith('http')) {
        return path;
      }

      return _supabase.storage.from('qris_bucket').getPublicUrl(path);
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

  // Fungsi 3: Mengambil riwayat topup berdasarkan Bulan & Tahun tertentu
  Future<List<TopupRequest>> fetchMyTopupHistoryByMonth(int year, int month) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Batas awal bulan: YYYY-MM-01 00:00:00
      final startOfMonth = DateTime(year, month, 1).toUtc().toIso8601String();
      
      // Batas akhir bulan (tanggal 1 bulan berikutnya)
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      final endOfMonth = DateTime(nextYear, nextMonth, 1).toUtc().toIso8601String();

      final response = await _supabase
          .from('topup_requests')
          .select()
          .eq('customer_id', userId)
          .gte('created_at', startOfMonth)
          .lt('created_at', endOfMonth)
          .order('created_at', ascending: false);

      return response.map((data) => TopupRequest.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil riwayat topup bulanan: $e');
    }
  }

  // Fungsi 4: Mengambil daftar Bulan & Tahun unik yang memiliki transaksi topup
  Future<List<DateTime>> fetchUniqueTransactionMonths() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User belum login');

      // Ambil hanya kolom created_at agar payload sangat kecil dan cepat
      final response = await _supabase
          .from('topup_requests')
          .select('created_at')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      final Set<String> uniqueKeys = {};
      final List<DateTime> months = [];

      for (final row in response) {
        final createdAtStr = row['created_at'] as String?;
        if (createdAtStr == null) continue;
        final date = DateTime.parse(createdAtStr).toLocal();
        
        // Normalisasi ke tanggal 1 di bulan & tahun tersebut
        final normalized = DateTime(date.year, date.month, 1);
        final key = '${date.year}-${date.month}';
        
        if (!uniqueKeys.contains(key)) {
          uniqueKeys.add(key);
          months.add(normalized);
        }
      }

      return months;
    } catch (e) {
      throw Exception('Gagal mengambil filter tanggal transaksi: $e');
    }
  }
}