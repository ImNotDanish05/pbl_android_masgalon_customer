import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/shared/main_head_bar.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../services/orders_service.dart';
import '../../models/order_model.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../../widgets/order/history_order_card.dart';
import '../../widgets/shared/section_header.dart';
import '../../providers/auth_provider.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  int _currentNavIndex = 1;
  final OrderService _ordersService = OrderService();

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authCustomerProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaldoCard(
              saldo: customer?.saldoAbunemen ?? 0,
              onTap: () {
                context.push('/topup');
              },
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Riwayat Pesanan',
              subtitle: 'Pantau pengiriman air Anda',
              actionText: 'Lihat Semua',
              onActionTap: () {
                context.push('/orders/history');
              },
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersService.getRiwayatPesanan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                final pesananList = snapshot.data ?? [];

                if (pesananList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Belum ada riwayat pesanan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: pesananList.map((pesananData) {
                    final order = OrderModel.fromMap(pesananData);

                    return HistoryOrderCard(
                      order: order,
                      formatRupiah: formatPrice,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (i) {
          if (i == 1) {
            setState(() => _currentNavIndex = i);
          } else if (i == 0) {
            context.go('/home');
          } else if (i == 2) {
            context.go('/profile');
          } else if (i == 3) {
            context.go('/chat');
          }
          setState(() => _currentNavIndex = i);
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