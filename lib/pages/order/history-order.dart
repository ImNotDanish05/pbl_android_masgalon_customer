import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../widgets/shared/general_app_bar.dart'; // Pastikan path ini benar!
import '../../widgets/order/history_order_card.dart';

class HistoryOrderPage extends StatefulWidget {
  const HistoryOrderPage({super.key});

  @override
  State<HistoryOrderPage> createState() => _HistoryOrderPageState();
}

class _HistoryOrderPageState extends State<HistoryOrderPage> {
  int _selectedTabIndex = 0; // 0 = Aktif, 1 = Selesai

  @override
  Widget build(BuildContext context) {
    // Ambil data dari dummy berdasarkan tab yang dipilih
    final listPesanan = _selectedTabIndex == 0
        ? DummyData.activeOrders
        : DummyData.completedOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Abu-abu background terang
      appBar: GeneralAppBar(
        title: 'Riwayat Pesanan',
        onBackPressed: () {
          context.pop();
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar (Segmented Control)
          _buildCustomTabBar(),

          // Daftar Pesanan
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Dinamis (Pesanan Berjalan / Selesai Baru-baru Ini)
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
                    if (_selectedTabIndex == 0) // Badge "2 Aktif"
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
                          '${DummyData.activeOrders.length} Aktif',
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
                ...listPesanan.map((order) {
                  return HistoryOrderCard(
                    order: order,
                    onLacakTap: () {
                      context.push('/track-order');
                    },
                  );
                }).toList(),
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
