// lib/core/utils/currency_format.dart

extension RupiahFormatter on int {
  String get toRupiah {
    final str = this.toString(); // 'this' mewakili angka int itu sendiri
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }
}