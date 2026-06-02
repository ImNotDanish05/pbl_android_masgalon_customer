import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/voucher_service.dart'; 

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  // 1. Siapkan wadah dan status loading
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;

  // 2. Fungsi ambil data dari Supabase
  Future<void> _loadVouchers() async {
    try {
      final voucherService = VoucherService();
      final data = await voucherService.ambilDaftarVoucher();

      if (mounted) {
        setState(() {
          _vouchers = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error ambil voucher: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi saat halaman dibuka
    _loadVouchers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Voucher Saya', style: TextStyle(color: Colors.blue)),
      ),
      // 4. Logika Tampilan (Loading / Kosong / Ada Isinya)
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada voucher yang tersedia untukmu saat ini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF1E3A8A)
                          ), 
                          children: [
                            const TextSpan(text: 'Tersedia '),
                            TextSpan(
                              text: '${_vouchers.length}', // <--- Pakai variabel state
                              style: const TextStyle(color: Colors.orange),
                            ),
                            const TextSpan(text: ' Voucher'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gunakan sebelum kadaluarsa untuk lebih hemat.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _vouchers.length,
                          itemBuilder: (context, index) {
                            final voucher = _vouchers[index];
                            return _buildVoucherCard(voucher);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_offer, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PROMO',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        voucher.title, // <--- Memanggil judul dari Supabase
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        voucher.subtitle, // <--- Memanggil deskripsi dari Supabase
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  // Logika saat ditekan bisa ditambahkan nanti
                  debugPrint('Voucher ${voucher.title} dipakai!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  minimumSize: Size.zero,
                ),
                child: const Text('Pakai', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}