import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/katalog_service.dart';
import '../../widgets/home/gas_section.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../widgets/shared/rupiah_format.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;
  List<ProductModel> daftarGalonAsli = [];
  List<ProductModel> daftarGasAsli = [];
  bool isLoadingKatalog = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printCurrentUser();
      _loadDataKatalog();
    });
    Future.microtask(() {
      ref.read(authCustomerProvider.notifier).refreshProfile();
    });
  }

  Future<void> _loadDataKatalog() async {
    try {
      final katalogService = KatalogService();
      final rawGalon = await katalogService.ambilDaftarProduk();
      final rawGas = await katalogService.ambilDaftarGas();

      final parsedGalon = rawGalon
          .map((json) => ProductModel.fromJson(json))
          .toList();
      final parsedGas = rawGas
          .map((json) => ProductModel.fromJson(json))
          .toList();

      if (!mounted) return;
      setState(() {
        daftarGalonAsli = parsedGalon;
        daftarGasAsli = parsedGas;
        isLoadingKatalog = false;
      });
    } catch (e) {
      debugPrint('Error ambil katalog/gas: $e');
      if (mounted) {
        setState(() => isLoadingKatalog = false);
      }
    }
  }

  void _printCurrentUser() {
    final customer = ref.read(authCustomerProvider);
    debugPrint('========================================');
    debugPrint('HOME PAGE DIBUKA');
    debugPrint('App masih kenal user ini:');
    debugPrint('ID       : ${customer?.id}');
    debugPrint('Email    : ${customer?.email}');
    debugPrint('Username : ${customer?.username}');
    debugPrint('Saldo    : Rp ${customer?.saldoAbunemen}');
    debugPrint('========================================');
  }

  Future<void> _handleLogout() async {
    debugPrint('========================================');
    debugPrint('LOGOUT');
    debugPrint('========================================');
    await ref.read(authCustomerProvider.notifier).logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authCustomerProvider);
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeSearchBar(hintText: 'Cari galon atau gas...'),
                const SizedBox(height: 16),
                SaldoCard(
                  saldo: customer?.saldoAbunemen ?? 0,
                  onTap: () {
                    context.push('/topup').then((_) {
                      if (mounted) {
                        ref.read(authCustomerProvider.notifier).refreshProfile();
                      }
                    });
                  },
                  onHistoryTap: () {
                    context.push('/topup/history').then((_) {
                      if (mounted) {
                        ref.read(authCustomerProvider.notifier).refreshProfile();
                      }
                    });
                  },
                ),
                const SizedBox(height: 48),
                ProductSection(products: daftarGalonAsli),
              ],
            ),
          ),
          if (cartItems.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pesanan Terpilih:',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cartItems.fold<int>(0, (sum, item) => sum + item.quantity)} Item (${ref.read(cartProvider.notifier).totalPrice.toRupiah})',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D52A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.push('/confirm-order');
                        },
                        child: Text(
                          'Beli Sekarang',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/orders');
          } else if (index == 2) {
            context.go('/profile');
          }
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
