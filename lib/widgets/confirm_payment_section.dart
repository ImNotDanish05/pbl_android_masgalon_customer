import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class ConfirmPaymentSection extends StatelessWidget {
  final String selectedPayment;
  final Map<String, dynamic> paymentOptions;
  final Function(String) onSelected;

  const ConfirmPaymentSection({
    super.key,
    required this.selectedPayment,
    required this.paymentOptions,
    required this.onSelected,
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
            'Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...paymentOptions.entries.map((entry) {
            final String key = entry.key;
            final Map<String, dynamic> data = entry.value;
            final IconData icon = key == 'Saldo'
                ? Icons.account_balance_wallet_outlined
                : Icons.credit_card_outlined;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPaymentOption(
                icon: icon,
                title: data['title'],
                subtitle: data['subtitle'],
                value: key,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPayment == value
                ? AppColors.primaryBlue
                : AppColors.borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedPayment == value
              ? AppColors.primaryBlue.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPayment,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onSelected(newValue);
                }
              },
              activeColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
