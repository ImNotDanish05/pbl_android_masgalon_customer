import 'package:flutter/material.dart';

class TopUpStep1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const TopUpStep1({Key? key, required this.onNext, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              // Dummy QR Code
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 100,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      color: (index % 3 == 0) ? Colors.black : Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

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
