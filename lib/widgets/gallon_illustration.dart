import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GallonIllustration extends StatelessWidget {
  const GallonIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gallon body
              Container(
                width: 64,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 1.5,
                  ),
                ),
              ),
              // Water fill
              Positioned(
                bottom: 21,
                child: Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDBFE).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Cap
              Positioned(
                top: 21,
                child: Container(
                  width: 28,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Label stripe
              Positioned(
                top: 48,
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF93C5FD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
