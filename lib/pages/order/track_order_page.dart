import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../data/dummy_track.dart';
import '../../widgets/estimate_card.dart';
import '../../widgets/driver_info_sheet.dart';

class TrackOrderPage extends StatelessWidget {
  const TrackOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Custom AppBar khusus halaman ini karena ada Subtitle ID Pesanan
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lacak Pesanan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            Text(
              'ID #${TrackOrderDummy.orderId}',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),

      // Menggunakan Stack untuk menumpuk Peta dan UI
      body: Stack(
        children: [
          // 1. LAPISAN BAWAH: Peta OpenStreetMap
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  TrackOrderDummy.driverLocation, // Titik tengah peta
              initialZoom: 15.0, // Skala zoom
            ),
            children: [
              TileLayer(
                // URL ajaib untuk memanggil peta gratis dari OSM
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.masgalon.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: TrackOrderDummy.driverLocation,
                    width: 40,
                    height: 40,
                    // Icon pin lokasi di peta
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. LAPISAN ATAS (Floating Card)
          const SafeArea(
            child: Align(alignment: Alignment.topCenter, child: EstimateCard()),
          ),

          // 3. LAPISAN BAWAH (Driver Sheet)
          const Align(
            alignment: Alignment.bottomCenter,
            child: DriverInfoSheet(),
          ),
        ],
      ),
    );
  }
}
