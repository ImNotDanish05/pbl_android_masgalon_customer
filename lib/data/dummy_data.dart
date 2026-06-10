import '../models/order_detail_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/order_history_model.dart';
import '../models/profile_model.dart';
class DummyData {
  // Katalog Galon
  static const List<ProductModel> galonList = [
    ProductModel(
      id: 'g1',
      brand: 'AQUA 19L',
      name: 'Galon Isi Ulang',
      price: 18500,
      imageAsset: 'assets/images/aqua_galon.png',
    ),
    ProductModel(
      id: 'g2',
      brand: 'VIT 19L',
      name: 'Galon Isi Ulang',
      price: 15000,
      imageAsset: 'assets/images/vit_galon.png',
    ),
  ];

  // Katalog Gas
  static const List<ProductModel> gasList = [
    ProductModel(
      id: 'gas1',
      brand: 'BRIGHT GAS',
      name: 'Bright Gas 12kg',
      price: 215000,
      imageAsset: 'assets/images/bright_gas.png',
      badge: 'TERLARIS',
      subtitle: 'Refill / Isi Ulang Saja',
    ),
    ProductModel(
      id: 'gas2',
      brand: 'LPG 3KG',
      name: 'Gas Melon 3kg',
      price: 22000,
      imageAsset: 'assets/images/gas_melon.png',
      subtitle: 'Stok Terbatas',
    ),
  ];

  // Dummy saldo & poin
  static const int saldoAbunemen = 450000;
  static const int saldoAnda = 124500;
  static const String saldo = '2480000';
  static const int pointRewards = 2480;
  static const int pointTarget = 3000;
  static const String promoTitle = 'Hemat 20%\nUntuk\nLangganan 5\nGalon';
  static const String promoLabel = 'PROMO BULAN INI';
  static const int cartItemCount = 2;

  static const List<OrderModel> orderHistory = [
    OrderModel(
      id: 'o1',
      title: '2 Galon Air Mineral, 1 Gas LPG',
      details: '12 Okt 2023 • 14:20',
      price: 128000,
      status: OrderStatus.mencariKurir,
      repeatable: false,
    ),
    OrderModel(
      id: 'o2',
      title: '3 Gas LPG 3kg [Refill]',
      details: '12 Okt 2023 • 15:30',
      price: 66000,
      status: OrderStatus.mencariKurir,
      repeatable: false,
    ),
    OrderModel(
      id: 'o3',
      title: '3 Galon Aqua 19L',
      details: '12 Okt 2023 • 14:20',
      price: 54000,
      status: OrderStatus.selesai,
      repeatable: true,
    ),
    OrderModel(
      id: 'o4',
      title: '1 Galon Le Minerale',
      details: '08 Okt 2023 • 09:15',
      price: 18000,
      status: OrderStatus.tolak,
      note: 'Dibatalkan oleh sistem',
    ),
    OrderModel(
      id: 'o5',
      title: '2 Galon Vit',
      details: '01 Okt 2023 • 18:45',
      price: 30000,
      status: OrderStatus.selesai,
      repeatable: true,
    ),
  ];

  static final List<OrderDetailModel> orderDetails = [
    OrderDetailModel(
      id: 'MG-9821',
      label: 'Pesanan Berjalan',
      date: '12 Okt 2023 • 14:30',
      status: OrderStatus.mencariKurir,
      totalPrice: 128000,
      progress: 65,
      note: 'Driver menuju lokasi',
      address: 'Jl. Merdeka No. 22, Jakarta',
      items: [
        OrderDetailItem(product: DummyData.galonList[0], quantity: 3),
        OrderDetailItem(product: DummyData.gasList[0], quantity: 1),
      ],
    ),
  ];

  // static const List<VoucherModel> voucherList = [
  //   VoucherModel(
  //     title: 'Diskon galon beli 1 gratis 1',
  //     subtitle: 'Promo terbaik untukmu',
  //   ),
  //   VoucherModel(
  //     title: 'Diskon Gas beli 1 gratis 1',
  //     subtitle: 'Promo terbaik untukmu',
  //   ),
  // ];

