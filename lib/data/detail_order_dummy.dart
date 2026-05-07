class OrderItem {
  final String imageUrl;
  final String name;
  final int quantity;
  final int pricePerUnit;

  OrderItem({
    required this.imageUrl,
    required this.name,
    required this.quantity,
    required this.pricePerUnit,
  });

  int get totalPrice => quantity * pricePerUnit;
}

class OrderDetailDummy {
  static const String orderId = 'MG-2904X';
  static const String status = 'SEDANG DIKIRIM';
  static const String eta = '15 - 20 Menit';
  static const int progressStep = 2; // 1: Diproses, 2: Dikirim, 3: Selesai

  // Data Kurir
  static const String driverName = 'Budi Darmawan';
  static const double driverRating = 4.9;
  static const String driverRole = 'Mitra Pengantar';
  static const String driverImage = 'https://i.pravatar.cc/150?img=11'; // Placeholder avatar

  // Data Alamat
  static const String addressLabel = 'Rumah Utama (Andi)';
  static const String addressDetail = 'Jl. Melati No. 45, Perumahan Kebun Jeruk Mas, Blok C-12, Jakarta Barat, 11530';
  static const String addressNote = 'Catatan: Gerbang hitam, samping pohon mangga.';

  // Data Barang
  static final List<OrderItem> items = [
    OrderItem(
      imageUrl: 'galon', // Nanti diganti URL gambar asli
      name: 'Galon Air Mineral 19L',
      quantity: 2,
      pricePerUnit: 18000,
    ),
    OrderItem(
      imageUrl: 'gas',
      name: 'Gas LPG 3Kg (Isi Ulang)',
      quantity: 1,
      pricePerUnit: 22000,
    ),
  ];

  // Data Pembayaran
  static const int subtotal = 58000;
  static const int deliveryFee = 5000;
  static const int discount = 5000;
  static const String promoCode = 'HEMATHAUS';
  static const String paymentMethod = 'Saldo Abunemen';
  static const String orderTimestamp = 'Dipesan pada 24 Okt 2023, 14:20 WIB';

  static int get totalPayment => (subtotal + deliveryFee) - discount;
}