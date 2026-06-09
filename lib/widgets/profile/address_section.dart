import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/profile_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../pages/profile/address_form_page.dart';

class AddressSection extends StatelessWidget {
  final List<AddressModel> addresses;
  final VoidCallback onRefresh;

  const AddressSection({
    super.key,
    required this.addresses,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Tersimpan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // MENGOPER onRefresh KE DALAM CARD
        ...addresses.map((address) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AddressCard(
                address: address,
                onRefresh: onRefresh, // <--- Dioper di sini
              ),
            )),

        const SizedBox(height: 4),

        // Tambah Alamat Baru
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              // MENGGUNAKAN NAVIGATOR YANG BENAR
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddressFormPage(),
                ),
              );
              onRefresh(); // Refresh setelah kembali
            },
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.grey.shade100,
            splashColor: Colors.grey.shade200,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined,
                      color: Colors.grey[500], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Tambah Alamat Baru',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onRefresh; // <--- Menerima operan fungsi di sini

  const _AddressCard({
    required this.address,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (address.isUtama) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'UTAMA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      // NAVIGASI YANG BENAR
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddressFormPage(existingAddress: address),
                        ),
                      );
                      onRefresh(); // Refresh setelah kembali
                    },
                    borderRadius: BorderRadius.circular(20),
                    hoverColor: Colors.white24,
                    splashColor: Colors.white24,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: Colors.white.withOpacity(0.8), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Ubah',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              address.name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              address.detail,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Non-utama card
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // TAMBAHKAN AWAIT & GANTI NAVIGATOR DI SINI JUGA
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddressFormPage(existingAddress: address),
                  ),
                );
                onRefresh(); 
              },
              borderRadius: BorderRadius.circular(20),
              hoverColor: AppColors.darkBlue.withOpacity(0.08),
              splashColor: AppColors.darkBlue.withOpacity(0.12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        color: AppColors.darkBlue, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Ubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}