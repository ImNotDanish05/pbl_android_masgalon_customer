import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../core/constants/app_colors.dart';
import 'section_header.dart';

class CatalogSection extends StatelessWidget {
  final List<ProductModel> products;

  const CatalogSection({super.key, required this.products});

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Katalog Galon',
          subtitle: 'Air mineral segar untuk keluarga',
          actionText: 'Lihat Semua',
          onActionTap: () {},
        ),
        const SizedBox(height: 14),
        Row(
          children: products.map((product) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: products.indexOf(product) < products.length - 1 ? 10 : 0,
                ),
                child: _GalonCard(product: product, formatRupiah: _formatRupiah),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GalonCard extends StatelessWidget {
  final ProductModel product;
  final String Function(int) formatRupiah;

  const _GalonCard({required this.product, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              size: 48,
              color: Color(0xFF90CAF9),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(product.price),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
