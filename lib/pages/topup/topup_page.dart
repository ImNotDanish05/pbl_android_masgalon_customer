import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan ini
import '../../widgets/topup/topup_stepper.dart';
import '../../widgets/topup/topup_step1.dart';
import '../../widgets/topup/topup_step2.dart';
import '../../widgets/topup/topup_step3.dart';
import '../../models/topup_model.dart'; // Sesuaikan path jika berbeda
import '../../services/payment/topup_service.dart'; // Sesuaikan path jika berbeda
import '../../widgets/shared/custom_app_bar.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({Key? key}) : super(key: key);

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  int _currentStep = 1;
  bool _isLoading = false; // State untuk loading

  // Form State
  XFile? _buktiTransfer;
  String _nominal = '';
  String _keterangan = '';

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  // Fungsi submit yang sudah di-update menjadi async
  Future<void> _submitData() async {
    // 1. Validasi Input Dasar
    if (_buktiTransfer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload bukti transfer terlebih dahulu'),
        ),
      );
      return;
    }

    if (_nominal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal tidak boleh kosong')),
      );
      return;
    }

    // 2. Set Loading True
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User belum login');
      }

      final topupService = TopupService();

      // 3. Upload gambar bukti transfer ke Supabase Storage
      final imageUrl = await topupService.uploadBuktiTransfer(_buktiTransfer!);

      // 4. Bersihkan nominal dari karakter selain angka
      String cleanNominal = _nominal.replaceAll(RegExp(r'[^0-9]'), '');
      int nominalInt = int.parse(cleanNominal);

      // 5. Buat object model
      final request = TopupRequest(
        customerId: userId,
        nominal: nominalInt,
        buktiTransferUrl: imageUrl,
      );

      // 6. Simpan ke database
      await topupService.submitTopupRequest(request);

      // 7. Lanjut ke Step 3 jika sukses
      _nextStep();
    } catch (e) {
      // Tampilkan notifikasi error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim topup: ${e.toString()}')),
      );
    } finally {
      // 8. Matikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Top Up Saldo',
        showBackButton: _currentStep < 3,
        showNotifications: false,
        onBackPressed: () {
          if (_isLoading) return;
          if (_currentStep == 1) {
            Navigator.pop(context);
          } else {
            _prevStep();
          }
        },
      ),
      body: Stack(
        // Gunakan stack untuk menimpa layar dengan loading spinner
        children: [
          Column(
            children: [
              if (_currentStep < 3)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: TopUpStepper(currentStep: _currentStep),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildCurrentStepWidget(context),
                ),
              ),
            ],
          ),

          // Overlay Loading
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget(BuildContext context) {
    if (_currentStep == 1) {
      return TopUpStep1(
        onNext: _nextStep,
        onBack: () => Navigator.pop(context),
      );
    } else if (_currentStep == 2) {
      return TopUpStep2(
        nominal: _nominal,
        keterangan: _keterangan,
        buktiTransfer: _buktiTransfer,
        onNominalChanged: (val) => setState(() => _nominal = val),
        onKeteranganChanged: (val) => setState(() => _keterangan = val),
        onBuktiSelected: (file) => setState(() => _buktiTransfer = file),
        onSubmit: _isLoading
            ? () {}
            : _submitData, // Disable tombol saat loading
      );
    } else {
      return const TopUpStep3();
    }
  }
}
