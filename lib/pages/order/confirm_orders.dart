import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/orders_service.dart';
import '../../services/address_service.dart';
import '../../widgets/order/confirm_items_section.dart';
import '../../widgets/order/confirm_voucher_section.dart';
import '../../widgets/order/confirm_delivery_section.dart';
import '../../widgets/order/confirm_payment_section.dart';
import '../../widgets/order/confirm_summary_section.dart';
import '../../widgets/shared/general_app_bar.dart';
import '../../widgets/bottom_action.dart';
import '../../models/profile_model.dart';
import '../../pages/profile/address_form_page.dart';

class ConfirmOrderPage extends ConsumerStatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  ConsumerState<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends ConsumerState<ConfirmOrderPage> {
  String _selectedDelivery = '';
  String _selectedPayment = 'Abunemen';

  // Menyimpan alamat dan opsi pengiriman dari database
  Map<String, dynamic>? _alamatUtama;
  List<Map<String, dynamic>> _opsiPengiriman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataAwal();
  }

  Future<void> _ambilDataAwal() async {
    try {
      final addressService = AddressService();
      final orderService = OrderService();

      // Minta pelayan mengambil data dari Supabase
      final alamatResponse = await addressService.ambilAlamatUtama();
      final kurirResponse = await orderService.ambilOpsiPengiriman();

      if (mounted) {
        setState(() {
          _alamatUtama = alamatResponse;
          _opsiPengiriman = kurirResponse;

          // Set default kurir ke yang paling atas (termurah) jika ada
          if (_opsiPengiriman.isNotEmpty) {
            _selectedDelivery = _opsiPengiriman.first['tipe'].toString();
          }

          _isLoading = false; // Matikan loading spinner
        });
      }
    } catch (e) {
      debugPrint('Error ambil data awal: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _prosesPembayaran(int totalBayar, int hargaKurir) async {
    final customer = ref.read(authCustomerProvider);
    final cartItems = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    // Validasi data
    if (customer == null || _alamatUtama == null || cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data belum lengkap untuk checkout.')),
      );
      return;
    }

    // Validasi saldo
    if (_selectedPayment == 'Abunemen') {
      if (customer.saldoAbunemen < totalBayar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Saldo tidak mencukupi! Silakan Top Up atau pilih COD.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Cari ID kurir (shipping_option_id) berdasarkan nama kurir yang dipilih di UI
    int? selectedShippingId;
    for (var kurir in _opsiPengiriman) {
      if (kurir['tipe'] == _selectedDelivery) {
        selectedShippingId = kurir['id'];
        break;
      }
    }

    // Munculkan loading muter-muter
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final orderService = OrderService();

      // Kirim data ke Service untuk masuk database
      await orderService.buatPesananBaru(
        customerId: customer.id,
        alamatUtama: _alamatUtama!,
        cartItems: cartItems,
        shippingOptionId: selectedShippingId ?? 1,
        paymentMethod: _selectedPayment,
        totalHarga: totalBayar,
        saldoSaatIni: customer.saldoAbunemen,
      );

      // Potong saldo
      if (_selectedPayment == 'Abunemen') {
        ref.read(authCustomerProvider.notifier).updateSaldo(
          customer.saldoAbunemen - totalBayar,
        );
      }

      // Bersihkan keranjang
      cartNotifier.clearCart();

      // Pindah ke layar sukses
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        context.go('/orders-success', extra: {
          'totalBayar': totalBayar,
          'metodePembayaran': _selectedPayment,
          'tipePengiriman': _selectedDelivery,
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Tutup loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final customer = ref.watch(authCustomerProvider);

    // 1. Hitung biaya kurir yang dipilih
    int deliveryFee = 0;
    for (var kurir in _opsiPengiriman) {
      if (kurir['tipe'] == _selectedDelivery) {
        deliveryFee = (kurir['harga'] as num).toInt();
        break;
      }
    }

    final int subtotal = cartNotifier.totalPrice;
    final int total = subtotal + deliveryFee;

    // 2. Mapping data kurir dari DB ke format yang dibutuhkan Widget
    final Map<String, dynamic> formattedDeliveryOptions = {};
    for (var kurir in _opsiPengiriman) {
      final String tipe = kurir['tipe'].toString();
      final int harga = (kurir['harga'] as num).toInt();
      formattedDeliveryOptions[tipe] = {
        'label': tipe,
        'subtitle': 'Pengiriman tipe $tipe',
        'price': harga,
      };
    }

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: GeneralAppBar(
          title: 'Konfirmasi Pesanan',
          onBackPressed: () => context.pop(),
        ),
        body: const Center(child: Text('Keranjang Anda kosong.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: GeneralAppBar(
        title: 'Konfirmasi Pesanan',
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION ALAMAT ---
                  if (_alamatUtama != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _alamatUtama!['label'] ?? 'Alamat Pengiriman',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final addressModel = AddressModel.fromJson(
                                    _alamatUtama!,
                                  );

                                  // 2. Buka halaman Edit
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddressFormPage(
                                        existingAddress: addressModel,
                                      ),
                                    ),
                                  );

                                  // 3. Setelah kembali dari halaman Edit, refresh data agar alamat terupdate di layar
                                  _ambilDataAwal();
                                },
                                child: const Text('Ubah'),
                              ),
                            ],
                          ),
                          Text(
                            _alamatUtama!['detail_alamat'] ?? '-',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Belum ada alamat utama!',
                            style: TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: () => context.push('/profile/edit'),
                            child: const Text('Tambah'),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // --- SECTION ITEM ---
                  ConfirmItemsSection(items: cartItems),

                  const SizedBox(height: 16),

                  // --- SECTION VOUCHER ---
                  ConfirmVoucherSection(
                    onVoucher: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih voucher')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- SECTION PENGIRIMAN ---
                  ConfirmDeliverySection(
                    selectedDelivery: _selectedDelivery,
                    deliveryOptions:
                        formattedDeliveryOptions, // 👈 Masukkan data dari DB
                    onSelected: (value) =>
                        setState(() => _selectedDelivery = value),
                  ),
                  const SizedBox(height: 16),

                  // --- SECTION PEMBAYARAN ---
                  ConfirmPaymentSection(
                    selectedPayment: _selectedPayment,
                    paymentOptions:  {
                      'Abunemen': {
                        'title': 'Saldo Abunemen',
                        'subtitle': customer != null
                            ? 'Saldo: Rp ${customer.saldoAbunemen}'
                            : 'Saldo tidak tersedia',
                      },
                      'COD': {
                        'title': 'Cash on Delivery',
                        'subtitle': 'Bayar saat barang sampai',
                      },
                    },
                    onSelected: (value) =>
                        setState(() => _selectedPayment = value),
                  ),
                  const SizedBox(height: 16),

                  // --- SECTION TOTAL ---
                  ConfirmSummarySection(
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    total: total,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: BottomActionButton(
        label: 'Bayar Sekarang',
        onPressed: () => _prosesPembayaran(total, deliveryFee),
      ),
    );
  }
}
