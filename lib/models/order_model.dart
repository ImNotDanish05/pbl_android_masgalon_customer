enum OrderStatus { completed, cancelled, pending }

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
      case OrderStatus.completed:
        return 'SELESAI';
      case OrderStatus.cancelled:
        return 'DIBATALKAN';
      case OrderStatus.pending:
        return 'DIPROSES';
    }
  }
}
