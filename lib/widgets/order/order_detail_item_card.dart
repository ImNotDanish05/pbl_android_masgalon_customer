import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_android_masgalon_customer/providers/cart_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/shared/rupiah_format.dart';

class OrderDetailItemCard extends StatelessWidget {
  final CartItem item;

  const OrderDetailItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final quantity = item.quantity;
    final int subTotal = product.price * quantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageAsset.isNotEmpty
                ? Image.asset(product.imageAsset, fit: BoxFit.contain)
                : const Icon(Icons.local_drink, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity x ${product.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subTotal.toRupiah,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
