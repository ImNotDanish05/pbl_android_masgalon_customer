import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// 1. Buat cetakan untuk item di dalam keranjang
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// 2. Buat mesin pengatur keranjangnya
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]); // Awalnya keranjang kosong
  void clearCart() {
    state = [];
  }

  // Fungsi Tambah Barang
  void addToCart(ProductModel product) {
    // Cek apakah barang sudah ada di keranjang
    final index = state.indexWhere((item) => item.product.name == product.name);
    
    if (index != -1) {
      // Kalau sudah ada, tambahkan jumlahnya saja
      state[index].quantity++;
      state = [...state]; // Paksa layar untuk update
    } else {
      // Kalau belum ada, masukkan barang baru ke keranjang
      state = [...state, CartItem(product: product)];
    }
  }

  // Fungsi Tambah (+) di Checkout
  void increment(int index) {
    state[index].quantity++;
    state = [...state];
  }

  // Fungsi Kurang (-) di Checkout
  void decrement(int index) {
    if (state[index].quantity > 1) {
      state[index].quantity--;
      state = [...state];
    } else {
      // Hapus barang kalau jumlahnya jadi 0
      state.removeAt(index);
      state = [...state];
    }
  }

  // Hitung Total Tagihan Otomatis
  int get totalPrice {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}

// 3. Provider yang akan dipanggil oleh seluruh halaman!
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});