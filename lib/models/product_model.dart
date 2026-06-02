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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. Ambil kolom 'nama' dari database (bukan 'name')
    final namaProduk = json['nama'] ?? 'Produk Tanpa Nama';

    // Logika otomatis menentukan gambar lokal dan subtitle berdasarkan teks nama produk
    String imageAssetDefault = 'assets/images/default_galon.png';
    String subtitleDefault = 'Refill / Isi Ulang Saja';
    String brandDefault = 'Aqua';

    if (namaProduk.toLowerCase().contains('gas')) {
      imageAssetDefault =
          'assets/images/default_gas.png'; // Pastikan path asset gas kamu benar
      subtitleDefault = 'Tabung Gas Dapur Aman';
      brandDefault = 'Pertamina';
    }

    return ProductModel(
      id: json['id'].toString(),
      name: namaProduk,

      // 2. Ambil kolom 'harga_dasar' dari database (bukan 'price')
      price: json['harga_dasar'] != null
          ? int.tryParse(json['harga_dasar'].toString()) ?? 0
          : 0,

      // Karena di database kamu tidak ada kolom gambar dan kategori, kita pakai logika lokal di atas
      imageAsset: imageAssetDefault,
      brand: brandDefault,
      badge: namaProduk.toLowerCase().contains('3kg') ? 'TERLARIS' : null,
      subtitle: subtitleDefault,
    );
  }
}
