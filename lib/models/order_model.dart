enum OrderStatus { mencariKurir, menungguKurir, diantar, selesai, tolak }

class OrderModel {
  final String id;
  final String title;
  final String details;
  final int price;
  final OrderStatus status;
  final String? note;
  final bool repeatable;

  const OrderModel({
    required this.id,
    required this.title,
    required this.details,
    required this.price,
    required this.status,
    this.note,
    this.repeatable = false,
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
}
