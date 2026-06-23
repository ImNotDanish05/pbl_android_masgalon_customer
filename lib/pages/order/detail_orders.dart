import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/bottom_action.dart';
import '../../widgets/order/order_detail_widget.dart';
import '../../models/order_model.dart'; // 👈 1. Import OrderModel
import '../../services/orders_service.dart'; // 👈 2. Import Service

class OrderDetailPage extends StatefulWidget {
  final OrderModel order; // 👈 3. Siapkan keranjang penangkap data dari halaman sebelumnya

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: GeneralAppBar(
        title: 'Rincian Pesanan',
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.white,
      ),
      // 👇 4. Gunakan FutureBuilder untuk mengambil rincian lengkap dari DB
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderService.getOrderDetail(widget.order.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat rincian: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data pesanan tidak ditemukan.'));
          }

          final detailData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPesananCard(detailData: detailData),
                const SizedBox(height: 16),
                KurirCard(detailData: detailData),
                const SizedBox(height: 24),

                const SectionHeader(
                  icon: Icons.location_on,
                  title: 'ALAMAT PENGIRIMAN',
                ),
                AlamatPengirimanCard(detailData: detailData),
                const SizedBox(height: 24),

                const SectionHeader(
                  icon: Icons.shopping_cart,
                  title: 'DETAIL BARANG',
                ),
                DetailBarangCard(detailData: detailData),
                const SizedBox(height: 24),

                const SectionHeader(
                  icon: Icons.payments,
                  title: 'INFORMASI PEMBAYARAN',
                ),
                InformasiPembayaranCard(detailData: detailData),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),

      // 👇 6. Tampilkan tombol Lacak hanya jika pesanan masih aktif
      bottomNavigationBar:
          widget.order.status != OrderStatus.selesai &&
              widget.order.status != OrderStatus.tolak
          ? BottomActionButton(
              icon: Icons.local_shipping,
              label: 'Lacak Pesanan',
              onPressed: () {
                context.push('/track-order', extra: widget.order);
              },
            )
          : null, // Hilangkan tombol di bawah jika pesanan sudah selesai/batal
    );
  }
}
