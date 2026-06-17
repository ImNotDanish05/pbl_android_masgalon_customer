import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/order_history_model.dart';
import '../shared/status_badge.dart';
import '../../widgets/shared/rupiah_format.dart';


class HistoryOrderCard extends StatelessWidget {
  final HistoryOrderModel order;
  final VoidCallback? onLacakTap;

  const HistoryOrderCard({super.key, required this.order, this.onLacakTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (ID Pesanan & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID PESANAN',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${order.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.date,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                status: order.status,
              ), // Memanggil widget global buatanmu!
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Color(0xFFE8EDF5), height: 1),
          ),

          // 2. Info Barang
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.imageType == 'galon' ? Icons.water_drop : Icons.propane,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.totalPrice.toRupiah,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Progress Bar & Tombol (Muncul HANYA JIKA pesanan Aktif)
          if (order.isActive) ...[
            const SizedBox(height: 20),

            // Progress Bar
            if (order.progress != null && order.progressText != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.progressText!,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  Text(
                    '${(order.progress! * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDF5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: order.progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Lacak Pesanan
            // 👇 ROW BARU: Detail + Chat + Lacak 👇
            Row(
              children: [
                // 1. Tombol Detail Pesanan (Garis Tiga)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.push('/orders/detail');
                    },
                    icon: const Icon(
                      Icons.receipt_long_outlined, // Ikon nota
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    tooltip: 'Detail Pesanan',
                  ),
                ),

                // 2. Tombol Chat Kurir
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // final defaultChat = ChatDummyData.chatList.first;
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => ChatDetailPage(chat: defaultChat),
                      //   ),
                      // );
                    },
                    icon: const Icon(
                      Icons.chat_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    tooltip: 'Chat Kurir',
                  ),
                ),

                // 3. Tombol Lacak Pesanan (Expanded)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onLacakTap,
                    icon: const Icon(
                      Icons.local_shipping,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Lacak',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.push('/orders/detail');
                    },
                    icon: const Icon(
                      Icons.receipt_long_outlined, // Ikon nota
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    tooltip: 'Detail Pesanan',
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/confirm-order');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryBlue, // Warna sama dengan Lacak
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Radius sama dengan Lacak
                      ),
                    ),
                    child: Text(
                      'Pesan Lagi',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}