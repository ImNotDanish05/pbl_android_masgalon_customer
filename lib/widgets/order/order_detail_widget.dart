import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../../pages/chat/chat_detail_page.dart';

// ==========================================
// 1. status_pesanan_card.dart
// ==========================================
class StatusPesananCard extends StatelessWidget {
  final Map<String, dynamic> detailData;

  const StatusPesananCard({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    // Merapikan tulisan status (Mencari_Kurir -> Mencari Kurir)
    final rawStatus = detailData['status']?.toString() ?? '';
    final statusText = rawStatus.replaceAll('_', ' ').toUpperCase();
    final orderId =
        detailData['id']?.toString().substring(0, 8).toUpperCase() ?? '-';

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
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C),
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
            'Pesanan #$orderId',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          Text(
            'Pesanan sedang diproses sistem',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey),
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
  final Map<String, dynamic> detailData;
  const KurirCard({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    // Tarik data kurir (bisa null jika belum ada kurir)
    final courierData = detailData['couriers'];

    if (courierData == null) {
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
        child: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(width: 16),
            Text(
              'Sedang mencari kurir terbaik...',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    // Jika kurir sudah ada
    final userData = courierData['users'] ?? {};
    final driverName =
        userData['username'] ?? courierData['nama_asli'] ?? 'Kurir';
    final avatarUrl = userData['avatar_url']?.toString() ?? '';
    final platNomor = courierData['plat_nomor'] ?? '-';

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
            backgroundColor: AppColors.lightBlue,
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.motorcycle,
                      color: Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      platNomor,
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
// Bungkus dengan Material & InkWell agar ada efek klik (ripple) yang rapi
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50), // Efek klik bulat
              onTap: (detailData['status']?.toString() == 'Mencari_Kurir' ||
                      detailData['status']?.toString() == 'Menunggu_Kurir')
                  ? null
                  : () {
                      // 👇 1. Ambil data dari variabel yang sudah ada di KurirCard
                      final chatRoom = ChatModel(
                        id: detailData['id'].toString(), // Ambil ID dari detailData
                        kurirName: driverName,           // driverName sudah dideklarasikan di atasnya
                        kurirAvatar: avatarUrl,          // avatarUrl juga sudah ada di atasnya
                        lastMessage: '',
                        time: '',
                        isOnline: true,
                      );

                      // 👇 2. Pindah ke halaman chat
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(chat: chatRoom),
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (detailData['status']?.toString() == 'Mencari_Kurir' ||
                          detailData['status']?.toString() == 'Menunggu_Kurir')
                      ? Colors.grey.shade100
                      : AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_outlined, // Boleh pakai chat_outlined juga
                  color: (detailData['status']?.toString() == 'Mencari_Kurir' ||
                          detailData['status']?.toString() == 'Menunggu_Kurir')
                      ? Colors.grey.shade400
                      : AppColors.primaryBlue, // Sesuaikan warna dengan tema aplikasimu
                  size: 20,
                ),
              ),
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
  final Map<String, dynamic> detailData;
  const AlamatPengirimanCard({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final addressLabel = detailData['address_label'] ?? 'Alamat Rumah';
    final addressDetail =
        detailData['address_detail'] ?? 'Detail tidak tersedia';

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
            addressLabel,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            addressDetail,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: DashedDivider(color: AppColors.borderColor),
          ),
          Text(
            'Titipkan di depan pintu jika tidak ada orang', // Opsional, bisa pakai field note DB kalau ada
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
  final Map<String, dynamic> detailData;
  const DetailBarangCard({super.key, required this.detailData});

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    // Tarik list barang dari relasi DB
    final itemsData = detailData['order_items'] as List<dynamic>? ?? [];

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
        children: itemsData.map((item) {
          final productData = item['products'] ?? {};
          final productName = productData['nama'] ?? 'Produk';
          final pricePerUnit =
              (productData['harga_dasar'] as num?)?.toInt() ?? 0;
          final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
          final subtotal = (item['subtotal'] as num?)?.toInt() ?? 0;
          final isGas = productName.toLowerCase().contains('gas');

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isGas ? Icons.propane : Icons.water_drop,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$quantity Unit x ${_formatRupiah(pricePerUnit)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatRupiah(subtotal),
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
  final Map<String, dynamic> detailData;
  const InformasiPembayaranCard({super.key, required this.detailData});

  String _formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

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
    // 1. Kalkulasi Matematika
    final totalHarga = (detailData['total_harga'] as num?)?.toInt() ?? 0;
    final itemsData = detailData['order_items'] as List<dynamic>? ?? [];

    int subtotalBarang = 0;
    for (var item in itemsData) {
      subtotalBarang += (item['subtotal'] as num?)?.toInt() ?? 0;
    }

    // Karena kita tidak menyimpan ongkir di DB, kita hitung selisihnya
    final ongkir = totalHarga - subtotalBarang;

    // 2. Data Lainnya
    final metodePembayaran = detailData['metode_pembayaran'] ?? 'Tunai';
    final rawDate =
        detailData['created_at']?.toString() ?? DateTime.now().toString();
    final parsedDate = DateTime.parse(rawDate).toLocal();

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
          _buildPaymentRow('Subtotal', _formatRupiah(subtotalBarang)),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Biaya Pengantaran',
            _formatRupiah(ongkir > 0 ? ongkir : 0),
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
                        metodePembayaran,
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
                _formatRupiah(totalHarga),
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
            _formatDate(parsedDate),
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. DashedDivider
// ==========================================
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

// ==========================================
// 7. BuktiPengirimanCard
// ==========================================
class BuktiPengirimanCard extends StatelessWidget {
  final Map<String, dynamic> detailData;
  const BuktiPengirimanCard({super.key, required this.detailData});

  @override
  Widget build(BuildContext context) {
    final buktiUrl = detailData['bukti_pengiriman_url']?.toString();

    if (buktiUrl == null || buktiUrl.isEmpty) {
      return const SizedBox.shrink();
    }

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
            'BUKTI FOTO PENGIRIMAN',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              buktiUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade100,
                child: const Center(
                  child: Text('Gagal memuat bukti foto.'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
