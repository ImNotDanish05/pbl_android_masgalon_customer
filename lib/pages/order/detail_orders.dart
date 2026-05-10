import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/shared/section_header.dart';
import '../../widgets/bottom_action.dart';
import '../../widgets/order/order_detail_widget.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: GeneralAppBar(
        title: 'Rincian Pesanan',
        onBackPressed: () {
          context.pop();
        },
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusPesananCard(),
            const SizedBox(height: 16),
            const KurirCard(),
            const SizedBox(height: 24),

            const SectionHeader(
              icon: Icons.location_on,
              title: 'ALAMAT PENGIRIMAN',
            ),
            const AlamatPengirimanCard(),
            const SizedBox(height: 24),

            const SectionHeader(
              icon: Icons.shopping_cart,
              title: 'DETAIL BARANG',
            ),
            const DetailBarangCard(),
            const SizedBox(height: 24),

            const SectionHeader(
              icon: Icons.payments,
              title: 'INFORMASI PEMBAYARAN',
            ),
            const InformasiPembayaranCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        icon: Icons.local_shipping,
        label: 'Lacak Pesanan',
        onPressed: () {},
      ),
    );
  }
}
