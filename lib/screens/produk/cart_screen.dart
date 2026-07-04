import 'package:flutter/material.dart';
import '/theme/app_theme.dart';
import '../../utils/image_helper.dart'; 
import '../../services/cart_service.dart';
import 'checkout_screen.dart'; // ✅ Import Checkout Screen

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // ✅ Helper Format Rupiah
  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // ✅ Gunakan helper dari CartService
  int get _totalPrice => CartService.totalPrice;

  // ✅ Fungsi Tambah Qty memakai CartService
  void _incrementQty(int index) {
    setState(() {
      CartService.incrementQty(index);
    });
  }

  // ✅ Fungsi Kurangi Qty memakai CartService
  void _decrementQty(int index) {
    setState(() {
      CartService.decrementQty(index);
    });
  }

  // ✅ Navigasi ke Detail Checkout
  Future<void> _goToCheckout() async {
    if (CartService.cartItems.isEmpty) return;

    // Pindah ke halaman checkout, tunggu hasilnya
    bool? success = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );

    // Jika checkout sukses (mengembalikan true), tutup CartScreen dan kembali ke Home
    if (success == true && mounted) {
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Keranjang Saya',
            style: TextStyle(
                color: AppTheme.peachDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.peachDark),
          onPressed: () => Navigator.pop(context, false), 
        ),
      ),
      body: CartService.cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Keranjang kosong',
                      style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: CartService.cartItems.length,
                    itemBuilder: (context, index) {
                      var item = CartService.cartItems[index];
                      int itemTotal = (item['price'] as int) * (item['qty'] as int);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0E6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageHelper.showImage(
                                {
                                  'imageUrl': item['imageUrl'] ?? '',
                                  'imageBase64': item['imageBase64']
                                },
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.peachDark)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _decrementQty(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.peachMain.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.remove, size: 16, color: AppTheme.peachDark),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text('${item['qty']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ),
                                      GestureDetector(
                                        onTap: () => _incrementQty(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.peachMain,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Rp ${formatRupiah(itemTotal)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.peachMain)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Total & Tombol Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Harga:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp ${formatRupiah(_totalPrice)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.peachMain)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // ✅ Diganti: Sekarang mengarah ke halaman checkout
                          onPressed: _goToCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.peachMain,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Checkout Sekarang',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}