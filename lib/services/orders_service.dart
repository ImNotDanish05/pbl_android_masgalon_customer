// lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  // Fungsi sakti untuk mengeksekusi Checkout
  Future<void> buatPesananBaru({
    required String customerId,
    required Map<String, dynamic> alamatUtama,
    required List<dynamic>
    cartItems, // Gunakan List<CartItem> jika modelnya sudah ada
    required int shippingOptionId,
    required String paymentMethod,
    required int totalHarga,
    required int saldoSaatIni,
  }) async {
    try {
      // 1. Validasi Saldo (Jika bayar pakai Saldo Akunemen)
      if (paymentMethod == 'Abunemen') {
        if (saldoSaatIni < totalHarga) {
          throw Exception('Saldo tidak mencukupi!');
        }
      }

      // 2. Buat Kepala Struk (Insert ke tabel 'orders')
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'customer_id': customerId,
            'address_id': alamatUtama['id'],
            'address_label': alamatUtama['label'],
            'address_detail':
                alamatUtama['detail_alamat'], // Sesuaikan dengan nama kolom di AddressService
            'address_lat': alamatUtama['lat'],
            'address_long': alamatUtama['long'],
            'shipping_option_id': shippingOptionId,
            'status': 'Mencari_Kurir', // Status awal pesanan
            'metode_pembayaran': paymentMethod,
            'total_harga': totalHarga,
          })
          .select('id')
          .single();

      final String newOrderId = orderResponse['id'].toString();

      // 3. Buat Rincian Barang (Insert ke tabel 'order_items')
      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': newOrderId,
          'product_id': int.parse(
            item.product.id,
          ), // Pastikan tipe datanya int4 sesuai Supabase-mu
          'quantity': item.quantity,
          'subtotal': item.product.price * item.quantity,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItemsData);

      // 4. Potong Saldo (Hanya jika metode pembayaran Saldo)
      if (paymentMethod == 'Abunemen') {
        final sisaSaldo = saldoSaatIni - totalHarga;

        await _supabase
            .from('customers')
            .update({'saldo_abunemen': sisaSaldo})
            .eq(
              'user_id',
              customerId,
            ); // Pastikan ini menggunakan 'user_id' atau 'id' sesuai tabel customers-mu
      }
    } catch (e) {
      debugPrint('Error OrderService: $e');
      throw Exception('Gagal memproses pesanan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> ambilOpsiPengiriman() async {
    try {
      final response = await _supabase
          .from('shipping_options')
          .select()
          .eq('is_active', true)
          .order('harga', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Gagal mengambil opsi pengiriman: $e');
    }
  }
}
