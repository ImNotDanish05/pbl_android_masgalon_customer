import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../models/chat_model.dart';
import '../../pages/chat/chat_detail_page.dart';
import '../shared/status_badge.dart';

class HistoryOrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatRupiah;

  const HistoryOrderCard({
    super.key,
    required this.order,
    required this.formatRupiah,
  });

  // 👇 FUNGSI WARNA DIHAPUS KARENA KITA AKAN PAKAI STATUS BADGE LANGSUNG

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah pesanan sedang aktif
    final isAktif =
        order.status != OrderStatus.selesai &&
        order.status != OrderStatus.tolak;

    // Mengecek apakah tombol chat dan lacak harus dikunci (hanya aktif jika statusnya diantar)
    final isLocked = order.status == OrderStatus.mencariKurir ||
        order.status == OrderStatus.menungguKurir;

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
              // 👇 2. GANTI MANUAL CONTAINER DENGAN STATUS BADGE
              StatusBadge(status: order.status),
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

              Row(
                children: [
                  // Tombol Detail (Selalu tampil untuk semua status)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      onPressed: () => context.push('/orders/detail', extra: order),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      tooltip: "Detail Pesanan",
                    ),
                  ),
                  if (isAktif) ...[
                    // Tombol Chat (Mati kalau kurir belum ada / masih menunggu)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? Colors.grey[200]
                            : AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        onPressed: isLocked
                            ? null
                            : () {
                                final chatRoom = ChatModel(
                                  id: order.id,
                                  kurirName: order.kurirName ?? 'Kurir',
                                  kurirAvatar: order.kurirAvatar ?? '',
                                  lastMessage: '',
                                  time: '',
                                  isOnline: true,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatDetailPage(chat: chatRoom),
                                  ),
                                );
                              },
                        icon: Icon(
                          Icons.chat_outlined,
                          color: isLocked
                              ? Colors.grey
                              : AppColors.primaryBlue,
                          size: 20,
                        ),
                        tooltip: "Chat Kurir",
                      ),
                    ),
                    // Tombol Lacak (Mati kalau kurir belum ada / masih menunggu)
                    ElevatedButton(
                      // 👇 Beri nilai null kalau masih mencari kurir / menunggu kurir
                      onPressed: isLocked
                          ? null
                          : () {
                              context.push('/track-order', extra: order);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            Colors.grey[300], // Warna background saat mati
                        disabledForegroundColor:
                            Colors.grey[600], // Warna teks saat mati
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lacak',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Jika statusnya SELESAI / DIBATALKAN (Tampilkan Pesan Lagi)
                    ElevatedButton(
                      onPressed: () => context.push('/confirm-order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
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
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
