import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/chat_model.dart';
import '../../pages/chat/chat_detail_page.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatRupiah;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.formatRupiah,
  });

  Color _statusBackground(OrderStatus status) {
    switch (status) {
      case OrderStatus.selesai:
        return const Color(0xFFE6F9EF);
      case OrderStatus.tolak:
        return const Color(0xFFFDE8E8);
      case OrderStatus.mencariKurir:
        return const Color(0xFFFFF4DB);
      case OrderStatus.menungguKurir:
        return const Color(0xFFFFF4DB);
      case OrderStatus.diantar:
        return const Color(0xFFFFF4DB);
    }
  }

  Color _statusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.selesai:
        return const Color(0xFF147950);
      case OrderStatus.tolak:
        return const Color(0xFFB42318);
      case OrderStatus.mencariKurir:
        return const Color(0xFF92400E);
      case OrderStatus.menungguKurir:
        return const Color(0xFF92400E);
      case OrderStatus.diantar:
        return const Color(0xFF92400E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusBackground(order.status),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  order.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusTextColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.details,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
          ),
          if (order.note != null) ...[
            const SizedBox(height: 10),
            Text(
              order.note!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Teks Harga (Tampil selalu)
              Text(
                formatRupiah(order.price),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              if (order.status == OrderStatus.menungguKurir || order.status == OrderStatus.diantar)
                Row(
                  children: [
                    // Tombol Detail
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () => context.push('/orders/detail'),
                        icon: const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    // Tombol Chat
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: () {
                          final chatRoom = ChatModel(
                            id: order
                                .id, // Menggunakan ID Pesanan sebagai ID Ruang Chat
                            kurirName: order.kurirName ?? 'Kurir Mas Galon',
                            kurirAvatar: order.kurirAvatar ?? '',
                            lastMessage: '',
                            time: '',
                            isOnline: true,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(chat: chatRoom),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.chat_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                    // Tombol Lacak
                    ElevatedButton(
                      onPressed: () {
                        context.push('/track-order');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lacak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              // Jika statusnya SELESAI / DIBATALKAN (Tampilkan Pesan Lagi)
              else if (order.status == OrderStatus.selesai ||
                  order.status == OrderStatus.tolak)
                ElevatedButton(
                  onPressed: () => context.push('/confirm-order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Pesan Lagi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
