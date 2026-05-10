import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopUpStep3 extends StatelessWidget {
  const TopUpStep3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[800],
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, spreadRadius: 10),
              ],
            ),
            child: const Icon(Icons.check, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 40),
          const Text(
            'Top Up Berhasil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Terima kasih! Pesanan Anda sedang diproses dan akan segera diantar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 6,
              ),
              onPressed: () => context.goNamed('home'),
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}