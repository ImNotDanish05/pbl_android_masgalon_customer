class ProfileModel {
  final String name;
  final String email;
  final String avatarAsset;
  final String? avatarUrl;
  final int saldo;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.avatarAsset,
    this.avatarUrl,
    required this.saldo,
  });
}

class VoucherModel {
  final String id;
  final String diskonType;
  final bool isUsed;

  // 👇 TRIK GETTER UNTUK UI 👇
  // Ini menyulap data database agar cocok dengan kodingan UI-mu yang sudah ada
  String get title => diskonType;
  String get subtitle => 'Promo spesial untuk transaksi kamu selanjutnya';

  const VoucherModel({
    required this.id,
    required this.diskonType,
    required this.isUsed,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'].toString(),
      // Kiri Dart, Kanan nama kolom di database sesuai gambarmu
      diskonType: json['diskon_type'] ?? 'Voucher Promo',
      isUsed: json['is_used'] ?? false,
    );
  }
}

class AddressModel {
  final String id;
  final String name; // Nyambung ke kolom 'label' di database
  final String detail; // Nyambung ke kolom 'detail_alamat' di database
  final double lat; // Kolom 'lat' (Latitude)
  final double long; // Kolom 'long' (Longitude)
  final bool isUtama; // Nyambung ke kolom 'is_main' di database

  const AddressModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.lat,
    required this.long,
    required this.isUtama,
  });

  // 👇 MESIN PENERJEMAH DARI SUPABASE 👇
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      name: json['label'] ?? 'Tanpa Label',
      detail: json['detail_alamat'] ?? 'Tidak ada detail alamat',

      // Amankan koordinat dari format string/numeric Supabase
      lat: json['lat'] != null
          ? double.tryParse(json['lat'].toString()) ?? 0.0
          : 0.0,
      long: json['long'] != null
          ? double.tryParse(json['long'].toString()) ?? 0.0
          : 0.0,

      // Ambil boolean, default false kalau kosong
      isUtama: json['is_main'] ?? false,
    );
  }
}
