import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FloatingCartButton extends StatelessWidget {
  final int itemCount;

  const FloatingCartButton({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to cart page
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBlue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          if (itemCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFE07B00),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    itemCount > 9 ? '9+' : itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
