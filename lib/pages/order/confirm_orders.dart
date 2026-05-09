import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';
import '../../data/dummy_confirm_order.dart';
import '../../widgets/confirm_address_section.dart';
import '../../widgets/confirm_items_section.dart';
import '../../widgets/confirm_voucher_section.dart';
import '../../widgets/confirm_delivery_section.dart';
import '../../widgets/confirm_payment_section.dart';
import '../../widgets/confirm_summary_section.dart';
import '../../widgets/general_app_bar.dart';
import '../../widgets/bottom_action.dart';

class ConfirmOrderPage extends StatefulWidget {
  const ConfirmOrderPage({super.key});

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  int _currentNavIndex = 1;
  String _selectedDelivery = 'Kilet';
  String _selectedPayment = 'Saldo';

  String _formatRupiah(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final order = DummyData.orderDetails.first;
    final int deliveryFee = _selectedDelivery == 'Kilet' ? 5000 : 0;
    final int subtotal = order.totalPrice;
    final int total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: GeneralAppBar(
        title: 'Konfirmasi Pesanan',
        showBackButton: true,
        onBackPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConfirmAddressSection(
              address: ConfirmOrderDummy.address,
              onEdit: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Ubah alamat')));
              },
            ),
            const SizedBox(height: 16),
            ConfirmItemsSection(
              items: order.items,
              formatRupiah: _formatRupiah,
            ),

            const SizedBox(height: 16),
            ConfirmVoucherSection(
              onVoucher: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Lihat voucher')));
              },
            ),
            const SizedBox(height: 16),
            ConfirmDeliverySection(
              selectedDelivery: _selectedDelivery,
              deliveryOptions: ConfirmOrderDummy.deliveryOptions,
              onSelected: (value) {
                setState(() => _selectedDelivery = value);
              },
              formatRupiah: _formatRupiah,
            ),
            const SizedBox(height: 16),
            ConfirmPaymentSection(
              selectedPayment: _selectedPayment,
              paymentOptions: ConfirmOrderDummy.paymentOptions,
              onSelected: (value) {
                setState(() => _selectedPayment = value);
              },
            ),
            const SizedBox(height: 16),
            ConfirmSummarySection(
              subtotal: subtotal,
              deliveryFee: deliveryFee,
              total: total,
              formatRupiah: _formatRupiah,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        label: 'Bayar Sekarang',
        onPressed: () {},
      ),
    );
  }
}
