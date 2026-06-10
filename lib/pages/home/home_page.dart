import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_client.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../widgets/home/gas_section.dart';
import '../../widgets/home/floating_cart_button.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../auth/login_page.dart';
import '../../services/katalog_service.dart';
import '../../models/product_model.dart';

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
  String searchQuery = '';
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  Future<void> _loadDataKatalog() async {
    try {
      final katalogService = KatalogService();

      // 1. Ambil data mentah (JSON) untuk produk Galon dan Gas sekaligus
      final rawGalon = await katalogService.ambilDaftarProduk();
      final rawGas = await katalogService.ambilDaftarGas();

      // 2. MASAK DATANYA: Konversi keduanya menjadi List<ProductModel>
      final parsedGalon = rawGalon
          .map((json) => ProductModel.fromJson(json))
          .toList();
      final parsedGas = rawGas
          .map((json) => ProductModel.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          // 3. Masukkan hasil masakan ke masing-masing variabel aslinya
          daftarGalonAsli = parsedGalon;
          daftarGasAsli =
              parsedGas; // <--- SEKARANG VARIABEL INI SUDAH ADA ISINYA!
          isLoadingKatalog = false;
        });
      }
    } catch (e) {
      debugPrint('Error ambil katalog/gas: $e');
      if (mounted) {
        setState(() => isLoadingKatalog = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay sedikit biar provider sudah terisi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printCurrentUser();
      _loadDataKatalog();
    });
  }

  void _printCurrentUser() {
    final customer = ref.read(authCustomerProvider);
    debugPrint('========================================');
    debugPrint('🏠 HOME PAGE DIBUKA');
    debugPrint('App masih kenal user ini:');
    debugPrint('ID       : ${customer?.id}');
    debugPrint('Email    : ${customer?.email}');
    debugPrint('Username : ${customer?.username}');
    debugPrint('Saldo    : Rp ${customer?.saldoAbunemen}');
    debugPrint('========================================');
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authCustomerProvider);
    final cartItems = ref.watch(cartProvider);
    final filteredGalon = daftarGalonAsli
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    // if (isLoadingKatalog) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer?.username ?? 'Customer',
                        style: const TextStyle(
                          fontFamily: 'Times New Roman,Times,serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors
                              .textDark, // Warna hitam pekat untuk nama
                        ),
                        maxLines: 1,
                        overflow: TextOverflow
                            .ellipsis, // Potong jika nama terlalu panjang
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                HomeSearchBar(
                  hintText: 'Cari galon atau gas...',
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SaldoCard(
                  saldo: customer?.saldoAbunemen ?? 0,
                  onTap: () => context.push('/topup'),
                ),

                const SizedBox(height: 24),
                const SizedBox(height: 24),
                ProductSection(products: filteredGalon),
              ],
            ),
          ),

          // Floating cart button
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingCartButton(itemCount: cartItems.length),
          ),

          // Temporary logout button for testing
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                debugPrint('========================================');
                debugPrint('🚪 LOGOUT');
                debugPrint('========================================');
                await supabase.auth.signOut();
                ref.read(authCustomerProvider.notifier).state = null;
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
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
          } else if (index == 3) {
            context.go('/chat');
          }
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
