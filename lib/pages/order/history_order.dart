import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../services/order/orders_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/order/history_order_card.dart';
import '../../route/routes.dart';

class HistoryOrderPage extends ConsumerStatefulWidget {
  const HistoryOrderPage({super.key});

  @override
  ConsumerState<HistoryOrderPage> createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends ConsumerState<HistoryOrderPage> with RouteAware {
  int _selectedTabIndex = 0; // 0 = Aktif, 1 = Selesai
  final _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

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
      _ordersFuture = _orderService.getRiwayatPesanan();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil ID User yang sedang login
    final customer = ref.watch(authCustomerProvider);
    final userId = customer?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: GeneralAppBar(
        title: 'Riwayat Pesanan',
        onBackPressed: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomTabBar(),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                // Tampilan saat loading
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Tampilan saat error
                if (snapshot.hasError && !snapshot.hasData) {
                  return Center(
                    child: Text('Gagal memuat pesanan: ${snapshot.error}'),
                  );
                }
                final rawData = snapshot.data ?? [];
                final allOrders = rawData
                    .map((json) => OrderModel.fromMap(json))
                    .toList();
                final activeOrders = allOrders
                    .where(
                      (order) =>
                          order.status != OrderStatus.selesai &&
                          order.status != OrderStatus.tolak,
                    )
                    .toList();

                final completedOrders = allOrders
                    .where(
                      (order) =>
                          order.status == OrderStatus.selesai ||
                          order.status == OrderStatus.tolak,
                    )
                    .toList();

                // Pilih list mana yang mau ditampilkan berdasarkan Tab
                final listPesanan = _selectedTabIndex == 0
                    ? activeOrders
                    : completedOrders;

                if (listPesanan.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedTabIndex == 0
                          ? 'Belum ada pesanan aktif.'
                          : 'Belum ada pesanan selesai.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTabIndex == 0
                              ? 'Pesanan Berjalan'
                              : 'Selesai Baru-baru Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (_selectedTabIndex == 0) // Badge "X Aktif"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${activeOrders.length} Aktif',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Render List Kartu Pesanan
                    ...listPesanan.map((order) {
                      return HistoryOrderCard(
                        order: order,
                        formatRupiah: (harga) {
                          return 'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
                        },
                      );
                    }).toList(), // Hapus .toList() jika pakai spread operator (...)

                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Menampilkan ${listPesanan.length} pesanan terakhir',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(title: 'Aktif', index: 0),
          _buildTabItem(title: 'Selesai', index: 1),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}
