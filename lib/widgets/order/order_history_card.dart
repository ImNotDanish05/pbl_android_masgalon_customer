import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';

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
      case OrderStatus.completed:
        return const Color(0xFFE6F9EF);
      case OrderStatus.cancelled:
        return const Color(0xFFFDE8E8);
      case OrderStatus.pending:
        return const Color(0xFFFFF4DB);
    }
  }

  Color _statusTextColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return const Color(0xFF147950);
      case OrderStatus.cancelled:
        return const Color(0xFFB42318);
      case OrderStatus.pending:
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
              Text(
                formatRupiah(order.price),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              if (order.repeatable)
                OutlinedButton(
                  onPressed: () {
                    context.push('/confirm-order');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Pesan Lagi',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
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
