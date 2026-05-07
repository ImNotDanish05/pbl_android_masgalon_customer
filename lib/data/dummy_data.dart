import '../models/product_model.dart';
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
  static const int pointRewards = 2480;
  static const int pointTarget = 3000;
  static const String promoTitle = 'Hemat 20%\nUntuk\nLangganan 5\nGalon';
  static const String promoLabel = 'PROMO BULAN INI';
  static const int cartItemCount = 2;

  // Profil
  static const ProfileModel profile = ProfileModel(
    name: 'Mas Basith',
    email: 'basithyafi@gmail.com',
    avatarAsset: 'assets/images/avatar_dummy.png',
    saldo: 124500,
  );

  // Voucher
  static const List<VoucherModel> voucherList = [
    VoucherModel(
      title: 'Diskon galon beli 1 gratis 1',
      subtitle: 'Promo terbaik untukmu',
    ),
    VoucherModel(
      title: 'Diskon Gas beli 1 gratis 1',
      subtitle: 'Promo terbaik untukmu',
    ),
  ];

  // Alamat
  static const List<AddressModel> addressList = [
    AddressModel(
      label: 'Rumah',
      name: 'Rumah (Utama)',
      detail: 'Jl. Menteng Pulo No. 42, Setiabudi, Jakarta Selatan, DKI Jakarta 12970',
      isUtama: true,
    ),
    AddressModel(
      label: 'Kantor',
      name: 'Kantor',
      detail: 'Menara Imperium, Lt. 15, Kuningan, Jakarta Selatan, DKI Jakarta 12980',
    ),
  ];
}