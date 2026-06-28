import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/katalog_service.dart';
import '../../widgets/home/floating_cart_button.dart';
import '../../widgets/home/gas_section.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../../widgets/shared/saldo_card.dart';
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Halo, ${customer?.username ?? 'Customer'}!'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      color: Colors.black87,
                      tooltip: 'Keluar',
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                ),
                const SizedBox(height: 48),
                ProductSection(products: daftarGalonAsli),
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingCartButton(itemCount: cartItems.length),
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
          } else if (index == 3) {
            context.go('/chat');
          }
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
