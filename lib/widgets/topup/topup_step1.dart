import 'package:flutter/material.dart';
import '../../services/topup_service.dart'; // Pastikan path ini sesuai dengan struktur foldermu

class TopUpStep1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const TopUpStep1({Key? key, required this.onNext, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inisialisasi service untuk memanggil fungsi fetchQrisImage()
    final topupService = TopupService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
          ),
          child: Column(
            children: [
              // --- Bagian FutureBuilder Pengganti Dummy QR Code ---
              FutureBuilder<String?>(
                future: topupService.fetchQrisImage(),
                builder: (context, snapshot) {
                  // Kondisi 1: Sedang Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Kondisi 2: Error atau Data Kosong
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'QRIS belum tersedia',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  // Kondisi 3: Berhasil mendapat URL gambar dari Supabase
                  return Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        snapshot.data!, // Tampilkan gambar
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey)
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // --- Bagian Info Cara Pembayaran (Tetap sama seperti aslimu) ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cara Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. Buka aplikasi e-Wallet (OVO, GoPay, Dana) atau M-Banking Anda.',
                    ),
                    SizedBox(height: 4),
                    Text('2. Pilih menu Scan QR atau Pay.'),
                    SizedBox(height: 4),
                    Text('3. Arahkan kamera ke QR Code di atas.'),
                    SizedBox(height: 4),
                    Text('4. Konfirmasi pembayaran sesuai nominal.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // --- Bagian Tombol (Tetap sama seperti aslimu) ---
        ElevatedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.receipt_long),
          label: const Text('Sudah Bayar, Unggah Bukti'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[800],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Kembali'),
        ),
      ],
    );
  }
}