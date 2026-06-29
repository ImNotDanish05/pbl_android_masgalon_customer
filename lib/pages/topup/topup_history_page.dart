import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../models/topup_model.dart';
import '../../services/payment/topup_service.dart';
import '../../widgets/shared/general_app_bar.dart';

class TopUpHistoryPage extends ConsumerStatefulWidget {
  const TopUpHistoryPage({super.key});

  @override
  ConsumerState<TopUpHistoryPage> createState() => _TopUpHistoryPageState();
}

class _TopUpHistoryPageState extends ConsumerState<TopUpHistoryPage> {
  final _topupService = TopupService();
  
  // Future untuk memuat transaksi
  Future<List<TopupRequest>>? _historyFuture;
  
  // State untuk filter bulanan
  bool _isLoadingFilters = true;
  String? _filterError;
  List<DateTime> _monthsList = [];
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadFiltersAndHistory();
  }

  // Fungsi untuk memuat daftar bulan yang tersedia dari database, baru memuat riwayat bulan terbaru
  Future<void> _loadFiltersAndHistory() async {
    setState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });
    try {
      final months = await _topupService.fetchUniqueTransactionMonths();
      if (mounted) {
        setState(() {
          _monthsList = months;
          _isLoadingFilters = false;
          if (months.isNotEmpty) {
            // Default pilih bulan terbaru (paling atas)
            _selectedMonth = months.first;
            _loadHistory();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filterError = e.toString();
          _isLoadingFilters = false;
        });
      }
    }
  }

  void _loadHistory() {
    if (_selectedMonth == null) return;
    setState(() {
      _historyFuture = _topupService.fetchMyTopupHistoryByMonth(
        _selectedMonth!.year,
        _selectedMonth!.month,
      );
    });
  }

  String _getMonthNameIndonesian(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  String _formatRupiah(int value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime.toLocal());
  }

  void _showDetailDialog(TopupRequest request) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Top Up',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildDetailRow('Nominal', _formatRupiah(request.nominal), isBold: true),
                  const SizedBox(height: 8),
                  _buildDetailRow('Tanggal', _formatDate(request.createdAt)),
                  const SizedBox(height: 8),
                  _buildDetailStatusRow('Status', request.isVerified),
                  const SizedBox(height: 20),
                  Text(
                    'Bukti Transfer:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (request.buktiTransferUrl != null && request.buktiTransferUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: request.buktiTransferUrl!,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bukti transfer tidak tersedia.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStatusRow(String label, bool isVerified) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textGrey,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isVerified ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isVerified ? 'Berhasil' : 'Menunggu Verifikasi',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isVerified ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: GeneralAppBar(
        title: 'Riwayat Top Up',
        onBackPressed: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadFiltersAndHistory();
        },
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    // 1. Sedang memuat filter bulan unik
    if (_isLoadingFilters) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Terjadi error saat memuat filter
    if (_filterError != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 150,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Gagal memuat filter bulan: $_filterError',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ),
        ),
      );
    }

    // 3. User sama sekali tidak memiliki riwayat transaksi apa pun
    if (_monthsList.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 70,
                  color: AppColors.textGrey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Riwayat Top Up',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Semua transaksi pengisian saldo Anda\nakan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 4. Tampilkan halaman lengkap dengan filter bulan yang didapat dinamis
    return Column(
      children: [
        // ── HORIZONTAL MONTH SELECTOR ───────────────────────────
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: _monthsList.length,
            itemBuilder: (context, index) {
              final monthDate = _monthsList[index];
              final isSelected = _selectedMonth != null &&
                  _selectedMonth!.year == monthDate.year &&
                  _selectedMonth!.month == monthDate.month;
              final label = '${_getMonthNameIndonesian(monthDate.month)} ${monthDate.year}';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.darkBlue,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.darkBlue,
                  backgroundColor: const Color(0xFFF0F4F8),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMonth = monthDate;
                        _loadHistory();
                      });
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  showCheckmark: false,
                  elevation: 0,
                  side: BorderSide.none,
                ),
              );
            },
          ),
        ),
        
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // ── TRANSACTIONS LIST UNTUK BULAN TERPILIH ─────────────
        Expanded(
          child: _historyFuture == null
              ? const SizedBox.shrink()
              : FutureBuilder<List<TopupRequest>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Gagal memuat riwayat: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final history = snapshot.data ?? [];

                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada transaksi di bulan ini.',
                          style: GoogleFonts.poppins(color: AppColors.textGrey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return GestureDetector(
                          onTap: () => _showDetailDialog(item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: item.isVerified
                                        ? Colors.green[50]
                                        : Colors.orange[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.isVerified
                                        ? Icons.add_moderator_outlined
                                        : Icons.hourglass_empty_rounded,
                                    color: item.isVerified
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatRupiah(item.nominal),
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(item.createdAt),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isVerified
                                        ? Colors.green[50]
                                        : Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.isVerified ? 'Berhasil' : 'Pending',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: item.isVerified
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
