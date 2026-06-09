class StoreConfig {
  final int id;
  final String qrisImage;

  StoreConfig({
    required this.id,
    required this.qrisImage,
  });

  factory StoreConfig.fromJson(Map<String, dynamic> json) {
    return StoreConfig(
      id: json['id'],
      qrisImage: json['qris_image'] ?? '', // Antisipasi kalau kosong
    );
  }
}