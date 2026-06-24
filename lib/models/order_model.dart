enum OrderStatus { mencariKurir, menungguKurir, diantar, selesai, tolak }

class OrderModel {
  final String id;
  final String title;
  final String details;
  final int price;
  final OrderStatus status;
  final String? note;
  final bool repeatable;
  final String? kurirName;
  final String? kurirAvatar;

  const OrderModel({
    required this.id,
    required this.title,
    required this.details,
    required this.price,
    required this.status,
    this.note,
    this.repeatable = false,
    this.kurirName,
    this.kurirAvatar,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.mencariKurir:
        return 'Mencari Kurir';
      case OrderStatus.menungguKurir:
        return 'Menunggu Kurir';
      case OrderStatus.diantar:
        return 'Diantar';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.tolak:
        return 'Tolak';
    }
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    // 1. Ambil daftar barang yang dipesan dari database
    final List itemsData = map['order_items'] ?? [];

    String title = 'Pesanan';
    int totalItems = 0;

    // 2. Merakit judul (title) dan jumlah barang (details)
    if (itemsData.isNotEmpty) {
      final firstItem = itemsData.first;
      final product = firstItem['products'] ?? {};

      title = product['nama'] ?? 'Pesanan';

      // Menghitung total quantity
      for (var item in itemsData) {
        totalItems += (item['quantity'] as num).toInt();
      }
    }

    // 3. Menerjemahkan status string dari DB ke bentuk Enum
    OrderStatus parsedStatus;
    final String rawStatus = map['status']?.toString() ?? '';

    switch (rawStatus) {
      case 'Mencari_Kurir':
        parsedStatus = OrderStatus.mencariKurir;
        break;
      case 'Menunggu_Kurir':
        parsedStatus = OrderStatus.menungguKurir;
        break;
      case 'Diantar':
        parsedStatus = OrderStatus.diantar;
        break;
      case 'Selesai':
        parsedStatus = OrderStatus.selesai;
        break;
      case 'Tolak':
        parsedStatus = OrderStatus.tolak;
        break;
      default:
        parsedStatus = OrderStatus.mencariKurir; // Default jaga-jaga
    }
    final courierData = map['couriers'] ?? {};
    String? namaKurir;
    String? avatarKurir;

    if (courierData != null) {
      final userData = courierData['users'] ?? {};
      namaKurir = userData['username'] ?? courierData['nama_asli'];
      avatarKurir = userData['avatar_url'] ?? '';
    }

    return OrderModel(
      id: map['id'].toString(),
      title: title, // Misal: "Galon Le Minerale"
      details: '$totalItems Items • Pembayaran: ${map['metode_pembayaran']}',
      price: (map['total_harga'] as num).toInt(),
      status: parsedStatus,
      note: map['created_at'] != null
          ? _formatDate(DateTime.parse(map['created_at']))
          : null,
      repeatable:
          parsedStatus == OrderStatus.selesai ||
          parsedStatus == OrderStatus.tolak,
      kurirName: namaKurir,
      kurirAvatar: avatarKurir,
    );
  }

  // Fungsi helper untuk merapikan tampilan tanggal
  static String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}