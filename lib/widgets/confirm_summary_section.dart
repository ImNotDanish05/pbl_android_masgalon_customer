import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class ConfirmSummarySection extends StatelessWidget {
  final int subtotal;
  final int deliveryFee;
  final int total;
  final String Function(int) formatRupiah;

  const ConfirmSummarySection({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
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
        children: [
          _buildPaymentRow(
            'Subtotal Item',
            formatRupiah(subtotal),
            isTotal: false,
          ),
          const SizedBox(height: 10),
          _buildPaymentRow(
            'Biaya Pengiriman',
            formatRupiah(deliveryFee),
            isTotal: false,
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor),
          const SizedBox(height: 12),
          _buildPaymentRow(
            'Total Pembayaran',
            formatRupiah(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String amount, {
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.primaryBlue : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
