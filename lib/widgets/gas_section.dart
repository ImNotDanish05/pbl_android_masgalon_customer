import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../core/constants/app_colors.dart';
import 'section_header.dart';

class GasSection extends StatelessWidget {
  final List<ProductModel> products;

  const GasSection({super.key, required this.products});

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tabung Gas',
          subtitle: 'Kebutuhan dapur yang andal',
          onLihatSemua: () {},
        ),
        const SizedBox(height: 14),
        ...products.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GasCard(
                product: product,
                formatRupiah: _formatRupiah,
              ),
            )),
      ],
    );
  }
}

class _GasCard extends StatelessWidget {
  final ProductModel product;
  final String Function(int) formatRupiah;

  const _GasCard({required this.product, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A3A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.propane_tank_outlined,
              color: Colors.white60,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.badge != null)
                  Text(
                    product.badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE07B00),
                    ),
                  ),
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (product.subtitle != null)
                  Text(
                    product.subtitle!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),

          // Price + button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(product.price),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Tambah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
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
