import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/order/checkout_item_card.dart';
import '../../providers/cart_provider.dart'; 
import '../../widgets/shared/rupiah_format.dart';
import '../../widgets/shared/custom_app_bar.dart';

// Ubah jadi ConsumerWidget, tidak butuh Stateful lagi!
class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Pantau isi keranjang secara real-time
    final cartItems = ref.watch(cartProvider);
    // 2. Ambil fungsi-fungsi untuk mengubah keranjang
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: CustomAppBar(
        title: 'Checkout',
        showBackButton: true,
        showNotifications: false,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Jika keranjang kosong
                if (cartItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'Keranjang masih kosong',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  // List Item langsung dari Provider
                  ...cartItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final itemTotal = item.product.price * item.quantity;

                    return CheckoutItemCard(
                      title: item.product.name,
                      subtitle:
                          '${item.quantity} unit x Rp ${item.product.price.toRupiah}',
                      price: itemTotal.toRupiah,
                      quantity: item.quantity,
                      onIncrement: () => cartNotifier.increment(
                        index,
                      ), 
                      onDecrement: () => cartNotifier.decrement(
                        index,
                      ), 
                    );
                  }),

                const SizedBox(height: 20),

                // Total Tagihan Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        cartNotifier.totalPrice.toRupiah,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D63B3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Konfirmasi di Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ElevatedButton(
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        // Hanya bisa dipencet jika keranjang tidak kosong
                        context.pushNamed('confirm-order');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D63B3),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Konfirmasi & Pesan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
