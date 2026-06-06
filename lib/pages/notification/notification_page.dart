import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
  });
}

class NotificationPage extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationPage({
    super.key,
    this.notifications = const [],
  });

  List<NotificationItem> get _defaultNotifications => [
        NotificationItem(
          title: 'Pembayaran berhasil',
          message: 'Top up saldo Anda berhasil diproses.',
          time: DateTime(2026, 6, 2, 10, 35),
        ),
        NotificationItem(
          title: 'Pesanan dalam perjalanan',
          message: 'Air galon Anda sedang dikirim ke alamat tujuan.',
          time: DateTime(2026, 6, 1, 18, 20),
        ),
        NotificationItem(
          title: 'Promo baru tersedia',
          message: 'Dapatkan diskon khusus untuk pembelian gas hari ini.',
          time: DateTime(2026, 5, 31, 9, 45),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = notifications.isEmpty ? _defaultNotifications : notifications;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Tutup',
                  style: GoogleFonts.poppins(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  const Icon(Icons.notifications_off, size: 56, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi baru',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(item.time),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute · ${dt.day}/${dt.month}/${dt.year}';
  }
}