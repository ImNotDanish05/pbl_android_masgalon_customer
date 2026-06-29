class TopupRequest {
  final String? id;
  final String customerId;
  final int nominal;
  final String? buktiTransferUrl;
  final bool isVerified;
  final DateTime? createdAt;

  TopupRequest({
    this.id,
    required this.customerId,
    required this.nominal,
    this.buktiTransferUrl,
    this.isVerified = false,
    this.createdAt,
  });

  // Mengubah JSON dari Supabase menjadi Object Dart (untuk read data)
  factory TopupRequest.fromJson(Map<String, dynamic> json) {
    return TopupRequest(
      id: json['id'],
      customerId: json['customer_id'],
      nominal: json['nominal'],
      buktiTransferUrl: json['bukti_transfer_url'],
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Mengubah Object Dart menjadi JSON (untuk insert ke Supabase)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'customer_id': customerId,
      'nominal': nominal,
    };
    if (buktiTransferUrl != null) {
      data['bukti_transfer_url'] = buktiTransferUrl;
    }
    return data;
  }
}