class ConfirmOrderDummy {
  static const String address =
      'Jl. Masuki No. 45, Kemandin\nBanten, Bkt. C-3, Jakarta\nBarat, 12345';

  static const Map<String, dynamic> deliveryOptions = {
    'Kilet': {
      'label': 'Kilet (< 45 Menit)',
      'subtitle': 'Pengiriman kilat dengan kurir profesional',
      'price': 5000,
    },
    'Regular': {
      'label': 'Regular (2-3 Jam)',
      'subtitle': 'Pengiriman standar dari kami',
      'price': 0,
    },
  };

  static const Map<String, dynamic> paymentOptions = {
    'Saldo': {
      'title': 'Saldo Akunemen',
      'subtitle': 'Saldo akunemen yang sudah terkumpul',
    },
    'Kartu': {
      'title': 'COD',
      'subtitle': 'Bayar ditempat',
    },
  };
}
