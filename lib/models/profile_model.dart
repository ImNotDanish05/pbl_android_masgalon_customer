class ProfileModel {
  final String name;
  final String email;
  final String avatarAsset;
  final int saldo;

  const ProfileModel({
    required this.name,
    required this.email,
    required this.avatarAsset,
    required this.saldo,
  });
}

class VoucherModel {
  final String title;
  final String subtitle;

  const VoucherModel({
    required this.title,
    required this.subtitle,
  });
}

class AddressModel {
  final String label;
  final String name;
  final String detail;
  final bool isUtama;

  const AddressModel({
    required this.label,
    required this.name,
    required this.detail,
    this.isUtama = false,
  });
}