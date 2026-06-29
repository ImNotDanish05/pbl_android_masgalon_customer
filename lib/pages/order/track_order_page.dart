import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart'; 
import '../../services/order/orders_service.dart'; 
import '../../widgets/shared/custom_app_bar.dart';
import '../../widgets/order/estimate_card.dart';
import '../../widgets/driver_info_sheet.dart';

class TrackOrderPage extends StatefulWidget {
  final OrderModel order; // 👈 Siapkan penangkap tas ransel data

  const TrackOrderPage({super.key, required this.order});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  final _orderService = OrderService();
  late Stream<Map<String, dynamic>> _orderDetailStream;
  LatLng? _courierLocation;
  StreamSubscription<LatLng>? _courierLocationSubscription;

  @override
  void initState() {
    super.initState();
    _orderDetailStream = _orderService.streamOrderDetail(widget.order.id);
    _setupLocationTracking();
  }

  void _setupLocationTracking() {
    // 1. Ambil lokasi terakhir dari tracking_logs (jika sudah ada)
    _orderService.fetchLatestCourierLocation(widget.order.id).then((loc) {
      if (loc != null && mounted) {
        setState(() {
          _courierLocation = loc;
        });
      }
    });

    // 2. Dengar stream koordinat kurir secara real-time
    _courierLocationSubscription = _orderService
        .streamCourierLocation(widget.order.id)
        .listen((loc) {
      if (mounted) {
        setState(() {
          _courierLocation = loc;
        });
      }
    });
  }

  @override
  void dispose() {
    _courierLocationSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // 👇 1. MENGGUNAKAN CUSTOM APP BAR
      appBar: CustomAppBar(
        showBackButton: true,
        showNotifications: false,
        backgroundColor: Colors.white,
        onBackPressed: () => context.pop(),
        // Gunakan titleWidget karena kita butuh 2 baris (Judul & ID)
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              'ID #${widget.order.id.substring(0, 8).toUpperCase()}', 
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),

      ),

      // 👇 2. MENARIK DATA KOORDINAT DARI DATABASE SECARA REAL-TIME
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _orderDetailStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && !snapshot.hasData) {
            return Center(child: Text('Gagal memuat peta: ${snapshot.error}'));
          }
          if ((!snapshot.hasData || snapshot.data == null) &&
              !snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final detailData = snapshot.data!;

          // Ambil titik Latitude & Longitude dari Database
          // Jika kosong, sistem otomatis mengarahkan ke koordinat cadangan (titik tengah Tembalang, Semarang)
          final lat =
              (detailData['address_lat'] as num?)?.toDouble() ?? -7.0493;
          final lng =
              (detailData['address_long'] as num?)?.toDouble() ?? 110.4208;
          final targetLocation = LatLng(lat, lng);

          return Stack(
            children: [
              // LAPISAN BAWAH: Peta OpenStreetMap
              FlutterMap(
                options: MapOptions(
                  initialCenter: targetLocation, // Peta otomatis fokus ke alamat
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.masgalon.app',
                  ),
                  if (_courierLocation != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [_courierLocation!, targetLocation],
                          color: AppColors.primaryBlue.withOpacity(0.8),
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: targetLocation, // Pin diletakkan di alamat tujuan
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                      if (_courierLocation != null)
                        Marker(
                          point: _courierLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.motorcycle,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // LAPISAN ATAS: Kartu Estimasi Waktu
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  // Nanti lempar detailData ke dalam sini: EstimateCard(detailData: detailData)
                  child: EstimateCard(
                    detailData: detailData,
                    courierLocation: _courierLocation,
                    targetLocation: targetLocation,
                  ),
                ),
              ),

              // LAPISAN BAWAH: Kartu Info Kurir
              Align(
                alignment: Alignment.bottomCenter,
                // Nanti lempar detailData ke dalam sini: DriverInfoSheet(detailData: detailData)
                child: DriverInfoSheet(
                    detailData: detailData, order: widget.order),
              ),
            ],
          );
        },
      ),
    );
  }
}