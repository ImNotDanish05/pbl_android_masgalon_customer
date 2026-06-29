import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/bottom_action.dart';
import '../../widgets/order/order_detail_widget.dart';
import '../../models/order_model.dart'; // 👈 1. Import OrderModel
import '../../services/order/orders_service.dart'; // 👈 2. Import Service
import '../../route/routes.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order; // 👈 3. Siapkan keranjang penangkap data dari halaman sebelumnya

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> with RouteAware {
  final _orderService = OrderService();
  late Stream<Map<String, dynamic>> _orderDetailStream;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadData();
  }

  void _loadData() {
    setState(() {
      _orderDetailStream = _orderService.streamOrderDetail(widget.order.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _orderDetailStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: GeneralAppBar(
              title: 'Rincian Pesanan',
              onBackPressed: () => context.pop(),
              backgroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError && !snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: GeneralAppBar(
              title: 'Rincian Pesanan',
              onBackPressed: () => context.pop(),
              backgroundColor: Colors.white,
            ),
            body: Center(
              child: Text('Gagal memuat rincian: ${snapshot.error}'),
            ),
          );
        }
        if ((!snapshot.hasData || snapshot.data == null) &&
            !snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: GeneralAppBar(
              title: 'Rincian Pesanan',
              onBackPressed: () => context.pop(),
              backgroundColor: Colors.white,
            ),
            body: const Center(child: Text('Data pesanan tidak ditemukan.')),
          );
        }

        final detailData = snapshot.data!;
        final rawStatus = detailData['status']?.toString() ?? '';
        final isFinished = rawStatus == 'Selesai' || rawStatus == 'Tolak';
        final isPending =
            rawStatus == 'Mencari_Kurir' || rawStatus == 'Menunggu_Kurir';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: GeneralAppBar(
            title: 'Rincian Pesanan',
            onBackPressed: () => context.pop(),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
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
          ),
          bottomNavigationBar: !isFinished
              ? BottomActionButton(
                  icon: Icons.local_shipping,
                  label: isPending ? 'Menunggu Kurir...' : 'Lacak Pesanan',
                  onPressed: isPending
                      ? null
                      : () {
                          final order = OrderModel.fromMap(detailData);
                          context.push('/track-order', extra: order);
                        },
                )
              : null,
        );
      },
    );
  }
}
