import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cart_service.dart';
import '../produk/produk_screen.dart';
import '../produk/cart_screen.dart';
import '../adopsi/adopsi_screen.dart';
import '../profil/about_screen.dart';
import '../home/profile_screen.dart';
import '../home/search_screen.dart';
import '../../utils/image_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const Color primary = Color(0xFFFF9A8A);
  static const Color soft = Color(0xFFFFEEE9);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearch = false;

  static const Color primary = Color(0xFFFF9A8A);
  static const Color soft = Color(0xFFFFEEE9);

  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'makanan':
      case 'food':
        return Icons.set_meal;
      case 'snack':
        return Icons.cookie;
      case 'mainan':
      case 'toys':
        return Icons.toys;
      case 'aksesoris':
      case 'accessories':
        return Icons.checkroom;
      case 'perawatan':
      case 'health':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  // ✅ GUNAKAN CartService + setState agar badge ke-update
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      CartService.addToCart(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} ditambahkan ke keranjang!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _openCart() async {
    // ✅ Tidak perlu kirim list lagi, CartScreen ambil dari CartService
    bool? cartCleared = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );

    if (mounted) {
      setState(() {
        // ✅ Jika checkout berhasil, CartService.clearCart() sudah dipanggil di CartScreen
        // setState() di sini cuma untuk me-refresh badge keranjang di header
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F5),

      // ================= BOTTOM NAVBAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
                color: primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(Icons.home_rounded, "Home", true, () {}),
            NavItem(Icons.shopping_bag_rounded, "Produk", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProdukScreen()));
            }),
            NavItem(Icons.pets_rounded, "Adopsi", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const AdopsiScreen()));
            }),
            NavItem(Icons.info_outline_rounded, "Tentang", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()));
            }),
          ],
        ),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.35),
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
                            Text("Welcome Back 👋",
                                style: GoogleFonts.pacifico(
                                    color: Colors.white, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text("You",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.pacifico(
                                    fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showSearch = !_showSearch),
                        child: const Icon(Icons.search,
                            color: Colors.white, size: 28),
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
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  constraints: const BoxConstraints(
                                      minWidth: 16, minHeight: 16),
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
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen())),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        // ✅ Tidak perlu kirim cartItems lagi
                                        SearchScreen(query: value.trim())));
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Cari makanan, snack, kucing...",
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          icon:
                              Icon(Icons.search, size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ================= SCROLL CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFB5A7), Color(0xFFFF9A8A)]),
                        boxShadow: [
                          BoxShadow(
                              color: primary.withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 12))
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                              top: -30,
                              right: -20,
                              child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      shape: BoxShape.circle))),
                          Positioned(
                              bottom: -40,
                              left: -40,
                              child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.10),
                                      shape: BoxShape.circle))),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 8,
                                    child: Align(
                                        alignment: const Alignment(0, 0.3),
                                        child: Transform.translate(
                                            offset: const Offset(0, 25),
                                            child: Transform.scale(
                                                scale: 1.95,
                                                child: Image.network(
                                                    'https://i.ibb.co.com/LzbzFd9n/cat-removebg-preview.png',
                                                    fit: BoxFit.contain))))),
                                const SizedBox(width: 28),
                                const Expanded(
                                    flex: 6,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Adopt Your\nNew Best\nFriend 🐾",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                  height: 1.2)),
                                          SizedBox(height: 12),
                                          Text(
                                              "Temukan sahabat berbulu terbaikmu hari ini.",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  height: 1.5))
                                        ])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),

                    // CATEGORIES
                    sectionTitle("Categories"),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 60,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categories')
                            .orderBy('createdAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const Center(
                                child:
                                    CircularProgressIndicator(color: primary));
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                            return const Center(
                                child: Text("Belum ada kategori",
                                    style: TextStyle(color: Colors.grey)));
                          var categories = snapshot.data!.docs;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              var cat = categories[index];
                              return category(
                                  _getCategoryIcon(cat['name']), cat['name']);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 38),

                    // PET ADOPTION
                    sectionTitle("Pet Adoption"),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 340,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('cats')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const Center(
                                child:
                                    CircularProgressIndicator(color: primary));
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                            return const Center(
                                child: Text("Belum ada kucing adopsi",
                                    style: TextStyle(color: Colors.grey)));
                          var cats = snapshot.data!.docs;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length,
                            itemBuilder: (context, index) {
                              var doc = cats[index];
                              var data = doc.data() as Map<String, dynamic>;
                              return PetCard(
                                data['name'] ?? '',
                                data['age'] ?? '',
                                data['gender'] ?? '',
                                data['imageUrl'] ?? '',
                                data['imageBase64'],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 38),

                    // PRODUCTS
                    sectionTitle("Popular Products"),
                    const SizedBox(height: 18),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('products')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(
                              child: CircularProgressIndicator(color: primary));
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                          return const Center(
                              child: Text("Belum ada produk",
                                  style: TextStyle(color: Colors.grey)));
                        var products = snapshot.data!.docs;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.50,
                          children: products.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            return ProductCard(
                              data['name'] ?? '',
                              data['weight'] ?? data['desc'] ?? '',
                              "Rp ${formatRupiah(data['price'] ?? 0)}",
                              data['imageUrl'] ?? '',
                              data['imageBase64'],
                              () => _addToCart({
                                'name': data['name'],
                                'price': data['price'],
                                'imageUrl': data['imageUrl'],
                                'imageBase64': data['imageBase64'],
                                'qty': 1,
                              }),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("See all",
            style: TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }

  static Widget category(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
          ]),
      child: Row(children: [
        Icon(icon, color: primary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))
      ]),
    );
  }
}

// ================= PET CARD =================
class PetCard extends StatelessWidget {
  final String name, age, gender, imageUrl;
  final String? base64Image;

  const PetCard(this.name, this.age, this.gender, this.imageUrl, this.base64Image, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                  height: 150,
                  color: const Color(0xFFFFEEE9),
                  child: ImageHelper.showImage(
                    {'imageUrl': imageUrl, 'imageBase64': base64Image},
                    width: double.infinity,
                    height: 150,
                    borderRadius: 24,
                    fit: BoxFit.cover,
                  ))),
          const SizedBox(height: 16),
          Text(name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(age, style: const TextStyle(color: Colors.grey)),
          Text(gender, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                  color: HomePage.primary,
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(
                  child: Text("Ready Adopt",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)))),
        ],
      ),
    );
  }
}

// ================= PRODUCT CARD =================
class ProductCard extends StatelessWidget {
  final String title, subtitle, price, imageUrl;
  final String? base64Image;
  final VoidCallback onAddToCart;

  const ProductCard(
      this.title, this.subtitle, this.price, this.imageUrl, this.base64Image, this.onAddToCart,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFFFEEE9),
                  child: ImageHelper.showImage(
                    {'imageUrl': imageUrl, 'imageBase64': base64Image},
                    height: 120,
                    width: double.infinity,
                    borderRadius: 24,
                    fit: BoxFit.cover,
                  ))),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(price,
              style: const TextStyle(
                  color: HomePage.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: onAddToCart,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: HomePage.primary,
                    borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.add_shopping_cart_rounded,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= NAV ITEM =================
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const NavItem(this.icon, this.label, this.active, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: active ? 32 : 28),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
        ],
      ),
    );
  }
}