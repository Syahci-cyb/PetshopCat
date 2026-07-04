import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart';
import '../home/profile_screen.dart';
import '../home/search_screen.dart';
import '../produk/produk_screen.dart';
import '../produk/cart_screen.dart';
import '../profil/about_screen.dart';
import '../../utils/image_helper.dart'; 
import '../../services/cart_service.dart';

class AdopsiScreen extends StatefulWidget {
  const AdopsiScreen({super.key});

  @override
  State<AdopsiScreen> createState() => _AdopsiScreenState();
}

class _AdopsiScreenState extends State<AdopsiScreen> {
  bool _showSearch = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  static const Color primary = Color(0xFFFF9A8A);
  static const Color primaryDark = Color(0xFFFF7A66);
  static const Color softBg = Color(0xFFFFF5F4);
  static const Color textDark = Color(0xFF3D2C2C);
  static const Color textMid = Color(0xFF7A5A5A);

  Future<void> _launchWhatsApp(String message) async {
    final url = Uri.parse(
        "https://wa.me/6281234567890?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  // ✅ Fungsi Buka Keranjang
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,

      // ================= BOTTOM NAVBAR (MENEMPEL BAWAH) =================
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
            _buildNavItem(Icons.home_rounded, "Home", false, () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            }),
            _buildNavItem(Icons.shopping_bag_rounded, "Produk", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProdukScreen()));
            }),
            _buildNavItem(Icons.pets_rounded, "Adopsi", true, () {}),
            _buildNavItem(Icons.info_outline_rounded, "Tentang", false, () {
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
            // ================= HEADER (MENEMPEL ATAS) =================
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
                            Text("PetshopCat 🐾",
                                style: GoogleFonts.pacifico(
                                    color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text("Adopsi Kucing",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.pacifico(
                                    fontSize: 13, color: Colors.white70)),
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
                            // ✅ Gunakan CartService.cartCount
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
                                    builder: (_) => SearchScreen(
                                        query: value.trim()))); // ✅ Hapus passing cartItems
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Cari kucing...",
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ================= HERO SECTION =================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [primary, Color(0xFFFFB8AD), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: primaryDark.withOpacity(0.2),
                                      blurRadius: 8)
                                ]),
                            child: const Text("🐾 HALAMAN ADOPSI RESMI",
                                style: TextStyle(
                                    color: primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                          const SizedBox(height: 16),
                          const Text("🐱", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text("Adopsi Kucing\nBerbulu Lucu!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pacifico(
                                  color: Colors.white,
                                  fontSize: 28,
                                  height: 1.2,
                                  shadows: const [
                                    Shadow(color: Colors.black26, blurRadius: 6)
                                  ])),
                          const SizedBox(height: 10),
                          Text(
                              "Temukan sahabat baru yang setia\nuntuk keluarga Anda di PetshopCat 🏡",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ================= KUCING TERSEDIA TITLE =================
                    Text("Kucing Tersedia 🐾",
                        style: GoogleFonts.pacifico(
                            color: primaryDark, fontSize: 20)),
                    Text("Klik tombol WhatsApp untuk adopsi langsung!",
                        style: TextStyle(
                            color: textMid,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),

                    // ================= CARDS LIST (DARI FIREBASE) ✅ =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('cats')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child:
                                    CircularProgressIndicator(color: primary));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Column(
                              children: [
                                SizedBox(height: 40),
                                Icon(Icons.pets, size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Belum ada kucing adopsi saat ini',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                              ],
                            );
                          }

                          var cats = snapshot.data!.docs;
                          return Column(
                            children: cats.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildCatCard(doc),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ================= FORM KHUSUS =================
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [primaryDark, primary]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: primaryDark.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        children: [
                          Text("Butuh Info\nLebih Lanjut? 🐱",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pacifico(
                                  color: Colors.white,
                                  fontSize: 20,
                                  height: 1.3)),
                          const SizedBox(height: 8),
                          Text(
                              "Isi data Anda dan tim kami akan segera\nmenghubungi untuk membantu proses adopsi!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5)),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nama Lengkap",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _nameController,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama Anda...',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nomor WhatsApp",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: '08xxxxxxxxxx',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                String msg =
                                    'Halo PetshopCat, saya ingin bertanya tentang adopsi kucing 🐱';
                                if (_nameController.text.trim().isNotEmpty)
                                  msg +=
                                      '\n\nNama saya: ${_nameController.text.trim()}';
                                if (_phoneController.text.trim().isNotEmpty)
                                  msg +=
                                      '\nNo. WA: ${_phoneController.text.trim()}';
                                _launchWhatsApp(msg);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryDark,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 4,
                              ),
                              child: const Text("💬 Hubungi Kami via WhatsApp",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPER NAV ITEM =================
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

  // ================= CAT CARD WIDGET (DIPERBAIKI IMAGE HELPER) ✅ =================
  Widget _buildCatCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>? ?? {};

    String name = data['name'] ?? 'Kucing';
    String age = data['age'] ?? '';
    String gender = data['gender'] ?? '';
    String desc = data['desc'] ?? '';
    String status = data['status'] ?? 'Ready Adopt';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
        ],
      ),
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: const Color(0xFFFFE8E4),
                  child: ImageHelper.showImage(
                    data,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color:
                          status == 'Ready Adopt' ? primaryDark : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: primaryDark.withOpacity(0.35), blurRadius: 8)
                      ]),
                  child: Text(status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),

          // Body Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        GoogleFonts.pacifico(color: primaryDark, fontSize: 18)),
                const SizedBox(height: 4),
                Text('$gender · $age',
                    style: const TextStyle(
                        color: textMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(desc,
                    style: TextStyle(
                        color: textMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
                const SizedBox(height: 14),

                // WA Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchWhatsApp(
                        'Halo PetshopCat, saya ingin mengadopsi $name 🐱'),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: const Text("Adopsi via WhatsApp",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF25D366).withOpacity(0.35),
                    ),
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