class ProductModel {
  final String id;
  final String brand;
  final String name;
  final int price;
  final String imageAsset;
  final String? badge; // e.g. "TERLARIS"
  final String? subtitle; // e.g. "Refill / Isi Ulang Saja"

  const ProductModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.imageAsset,
    this.badge,
    this.subtitle,
  });
}
