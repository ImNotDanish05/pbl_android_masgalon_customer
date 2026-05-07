import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/main_head_bar.dart';
import '../../widgets/saldo_card.dart';
import '../../data/dummy_data.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../../widgets/order_history_card.dart';
import '../../widgets/section_header.dart';
import '../../core/constants/app_colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaldoCard(
              saldo: DummyData.saldoAbunemen,
              onTopUpTap: () {
                print("Cihuyy, tombol isi saldo ditekan!");
              },
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Riwayat Pesanan',
              subtitle: 'Pantau pengiriman air Anda',
              actionText: 'Lihat Semua',
              onActionTap: () {},
            ),
            const SizedBox(height: 14),
            Column(
              children: DummyData.orderHistory
                  .map(
                    (order) => OrderHistoryCard(
                      order: order,
                      formatRupiah: formatPrice,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 1) {
            setState(() => _currentNavIndex = index);
          } else if (index == 0) {
            context.go('/home');
          } else {
            setState(() => _currentNavIndex = index);
          }
        },
      ),
    );
  }

  String formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
