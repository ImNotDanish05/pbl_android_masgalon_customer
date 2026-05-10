import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/detail_order_dummy.dart';
import '../../../core/constants/app_colors.dart';

// ==========================================
// 1. status_pesanan_card.dart
// ==========================================
class StatusPesananCard extends StatelessWidget {
  const StatusPesananCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5), // Orange pucat
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  OrderDetailDummy.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C), // Orange tegas
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: AppColors.darkBlue,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pesanan #${OrderDetailDummy.orderId}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          Text(
            'Estimasi tiba: ${OrderDetailDummy.eta}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),

          // Progress Bar Sederhana
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                // Jika step 1: 0.33, step 2: 0.66, step 3: 1.0
                widthFactor: OrderDetailDummy.progressStep * 0.33,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIPROSES',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                'DIKIRIM',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                'SELESAI',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. kurir_card.dart
// ==========================================
class KurirCard extends StatelessWidget {
  const KurirCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(OrderDetailDummy.driverImage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrderDetailDummy.driverName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${OrderDetailDummy.driverRating} • ${OrderDetailDummy.driverRole}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.darkBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. alamat_pengiriman_card.dart
// ==========================================
class AlamatPengirimanCard extends StatelessWidget {
  const AlamatPengirimanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OrderDetailDummy.addressLabel,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            OrderDetailDummy.addressDetail,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: DashedDivider(
              color: AppColors.borderColor,
            ), // Custom widget di bawah
          ),
          Text(
            OrderDetailDummy.addressNote,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. detail_barang_card.dart
// ==========================================
class DetailBarangCard extends StatelessWidget {
  const DetailBarangCard({super.key});

  // PINDAHKAN FUNGSI INI KE SINI
  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        children: OrderDetailDummy.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.imageUrl == 'galon' ? Icons.water_drop : Icons.propane,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        // Sekarang fungsi ini bisa dipanggil tanpa error!
                        '${item.quantity} Unit x ${_formatRupiah(item.pricePerUnit)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRupiah(item.totalPrice),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==========================================
// 5. informasi_pembayaran_card.dart
// ==========================================
class InformasiPembayaranCard extends StatelessWidget {
  const InformasiPembayaranCard({super.key});

  // TAMBAHKAN FUNGSI RUPIAH DI SINI JUGA
  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // PINDAHKAN WIDGET HELPER INI KE SINI
  Widget _buildPaymentRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDiscount ? const Color(0xFFB42318) : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          // Sekarang error merahnya akan hilang!
          _buildPaymentRow(
            'Subtotal',
            _formatRupiah(OrderDetailDummy.subtotal),
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Biaya Pengantaran',
            _formatRupiah(OrderDetailDummy.deliveryFee),
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Promo "${OrderDetailDummy.promoCode}"',
            '-${_formatRupiah(OrderDetailDummy.discount)}',
            isDiscount: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: DashedDivider(color: AppColors.borderColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PEMBAYARAN',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        OrderDetailDummy.paymentMethod,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                _formatRupiah(OrderDetailDummy.totalPayment),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            OrderDetailDummy.orderTimestamp,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class DashedDivider extends StatelessWidget {
  final Color color;
  const DashedDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
