class HistoryOrderModel {
  final String id;
  final String date;
  final String status;
  final String itemName;
  final int totalPrice;
  final String imageType; // 'galon' atau 'gas'
  final bool isActive;
  final double? progress; // 0.0 sampai 1.0
  final String? progressText;

  HistoryOrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.itemName,
    required this.totalPrice,
    required this.imageType,
    required this.isActive,
    this.progress,
    this.progressText,
  });
}