import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dummy_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_client.dart';
import '../../widgets/shared/main_bottom_nav_bar.dart';
import '../../widgets/profile/profile_info_card.dart';
import '../../widgets/shared/saldo_card.dart';
import '../../widgets/profile/voucher_section.dart';
import '../../widgets/profile/address_section.dart';
import '../../widgets/profile/menu_akun_section.dart';
import '../auth/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customer = ref.read(authCustomerProvider);
      debugPrint('========================================');
      debugPrint('👤 PROFILE PAGE DIBUKA');
      debugPrint('App masih kenal user ini:');
      debugPrint('ID       : ${customer?.id}');
      debugPrint('Email    : ${customer?.email}');
      debugPrint('Username : ${customer?.username}');
      debugPrint('Saldo    : Rp ${customer?.saldoAbunemen}');
      debugPrint('========================================');
    });
  }

  void _handleKeluar() async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Debug print
    debugPrint('========================================');
    debugPrint('🚪 CUSTOMER LOGOUT');
    debugPrint('User yang logout:');
    debugPrint('Username : ${ref.read(authCustomerProvider)?.username}');
    debugPrint('Email    : ${ref.read(authCustomerProvider)?.email}');
    debugPrint('========================================');

    // Clear session
    await supabase.auth.signOut();
    ref.read(authCustomerProvider.notifier).state = null;

    debugPrint('✅ Session cleared, navigating to LoginPage');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A56DB),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Saya
            _SectionLabel(label: 'Profil Saya'),
            const SizedBox(height: 10),
            ProfileInfoCard(profile: DummyData.profile),

            const SizedBox(height: 20),

            // Saldo Saya
            _SectionLabel(label: 'Saldo Saya'),
            const SizedBox(height: 10),
            SaldoCard(
              saldo: DummyData.profile.saldo,
              onTap: () => context.push('/topup'),
            ),

            const SizedBox(height: 20),

            // Voucher
            VoucherSection(vouchers: DummyData.voucherList),

            const SizedBox(height: 20),

            // Alamat
            AddressSection(addresses: DummyData.addressList),

            const SizedBox(height: 20),

            // Menu Akun
            MenuAkunSection(onKeluar: _handleKeluar),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 2) {
            context.go('/profile');
          } else if (index == 1) {
            context.go('/orders');
          } else if (index == 3) {
            context.go('/chat');
          }
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}
