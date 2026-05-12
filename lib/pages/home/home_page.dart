import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/dummy_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_client.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../widgets/home/reward_card.dart';
import '../../widgets/home/promo_banner.dart';
import '../../widgets/home/catalog_section.dart';
import '../../widgets/home/gas_section.dart';
import '../../widgets/home/floating_cart_button.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../auth/login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    // Delay sedikit biar provider sudah terisi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printCurrentUser();
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
                Text("Halo, ${customer?.username ?? 'Customer'}! 👋"),
                const SizedBox(height: 8),
                HomeSearchBar(hintText: 'Cari galon atau gas...'),
                const SizedBox(height: 16),
                SaldoCard(
                  saldo: DummyData.saldoAbunemen,
                  onTap: () => context.push('/topup'),
                ),
                const SizedBox(height: 14),
                RewardCard(
                  points: DummyData.pointRewards,
                  pointTarget: DummyData.pointTarget,
                ),
                const SizedBox(height: 14),
                PromoBanner(
                  label: DummyData.promoLabel,
                  title: DummyData.promoTitle,
                ),
                const SizedBox(height: 24),
                CatalogSection(products: DummyData.galonList),
                const SizedBox(height: 24),
                GasSection(products: DummyData.gasList),
              ],
            ),
          ),

          // Floating cart button
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingCartButton(itemCount: DummyData.cartItemCount),
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
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
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
          }else if (index == 1) {
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
