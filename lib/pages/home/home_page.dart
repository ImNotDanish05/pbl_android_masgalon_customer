import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/dummy_data.dart';
import '../../widgets/home/home_app_bar.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../widgets/home/reward_card.dart';
import '../../widgets/home/promo_banner.dart';
import '../../widgets/home/catalog_section.dart';
import '../../widgets/home/gas_section.dart';
import '../../widgets/home/floating_cart_button.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
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
