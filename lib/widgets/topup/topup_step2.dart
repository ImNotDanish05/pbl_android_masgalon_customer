import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Wajib di-import untuk input formatter
import 'package:image_picker/image_picker.dart'; 

class TopUpStep2 extends StatelessWidget {
  final String nominal;
  final String keterangan;
  final XFile? buktiTransfer;
  final Function(String) onNominalChanged;
  final Function(String) onKeteranganChanged;
  final Function(XFile) onBuktiSelected;
  final VoidCallback onSubmit;

  const TopUpStep2({
    Key? key,
    required this.nominal,
    required this.keterangan,
    this.buktiTransfer,
    required this.onNominalChanged,
    required this.onKeteranganChanged,
    required this.onBuktiSelected,
    required this.onSubmit,
  }) : super(key: key);

  // Fungsi async untuk membuka galeri dan memilih gambar
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (pickedFile != null) {
      onBuktiSelected(pickedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Unggah Bukti Transfer',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pastikan foto atau screenshot bukti transfer terlihat jelas.', 
          style: TextStyle(color: Colors.grey)
        ),
        const SizedBox(height: 20),

        // Info Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Saldo Anda akan otomatis bertambah setelah admin memverifikasi bukti transfer ini.', 
                  style: TextStyle(fontSize: 12)
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Upload Box
        const Text('Bukti Pembayaran (Receipt)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage, 
          child: Container(
            width: double.infinity,
            padding: buktiTransfer != null 
                ? EdgeInsets.zero 
                : const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: buktiTransfer != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11), 
                    child: FutureBuilder<Uint8List>(
                      future: buktiTransfer!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover, 
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error loading image: ${snapshot.error}'),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  )
                : Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue[800]),
                      const SizedBox(height: 12),
                      const Text('Pilih foto'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _pickImage, 
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue[800],
                        ),
                        child: const Text('Browse File'),
                      )
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // --- INPUT NOMINAL YANG SUDAH DIUPDATE ---
        const Text('Jumlah Nominal Yang Telah Ditransfer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number, // Memunculkan keyboard angka saja
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Memblokir spasi, koma, huruf, dll
            ThousandsSeparatorInputFormatter(),     // Format titik otomatis (class ada di bawah)
          ],
          onChanged: onNominalChanged,
          decoration: InputDecoration(
            prefixText: 'Rp ', // Tulisan otomatis di depan
            prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
            hintText: '0', // Hint text dibuat lebih relevan dengan angka
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        const Text('Keterangan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          onChanged: onKeteranganChanged,
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan untuk admin...',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.send),
            label: const Text('Kirim Bukti'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

// --- CLASS TAMBAHAN UNTUK FORMAT TITIK RIBUAN ---
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Jika input kosong, kembalikan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Hanya ambil angka, buang karakter lain (berjaga-jaga)
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Logika menambah titik setiap 3 digit dari belakang
    String formatted = '';
    int count = 0;
    for (int i = numericOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = numericOnly[i] + formatted;
      count++;
    }

    // Kembalikan teks yang sudah diformat dengan posisi kursor tetap di ujung kanan
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}