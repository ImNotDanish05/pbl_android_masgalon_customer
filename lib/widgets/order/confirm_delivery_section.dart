import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ConfirmDeliverySection extends StatelessWidget {
  final String selectedDelivery;
  final Map<String, dynamic> deliveryOptions;
  final Function(String) onSelected;
  final String Function(int) formatRupiah;

  const ConfirmDeliverySection({
    super.key,
    required this.selectedDelivery,
    required this.deliveryOptions,
    required this.onSelected,
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
            'Metode Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...deliveryOptions.entries.map((entry) {
            final String key = entry.key;
            final Map<String, dynamic> data = entry.value;
            final IconData icon = key == 'Kilet'
                ? Icons.flash_on_outlined
                : Icons.schedule_outlined;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDeliveryOption(
                icon: icon,
                title: data['label'],
                subtitle: data['subtitle'],
                price: '+' + formatRupiah(data['price']),
                value: key,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedDelivery == value
                ? AppColors.primaryBlue
                : AppColors.borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedDelivery == value
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
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
