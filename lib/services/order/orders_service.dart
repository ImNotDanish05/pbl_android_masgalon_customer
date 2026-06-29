// lib/services/order_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  // Tambahkan ini di dalam class OrderService
  Future<List<Map<String, dynamic>>> getRiwayatPesanan() async {
    final myUserId = _supabase.auth.currentUser!.id;

    try {
      // Tarik data order, gabung dengan order_items, gabung lagi dengan products
      final response = await _supabase
          .from('orders')
          .select('''
            id,
            created_at,
            status,
            total_harga,
            metode_pembayaran,
            couriers (
              nama_asli,
              users (
                username,
                avatar_url
              )
            ),
            order_items (
              quantity,
              products (nama, image_url)
            )
          ''')
          .eq('customer_id', myUserId)
          .order('created_at', ascending: false); // Urutkan dari yang terbaru

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getRiwayatPesanan: $e');
      return [];
    }
  }

  // 👇 Tambahkan fungsi ini untuk menarik detail pesanan secara spesifik
  Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            couriers (
              nama_asli,
              plat_nomor,
              users (username, avatar_url)
            ),
            order_items (
              quantity,
              subtotal,
              products (nama, image_url, harga_dasar)
            )
          ''')
          .eq('id', orderId)
          .single(); // Pakai .single() karena kita hanya butuh 1 data pesanan

      return response;
    } catch (e) {
      debugPrint('Error getOrderDetail: $e');
      rethrow;
    }
  }

  /// Listen to real-time changes in courier coordinates for a specific order.
  /// Returns a stream of LatLng for updates.
  Stream<LatLng> streamCourierLocation(String orderId) {
    late final RealtimeChannel channel;
    final controller = StreamController<LatLng>(
      onCancel: () {
        _supabase.removeChannel(channel);
      },
    );

    channel = _supabase.channel('tracking_logs_order_$orderId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'tracking_logs',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_id',
        value: orderId,
      ),
      callback: (payload) {
        final double lat =
            double.tryParse(payload.newRecord['lat'].toString()) ?? 0.0;
        final double lng =
            double.tryParse(payload.newRecord['long'].toString()) ?? 0.0;
        controller.add(LatLng(lat, lng));
      },
    ).subscribe();

    return controller.stream;
  }

  /// Fetch the latest location log for an order
  Future<LatLng?> fetchLatestCourierLocation(String orderId) async {
    try {
      final response = await _supabase
          .from('tracking_logs')
          .select('lat, long')
          .eq('order_id', orderId)
          .order('logged_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final double lat = double.tryParse(response['lat'].toString()) ?? 0.0;
        final double lng = double.tryParse(response['long'].toString()) ?? 0.0;
        return LatLng(lat, lng);
      }
    } catch (_) {
      // Fail silently
    }
    return null;
  }

  /// Listen to real-time updates for a specific order, pushing full order details
  Stream<Map<String, dynamic>> streamOrderDetail(String orderId) {
    late final RealtimeChannel channel;
    final controller = StreamController<Map<String, dynamic>>(
      onCancel: () {
        _supabase.removeChannel(channel);
      },
    );

    // Initial load
    getOrderDetail(orderId).then((data) {
      if (!controller.isClosed) {
        controller.add(data);
      }
    }).catchError((e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    });

    // Subscribe to Postgres changes on the orders table
    channel = _supabase.channel('order_detail_updates_$orderId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: orderId,
      ),
      callback: (payload) async {
        try {
          final data = await getOrderDetail(orderId);
          if (!controller.isClosed) {
            controller.add(data);
          }
        } catch (_) {
          // Fail silently
        }
      },
    ).subscribe();

    return controller.stream;
  }

  /// Get detailed road route points using OSRM Route API
  Future<List<LatLng>> getOSRMRoute(LatLng start, LatLng end) async {
    final baseUrl = dotenv.env['OSRM_BASE_URL'] ?? 'https://router.project-osrm.org';
    final url = Uri.parse('$baseUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final List<LatLng> points = [];
          if (route['geometry'] != null && route['geometry']['coordinates'] != null) {
            final List<dynamic> coordsList = route['geometry']['coordinates'];
            for (final coord in coordsList) {
              final lng = double.tryParse(coord[0].toString()) ?? 0.0;
              final lat = double.tryParse(coord[1].toString()) ?? 0.0;
              points.add(LatLng(lat, lng));
            }
          }
          return points;
        }
      }
    } catch (e) {
      debugPrint('OSRM Customer Route Error: $e');
    }
    return [start, end]; // Fallback to straight line
  }
}