  // Profil
  static const ProfileModel profile = ProfileModel(
    name: 'Mas Basith',
    email: 'basithyafi@gmail.com',
    avatarAsset: 'assets/images/avatar_dummy.png',
    saldo: 124500,
  );

  static final List<HistoryOrderModel> orders = [
    // --- PESANAN AKTIF ---
    HistoryOrderModel(
      id: 'MG-9821',
      date: '12 Okt 2023 • 14:30',
      status: 'DIKIRIM',
      itemName: '2 Galon Air Mineral, 1 Gas LPG',
      totalPrice: 128000,
      imageType: 'galon',
      isActive: true,
      progress: 0.65,
      progressText: 'DRIVER MENUJU LOKASI',
    ),
    HistoryOrderModel(
      id: 'MG-9815',
      date: '12 Okt 2023 • 10:15',
      status: 'DIPROSES',
      itemName: '3 Gas LPG 3kg (Refill)',
      totalPrice: 66000,
      imageType: 'gas',
      isActive: true,
      // DIPROSES belum ada progress bar jalan, jadi diset null
    ),

    // --- PESANAN SELESAI ---
    HistoryOrderModel(
      id: 'MG-9788',
      date: '10 Okt 2023 • 09:00',
      status: 'SELESAI',
      itemName: '5 Galon Air Mineral (Refill)',
      totalPrice: 90000,
      imageType: 'galon',
      isActive: false,
    ),
  ];

  // Helper untuk memfilter data
  static List<HistoryOrderModel> get activeOrders =>
      orders.where((order) => order.isActive).toList();

  static List<HistoryOrderModel> get completedOrders =>
      orders.where((order) => !order.isActive).toList();

  static const String orderId = 'MG-8821';
  static const String paymentMethod = 'Saldo Abunemen';
  static const String paymentDate = '24 May 2024, 14:05 WIB';
  static const int totalBayar = 54000;

  // Data untuk kartu pengantaran (opsional jika pakai gambar banner seperti di desain)
  static const String deliveryType = 'Pengantaran Cepat';
  static const String deliveryEstimate = 'Estimasi tiba dalam 30-45 menit';

  static const String title = 'Unggah Bukti Transfer';
  static const String subtitle =
      'Pastikan foto atau screenshot bukti transfer terlihat jelas untuk mempercepat proses verifikasi.';

  static const String infoTitle = 'Proses Verifikasi';
  static const String infoDesc =
      'Saldo Anda akan otomatis bertambah setelah admin memverifikasi bukti transfer ini. Mohon tunggu sebentar.';

  static const String uploadTitle = 'Bukti Pembayaran (Receipt)';
  static const String uploadHint = 'Pilih foto';
  static const String uploadSubHint = 'Maksimal ukuran file 5MB (JPG, PNG)';

  static const List<String> paymentInstructions = [
    'Buka aplikasi e-Wallet (OVO, GoPay, Dana) atau M-Banking Anda.',
    'Pilih menu Scan QR atau Pay.',
    'Arahkan kamera ke QR Code di atas.',
    'Pastikan nama merchant adalah Mas Galon.',
    'Konfirmasi pembayaran sesuai nominal.',
  ];

  // Alamat
  // static const List<AddressModel> addressList = [
  //   AddressModel(
  //     label: 'Rumah',
  //     name: 'Rumah (Utama)',
  //     detail:
  //         'Jl. Menteng Pulo No. 42, Setiabudi, Jakarta Selatan, DKI Jakarta 12970',
  //     isUtama: true,
  //   ),
  //   AddressModel(
  //     label: 'Kantor',
  //     name: 'Kantor',
  //     detail:
  //         'Menara Imperium, Lt. 15, Kuningan, Jakarta Selatan, DKI Jakarta 12980',
  //   ),
  // ];

  static const String successTitle = 'Top Up Berhasil';
  static const String successSubtitle =
      'Terima kasih! Saldo Anda sedang diproses dan akan segera bertambah setelah verifikasi.';
}
