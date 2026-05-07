import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/order_detail_model.dart';
import 'order_detail_item_card.dart'; // atau order_item_row.dart

class ConfirmItemsSection extends StatelessWidget {
  final String title; // 1. TAMBAHKAN VARIABEL INI
  final List<OrderDetailItem> items;
  final String Function(int) formatRupiah;

  const ConfirmItemsSection({
    super.key,
    this.title = 'Detail Item', // default
    required this.items,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title, // 3. PANGGIL VARIABELNYA DI SINI
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: items
                .map(
                  (item) => OrderDetailItemCard(
                    item: item,
                    formatRupiah: formatRupiah,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
