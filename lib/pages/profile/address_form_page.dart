import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../services/address_service.dart';

class AddressFormPage extends StatefulWidget {
  /// Kalau null → mode Tambah, kalau diisi → mode Edit
  final AddressModel? existingAddress;
  // Siapkan supir untuk mengendalikan peta

  const AddressFormPage({super.key, this.existingAddress});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _mapController = MapController();

  // Default koordinat: Jakarta Selatan
  LatLng _selectedLocation = const LatLng(-6.2607, 106.7816);

  String _selectedLabel = 'Rumah';
  bool _isUtama = false;
  bool _isLoadingLocation = false;

  bool get _isEditMode => widget.existingAddress != null;

  final List<String> _labelOptions = ['Rumah', 'Kantor', 'Apartemen'];

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      final addr = widget.existingAddress!;

      if (addr.name.contains(' - ')) {
        // Pisahkan teks berdasarkan tanda ' - '
        final parts = addr.name.split(' - ');

        // Cek apakah kata pertamanya cocok dengan opsi label kita (Rumah/Kantor/Apartemen)
        if (_labelOptions.contains(parts[0])) {
          _selectedLabel = parts[0];
        } else {
          _selectedLabel = 'Rumah';
        }

        // Masukkan sisa katanya ke dalam kolom input Nama Lokasi
        // (.sublist dipakai untuk berjaga-jaga kalau nama lokasinya kebetulan mengandung tanda strip juga)
        _namaController.text = parts.sublist(1).join(' - ');
      } else {
        _namaController.text = addr.name;
        _selectedLabel = 'Rumah';
      }
      _alamatController.text = addr.detail;
      _isUtama = addr.isUtama;
      // Langsung arahkan peta ke koordinat alamat yang sedang diedit
      _selectedLocation = LatLng(addr.lat, addr.long);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _useCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // ── TAP MAP → pindah marker + reverse geocode ─────────────
  Future<void> _onMapTap(TapPosition tapPos, LatLng latlng) async {
    setState(() => _selectedLocation = latlng);
    await _reverseGeocode(latlng);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // 1. Cek & minta permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showSnackbar('Izin lokasi ditolak. Aktifkan di pengaturan browser.');
        return;
      }

      // 2. Ambil posisi GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latlng = LatLng(position.latitude, position.longitude);

      // 3. Update marker & pindah kamera map
      setState(() => _selectedLocation = latlng);
      _mapController.move(latlng, 16);

      // 4. Reverse geocode → isi inputan alamat
      await _reverseGeocode(latlng);
    } catch (e) {
      _showSnackbar('Gagal mendapatkan lokasi: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }


  Future<void> _reverseGeocode(LatLng latlng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${latlng.latitude}'
        '&lon=${latlng.longitude}'
        '&format=json'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'MasGalonApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'] as String?;

        if (displayName != null && mounted) {
          setState(() => _alamatController.text = displayName);
        }
      }
    } catch (e) {
      // Gagal reverse geocode — biarkan user isi manual
      debugPrint('Reverse geocode error: $e');
    }
  }

  // ── NOMINATIM FORWARD GEOCODE (Teks -> Kordinat) ─────────────
  Future<void> _geocodeAndMovePeta(String teksAlamat) async {
    if (teksAlamat.length < 5) return; // Jangan cari kalau baru ngetik dikit

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$teksAlamat&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'MasGalonApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final newLatLng = LatLng(lat, lon);

          if (mounted) {
            setState(() => _selectedLocation = newLatLng);
            _mapController.move(newLatLng, 16);
          }
        }
      }
    } catch (e) {
      debugPrint('Geocode error: $e');
    }
  }

  Future<void> _simpanAlamat() async {
    if (_namaController.text.isEmpty || _alamatController.text.isEmpty) {
      _showSnackbar('Nama lokasi dan alamat lengkap wajib diisi');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final addressService = AddressService();
      final namaLokasiGabungan = '$_selectedLabel - ${_namaController.text}';

      if (_isEditMode) {
        await addressService.ubahAlamat(
          idAlamat: widget.existingAddress!.id,
          label: namaLokasiGabungan,
          detail: _alamatController.text,
          lat: _selectedLocation.latitude,
          long: _selectedLocation.longitude,
          isUtama: _isUtama,
        );
      } else {
        await addressService.tambahAlamat(
          label: namaLokasiGabungan,
          detail: _alamatController.text,
          lat: _selectedLocation.latitude,
          long: _selectedLocation.longitude,
          isUtama: _isUtama,
        );
      }

      if (mounted) Navigator.pop(context); // Tutup loading
      if (mounted) Navigator.pop(context); // Kembali ke profil
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackbar('Gagal menyimpan alamat: $e');
    }
  }

  Future<void> _hapusAlamat() async {
    // 1. Tampilkan Dialog Konfirmasi agar tidak tidak sengaja terhapus
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Alamat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah kamu yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Eksekusi Penghapusan ke Supabase
    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Panggil service untuk menghapus berdasarkan ID
      await AddressService().hapusAlamat(widget.existingAddress!.id);

      if (mounted) Navigator.pop(context); // Tutup loading dialog
      if (mounted)
        Navigator.pop(
          context,
        ); // Kembali ke halaman Profil (Otomatis memicu onRefresh)
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup loading dialog
      _showSnackbar('Gagal menghapus alamat: $e');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.darkBlue,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              _isEditMode ? 'Ubah Alamat' : 'Tambah Alamat Baru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
          ],
        ),
        actions: [
          // Tombol hapus hanya muncul jika sedang dalam Mode Edit (bukan tambah baru)
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: _hapusAlamat,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 26,
                ),
                tooltip: 'Hapus Alamat',
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── MAP SECTION ──────────────────────────────────
              SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15,
                        onTap: _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.masgalon.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: AppColors.darkBlue,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Gunakan Lokasi Saat Ini button
                    Positioned(
                      bottom: 32,
                      right: 16,
                      child: GestureDetector(
                        onTap: _isLoadingLocation ? null : _useCurrentLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Loading spinner atau icon
                              _isLoadingLocation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.darkBlue,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.my_location,
                                      color: AppColors.darkBlue,
                                      size: 16,
                                    ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoadingLocation
                                    ? 'Mencari lokasi...'
                                    : 'Gunakan Lokasi Saat Ini',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── FORM SECTION ─────────────────────────────────
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Pilih Label Alamat',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: _labelOptions.map((label) {
                              final isSelected = _selectedLabel == label;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedLabel = label),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkBlue
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.darkBlue
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                          _buildLabel('NAMA LOKASI'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _namaController,
                            hint: 'Contoh: Kosan, Rumah Ortu',
                          ),
                          const SizedBox(height: 20),
                          // 👆
                          _buildLabel('ATUR SEBAGAI'),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => setState(() => _isUtama = !_isUtama),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Utama',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.darkBlue,
                                        width: 2,
                                      ),
                                    ),
                                    child: _isUtama
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: AppColors.darkBlue,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('ALAMAT LENGKAP'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _alamatController,
                            hint:
                                'Ketik alamat lalu tekan Enter di keyboard untuk mencari di peta...',
                            maxLines: 2,
                            onSubmitted: (value) => _geocodeAndMovePeta(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── SIMPAN BUTTON (fixed bottom) ──────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _simpanAlamat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isEditMode ? 'Simpan Perubahan' : 'Simpan Alamat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.search,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 14),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
      ),
    );
  }
}
