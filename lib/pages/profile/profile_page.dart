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
import '../../services/address_service.dart';
import '../../models/profile_model.dart';
import '../../services/voucher_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _currentNavIndex = 2;
  List<AddressModel> _daftarAlamat = [];
  bool _isLoadingAlamat = true;
  List<VoucherModel> _daftarVoucher = [];
  bool _isLoadingVoucher = true;

  // 2. Buat fungsi pengambil data dari Supabase
  Future<void> _loadAlamat() async {
    try {
      final addressService = AddressService();
      final data = await addressService.ambilDaftarAlamat();

      if (mounted) {
        setState(() {
          _daftarAlamat = data;
          _isLoadingAlamat = false;
        });
      }
    } catch (e) {
      debugPrint('Error ambil alamat: $e');
      if (mounted) {
        setState(() => _isLoadingAlamat = false);
      }
    }
  }

  // 👇 2. BUAT FUNGSI AMBIL VOUCHER DARI DATABASE 👇
  Future<void> _loadVoucher() async {
    try {
      final voucherService = VoucherService();
      final data = await voucherService.ambilDaftarVoucher();

      if (mounted) {
        setState(() {
          _daftarVoucher = data;
          _isLoadingVoucher = false;
        });
      }
    } catch (e) {
      debugPrint('Error ambil voucher: $e');
      if (mounted) {
        setState(() => _isLoadingVoucher = false);
      }
    }
  }

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
      _loadAlamat();
      _loadVoucher();
    });
  }

  void _handleKeluar() async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = ref.watch(authCustomerProvider);
    final profileSaatIni = ProfileModel(
      name: customer?.username ?? 'Customer',
      email: customer?.email ?? '-',
      avatarAsset: DummyData.profile.avatarAsset,
      avatarUrl: customer?.avatarUrl,
      saldo: DummyData.profile.saldo,
    );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(label: 'Profil Saya'),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF1A56DB)),
                    onPressed: () {
                      // Pindah ke halaman EditProfilePage saat ikon diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ).then((_) {
                        // Blok ini akan berjalan saat user kembali dari halaman edit profil.
                        // Kamu bisa memanggil fungsi refresh data di sini jika diperlukan agar data terbaru langsung muncul.
                        setState(() {}); 
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ProfileInfoCard(profile: profileSaatIni),

            const SizedBox(height: 20),

            // Saldo Saya
            _SectionLabel(label: 'Saldo Saya'),
            const SizedBox(height: 10),
            SaldoCard(
              saldo: customer?.saldoAbunemen ?? 0,
              onTap: () => context.push('/topup'),
            ),

            const SizedBox(height: 20),

            // Voucher
            VoucherSection(vouchers: _daftarVoucher),

            const SizedBox(height: 20),

            // Alamat
            _isLoadingAlamat
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) 
                : AddressSection(
                    addresses: _daftarAlamat,
                    onRefresh:
                        _loadAlamat, 
                  ),
            const SizedBox(height: 20),

            // Menu Akun
            MenuAkunSection(
              onTap: () {
                context.push('/orders/history');
              },
              onKeluar: _handleKeluar,
            ),

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
