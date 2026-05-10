import 'order_model.dart';
import 'product_model.dart';

class OrderDetailItem {
  final ProductModel product;
  final int quantity;

  const OrderDetailItem({required this.product, required this.quantity});

  int get subTotal => product.price * quantity;
}

class OrderDetailModel {
  final String id;
  final String label;
  final String date;
  final OrderStatus status;
  final int totalPrice;
  final int progress;
  final String note;
  final List<OrderDetailItem> items;
  final String address;

  const OrderDetailModel({
    required this.id,
    required this.label,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.progress,
    required this.note,
    required this.items,
    required this.address,
  });

  String get statusText {
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
