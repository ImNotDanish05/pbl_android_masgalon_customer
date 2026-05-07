import 'dart:io';
import 'package:flutter/material.dart';

class TopUpStep2 extends StatelessWidget {
  final String nominal;
  final String keterangan;
  final File? buktiTransfer;
  final Function(String) onNominalChanged;
  final Function(String) onKeteranganChanged;
  final Function(File) onBuktiSelected;
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

  void _pickImage() {
    // TODO: Implementasi image_picker di sini
    // Contoh dummy logic:
    // final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (file != null) onBuktiSelected(File(file.path));
    print('Pilih file diklik');
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
        const Text('Pastikan foto atau screenshot bukti transfer terlihat jelas.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        // Info Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(child: Text('Saldo Anda akan otomatis bertambah setelah admin memverifikasi bukti transfer ini.', style: TextStyle(fontSize: 12))),
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
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue[800]),
                const SizedBox(height: 12),
                const Text('Pilih foto atau tarik file ke sini'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[800],),
                  child: const Text('Browse File'),
                  
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Inputs
        const Text('Jumlah Nominal Yang Telah Ditransfer', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: onNominalChanged,
          decoration: InputDecoration(
            hintText: 'Masukkan Nominal',
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