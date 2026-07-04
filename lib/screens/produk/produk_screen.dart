import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cart_service.dart';
import '../home/home_screen.dart';
import '../home/profile_screen.dart';
import '../home/search_screen.dart';
import '../produk/cart_screen.dart';
import '../adopsi/adopsi_screen.dart';
import '../profil/about_screen.dart';
import '../../utils/image_helper.dart'; // ✅ Import Helper Base64

// ==================== COLOR CONSTANTS ====================
class AppColors {
  static const peach400 = Color(0xFFFF9A8A);
  static const peach500 = Color(0xFFFF7E6B);
  static const peach600 = Color(0xFFE6644F);
  static const peach700 = Color(0xFFBF4F3D);
  static const peach800 = Color(0xFF993A2E);
  static const peach50 = Color(0xFFFFF5F3);
  static const peach100 = Color(0xFFFFE8E3);
  static const peach200 = Color(0xFFFFD0C7);
  static const peach300 = Color(0xFFFFB5A7);
}

String formatRupiah(int price) {
  return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
}

// ==================== MAIN SCREEN ====================
class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  String _currentCategory = 'makanan';
  bool _showSearch = false;

  // ✅ GUNAKAN CartService + setState agar badge ke-update
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      CartService.addToCart(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} ditambahkan! 🛒'),
        backgroundColor: AppColors.peach700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openCart() async {
    // ✅ Tidak perlu kirim list lagi, CartScreen ambil dari CartService
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
    
    // ✅ Panggil setState setelah kembali dari CartScreen agar badge di header update
    if (mounted) {
      setState(() {});
    }
  }

  void _openDetail(DocumentSnapshot productDoc) {
    var data = productDoc.data() as Map<String, dynamic>? ?? {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(
        productDoc: productDoc,
        category: _currentCategory,
        onAdd: () {
          _addToCart({
            'name': data['name'],
            'price': data['price'],
            'imageUrl': data['imageUrl'] ?? '',
            'imageBase64': data['imageBase64'],
            'qty': 1,
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'makanan':
      case 'food':
        return Icons.restaurant;
      case 'snack':
        return Icons.cookie_outlined;
      case 'mainan':
      case 'toys':
        return Icons.sports_esports;
      case 'perawatan':
        return Icons.auto_fix_high;
      case 'aksesoris':
        return Icons.diamond;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.peach50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Produk $_currentCategory',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.peach800)),
                        TextButton(
                            onPressed: () {},
                            child: const Text('Lihat Semua',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.peach500))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.peach400,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.peach400.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                      'https://i.ibb.co.com/bMHGnL46/logopetshop.jpg',
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PetshopCat 🐾",
                        style: GoogleFonts.pacifico(
                            color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text("Produk Terbaik",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pacifico(
                            fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showSearch = !_showSearch),
                child: const Icon(Icons.search, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: _openCart,
                child: Stack(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 28),
                    // ✅ Pakai CartService.cartCount
                    if (CartService.cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text('${CartService.cartCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          if (_showSearch) ...[
            const SizedBox(height: 14),
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                // ✅ HAPUS cartItems: CartService.cartItems
                                SearchScreen(query: value.trim())));
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari produk kucing...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  icon: Icon(Icons.search, size: 24, color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================= CATEGORY TABS =================
  Widget _buildCategoryTabs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var categories = snapshot.data!.docs;
        return Container(
          color: AppColors.peach50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: categories.map((doc) {
                String catName = doc['name'];
                bool isActive = _currentCategory == catName;
                return GestureDetector(
                  onTap: () => setState(() => _currentCategory = catName),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.peach400 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isActive
                              ? AppColors.peach400
                              : AppColors.peach200),
                    ),
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(catName),
                            size: 14,
                            color:
                                isActive ? Colors.white : AppColors.peach500),
                        const SizedBox(width: 6),
                        Text(catName[0].toUpperCase() + catName.substring(1),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.peach500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ================= PROMO BANNER =================
  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.peach400, AppColors.peach500],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.peach300.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promo Spesial 🎉',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                const Text('Diskon 30%',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Untuk semua makanan kucing minggu ini!',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Belanja Sekarang',
                      style: TextStyle(
                          color: AppColors.peach600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT GRID =================
  Widget _buildProductGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: _currentCategory)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.peach400));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: const [
              SizedBox(height: 60),
              Icon(Icons.inventory_2_outlined,
                  size: 48, color: AppColors.peach300),
              SizedBox(height: 12),
              Text('Belum ada produk di kategori ini',
                  style: TextStyle(
                      color: AppColors.peach400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          );
        }

        var products = snapshot.data!.docs;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var doc = products[index];
            var data = doc.data() as Map<String, dynamic>;
            return _ProductCard(
              productDoc: doc,
              onTap: () => _openDetail(doc),
              onAdd: () => _addToCart({
                'name': data['name'],
                'price': data['price'],
                'imageUrl': data['imageUrl'] ?? '',
                'imageBase64': data['imageBase64'],
                'qty': 1,
              }),
            );
          },
        );
      },
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.peach400,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: AppColors.peach400.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, "Home", false, () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          }),
          _buildNavItem(Icons.shopping_bag_rounded, "Produk", true, () {}),
          _buildNavItem(Icons.pets_rounded, "Adopsi", false, () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AdopsiScreen()));
          }),
          _buildNavItem(Icons.info_outline_rounded, "Tentang", false, () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isActive ? 32 : 28),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================
class _ProductCard extends StatefulWidget {
  final DocumentSnapshot productDoc;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductCard(
      {required this.productDoc, required this.onTap, required this.onAdd});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    var p = widget.productDoc;
    var data = p.data() as Map<String, dynamic>? ?? {};

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.peach100.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
                color: AppColors.peach200.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.peach50,
                      child: ImageHelper.showImage(
                        {
                          'imageUrl': data['imageUrl'] ?? '',
                          'imageBase64': data['imageBase64']
                        },
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: 0,
                      ),
                    ),
                  ),
                  if ((data['price'] ?? 0) > 50000)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.peach500,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('Premium',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _isWishlisted = !_isWishlisted),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle),
                        child: Icon(
                            _isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: _isWishlisted
                                ? AppColors.peach500
                                : AppColors.peach300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.peach800),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(data['weight'] ?? data['desc'] ?? '',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.peach400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rp${formatRupiah(data['price'] ?? 0)}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.peach600)),
                      GestureDetector(
                        onTap: widget.onAdd,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppColors.peach400,
                              AppColors.peach500
                            ]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.peach300.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PRODUCT DETAIL SHEET ====================
class _ProductDetailSheet extends StatelessWidget {
  final DocumentSnapshot productDoc;
  final String category;
  final VoidCallback onAdd;

  const _ProductDetailSheet(
      {required this.productDoc, required this.category, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    var data = productDoc.data() as Map<String, dynamic>? ?? {};

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.peach200,
                  borderRadius: BorderRadius.circular(4))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.peach50,
                child: ImageHelper.showImage(
                  {
                    'imageUrl': data['imageUrl'] ?? '',
                    'imageBase64': data['imageBase64']
                  },
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(data['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.peach800))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                              color: AppColors.peach50, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: AppColors.peach400, size: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data['desc'] ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.peach400, height: 1.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.peach100,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(data['weight'] ?? '-',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.peach600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.peach50,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(category,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.peach500)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp${formatRupiah(data['price'] ?? 0)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.peach600)),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.peach400, AppColors.peach500]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.peach300.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Tambah',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}