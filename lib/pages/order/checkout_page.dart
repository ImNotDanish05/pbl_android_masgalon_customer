import 'package:flutter/material.dart';
import '../../widgets/order/checkout_item_card.dart';
import '../../data/dummy_data.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = [
      {
        'product': DummyData.galonList[0], // AQUA 19L
        'quantity': 2,
      },
      {
        'product': DummyData.gasList[1], // Gas Melon 3kg
        'quantity': 1,
      },
    ];
  }

  // Hitung total harga
  int get _totalPrice {
    return _cartItems.fold(0, (sum, item) {
      return sum + (item['product'].price * item['quantity'] as int);
    });
  }

  // Increment quantity
  void _incrementQuantity(int index) {
    setState(() {
      _cartItems[index]['quantity'] = (_cartItems[index]['quantity'] as int) + 1;
    });
  }

  // Decrement quantity
  void _decrementQuantity(int index) {
    setState(() {
      int currentQty = _cartItems[index]['quantity'] as int;
      if (currentQty > 1) {
        _cartItems[index]['quantity'] = currentQty - 1;
      } else {
        // Remove item jika quantity jadi 0
        _cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D63B3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Color(0xFF0D63B3), fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Pesanan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // List Item dari dummy data
                ..._cartItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  final item = entry.value;
                  final product = item['product'];
                  final quantity = item['quantity'] as int;
                  final itemTotal = product.price * quantity;
                  
                  return CheckoutItemCard(
                    title: product.name,
                    subtitle: '$quantity unit x Rp ${product.price}',
                    price: 'Rp $itemTotal',
                    quantity: quantity,
                    onIncrement: () => _incrementQuantity(index),
                    onDecrement: () => _decrementQuantity(index),
                  );
                }).toList(),
                const SizedBox(height: 20),
                // Total Tagihan Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Rp $_totalPrice',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D63B3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tombol Konfirmasi di Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D63B3),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Konfirmasi & Pesan',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}