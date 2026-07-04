import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/theme/app_theme.dart';
import '../../services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String _userName = '';
  String _userAddress = '';
  String? _selectedPayment; // Menyimpan metode pembayaran yang dipilih

  // ✅ Data Metode Pembayaran (Bank & E-Wallet)
  final List<Map<String, String>> _paymentMethods = [
    {'type': 'Bank Transfer', 'name': 'BCA', 'number': '1234567890 a.n PetShopCat'},
    {'type': 'Bank Transfer', 'name': 'BNI', 'number': '0987654321 a.n PetShopCat'},
    {'type': 'Bank Transfer', 'name': 'Mandiri', 'number': '1122334455 a.n PetShopCat'},
    {'type': 'E-Wallet', 'name': 'GoPay', 'number': '081234567890 a.n PetShopCat'},
    {'type': 'E-Wallet', 'name': 'OVO', 'number': '089876543210 a.n PetShopCat'},
    {'type': 'E-Wallet', 'name': 'Dana', 'number': '081122334455 a.n PetShopCat'},
  ];

  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Ambil data user dari Firestore
  Future<void> _fetchUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _userName = userDoc['name'] ?? '';
          _userAddress = userDoc['address'] ?? 'Belum ada alamat';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Proses Checkout & Simpan ke Firestore
  Future<void> _processCheckout() async {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Mapping item, JANGAN simpan imageBase64 agar tidak melebihi batas 1MB Firestore
      List<Map<String, dynamic>> orderItems = CartService.cartItems
          .map((item) => {
                'name': item['name'],
                'price': item['price'],
                'qty': item['qty'],
                'imageUrl': item['imageUrl'] ?? '',
              })
          .toList();

      // Simpan ke collection 'orders'
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': uid,
        'userName': _userName,
        'address': _userAddress,
        'items': orderItems,
        'totalPrice': CartService.totalPrice,
        'paymentMethod': _selectedPayment, // ✅ Simpan metode pembayaran
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Kosongkan keranjang setelah berhasil
      CartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Checkout berhasil! Pesanan sedang diproses.'),
              backgroundColor: Colors.green),
        );
        // Kembalikan true ke CartScreen agar CartScreen ikut pop ke Home
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal checkout: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detail Checkout', style: TextStyle(color: AppTheme.peachDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.peachDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.peachMain))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= ALAMAT PENERIMA =================
                        _buildSectionTitle('Alamat Penerima', Icons.location_on_outlined),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                          child: Row(
                            children: [
                              const Icon(Icons.home_outlined, color: AppTheme.peachMain),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(_userAddress, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ================= RINGKASAN PESANAN =================
                        _buildSectionTitle('Ringkasan Pesanan', Icons.shopping_bag_outlined),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                          child: Column(
                            children: CartService.cartItems.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text('${item['name']} x${item['qty']}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 8),
                                    Text('Rp ${formatRupiah((item['price'] as int) * (item['qty'] as int))}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ================= METODE PEMBAYARAN =================
                        _buildSectionTitle('Metode Pembayaran', Icons.account_balance_wallet_outlined),
                        const SizedBox(height: 8),
                        _buildPaymentGroup('Transfer Bank', _paymentMethods.where((m) => m['type'] == 'Bank Transfer').toList()),
                        const SizedBox(height: 12),
                        _buildPaymentGroup('E-Wallet', _paymentMethods.where((m) => m['type'] == 'E-Wallet').toList()),
                      ],
                    ),
                  ),
                ),

                // ================= TOMBOL BAYAR =================
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('Rp ${formatRupiah(CartService.totalPrice)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.peachMain)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _processCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.peachMain,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Helper Widget Judul Section
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.peachDark, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.peachDark)),
      ],
    );
  }

  // Helper Widget Grup Pembayaran (Bank / E-Wallet)
  Widget _buildPaymentGroup(String groupTitle, List<Map<String, String>> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(groupTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
          child: Column(
            children: methods.map((method) {
              String value = '${method['type']} - ${method['name']}';
              return RadioListTile<String>(
                title: Text(method['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(method['number']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                value: value,
                groupValue: _selectedPayment,
                activeColor: AppTheme.peachMain,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (String? val) {
                  setState(() => _selectedPayment = val);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}