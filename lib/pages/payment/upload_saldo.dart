import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';

// Import widget global
import '../../widgets/general_app_bar.dart';
import '../../widgets/bottom_action.dart';
import '../../widgets/input_field.dart'; // <-- Import widget input milikmu

// Import widget lokal
import '../../widgets/verification_info_box.dart';
import '../../widgets/upload_receipt_area.dart';

// Ubah menjadi StatefulWidget karena kita butuh TextEditingController
class UploadReceiptPage extends StatefulWidget {
  const UploadReceiptPage({super.key});

  @override
  State<UploadReceiptPage> createState() => _UploadReceiptPageState();
}

class _UploadReceiptPageState extends State<UploadReceiptPage> {
  // Siapkan controller untuk menangkap teks ketikan user
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  @override
  void dispose() {
    // Wajib di-dispose agar tidak memakan memori HP
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GeneralAppBar(title: 'Top Up Saldo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DummyData.title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DummyData.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            const VerificationInfoBox(),
            const SizedBox(height: 24),

            Text(
              DummyData.uploadTitle,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            UploadReceiptArea(
              onBrowseTap: () {
                print("Membuka galeri hp...");
              },
            ),
            const SizedBox(height: 24),

            // MENGGUNAKAN LOGIN INPUT FIELD MILIKMU
            InputField(
              label: 'Jumlah Nominal Yang Telah Ditransfer',
              hint: 'Masukkan Nominal',
              controller: _nominalController, // Sambungkan ke controller
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // MENGGUNAKAN LOGIN INPUT FIELD MILIKMU
            InputField(
              label: 'Keterangan (Opsional)',
              hint: 'Tambahkan catatan untuk admin...',
              controller: _keteranganController, // Sambungkan ke controller
              maxLines: 4, // Kotak menjadi lebih luas berkat update di atas!
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        label: 'Kirim Bukti',
        icon: Icons.send_outlined,
        onPressed: () {
          // Kamu bisa mengambil isi form dengan _nominalController.text
          print('Nominal: ${_nominalController.text}');
          print('Keterangan: ${_keteranganController.text}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mengunggah bukti transfer...')),
          );
        },
      ),
    );
  }
}
