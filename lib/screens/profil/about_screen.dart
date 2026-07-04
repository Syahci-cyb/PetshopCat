import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../home/profile_screen.dart';
import '../home/search_screen.dart';
import '../produk/produk_screen.dart';
import '../produk/cart_screen.dart';
import '../adopsi/adopsi_screen.dart';
import '../../services/cart_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _showSearch = false;

  static const Color primary = Color(0xFFFF9A8A);
  static const Color primaryDark = Color(0xFFFF7A66);

  // ✅ Data Developer dengan gambar online (IBB)
  final List<Map<String, dynamic>> developers = [
    {
      "name": "Miftah",
      "role": "Halaman Adopsi",
      "image": "https://i.ibb.co.com/W4Wh1fHM/miftah.jpg"
    },
    {
      "name": "Asna",
      "role": "Halaman Tentang",
      "image": "https://i.ibb.co.com/9FYRLbw/asna.jpg"
    },
    {
      "name": "Nafisah",
      "role": "Halaman Home",
      "image": "https://i.ibb.co.com/zHVm6x0L/nafisah.jpg"
    },
    {
      "name": "Niken",
      "role": "Halaman Login & Register",
      "image": "https://i.ibb.co.com/ZRPKHZg7/niken.jpg"
    },
    {
      "name": "Teguh",
      "role": "Halaman Produk",
      "image": "https://i.ibb.co.com/LXzKxmK5/teguh.jpg"
    },
  ];

  Future<void> _openCart() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CartScreen()));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F4),

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
            _buildNavItem(Icons.home_rounded, "Home", false, () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            }),
            _buildNavItem(Icons.shopping_bag_rounded, "Produk", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProdukScreen()));
            }),
            _buildNavItem(Icons.pets_rounded, "Adopsi", false, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const AdopsiScreen()));
            }),
            _buildNavItem(Icons.info_outline_rounded, "Tentang", true, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()));
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
                            Text("PetshopCat 🐾",
                                style: GoogleFonts.pacifico(
                                    color: Colors.white, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text("Tentang Kami",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.pacifico(
                                    fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () =>
                              setState(() => _showSearch = !_showSearch),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 28)),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: _openCart,
                        child: Stack(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                color: Colors.white, size: 28),
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
                                        SearchScreen(query: value.trim())));
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Cari info...",
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text("Tentang Kami",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffD95C76))),
                    const SizedBox(height: 5),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.pets, color: Color(0xffF5C5C5)),
                          SizedBox(width: 6),
                          Text("PetShopCat 🐾",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffD95C76))),
                          SizedBox(width: 6),
                          Icon(Icons.favorite, color: Color(0xffF5C5C5)),
                        ]),
                    const SizedBox(height: 20),

                    // ✅ LOGO ONLINE
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xffF28F8F), width: 4),
                        image: const DecorationImage(
                            image: NetworkImage(
                                'https://i.ibb.co.com/bMHGnL46/logopetshop.jpg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ================= ABOUT CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(children: [
                              Icon(Icons.pets,
                                  color: Color(0xffF28F8F), size: 18),
                              SizedBox(width: 8),
                              Text("Tentang PetShopCat",
                                  style: TextStyle(
                                      color: Color(0xffE56B7B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18))
                            ]),
                            SizedBox(height: 15),
                            Text(
                                "PetShopCat adalah website yang menyediakan berbagai kebutuhan kucing kesayanganmu, mulai dari makanan, perlengkapan, hingga informasi adopsi kucing.",
                                style: TextStyle(fontSize: 15, height: 1.8)),
                            SizedBox(height: 12),
                            Text(
                                "Kami berkomitmen untuk memberikan pelayanan terbaik untuk semua pecinta kucing.",
                                style: TextStyle(fontSize: 15, height: 1.8)),
                          ]),
                    ),
                    const SizedBox(height: 18),

                    // ================= DEVELOPMENT TEAM (MANUAL SCROLL) =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.pets,
                                color: Color(0xffF28F8F), size: 18),
                            SizedBox(width: 8),
                            Text("Development Team",
                                style: TextStyle(
                                    color: Color(0xffE56B7B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))
                          ]),
                          const SizedBox(height: 18),

                          // ✅ LANGSUNG DITULIS DI SINI (TANPA AUTO SCROLL)
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: developers.length,
                              itemBuilder: (context, index) {
                                final dev = developers[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailDeveloperPage(
                                          name: dev['name'],
                                          role: dev['role'],
                                          image: dev['image'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 18),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 31,
                                          backgroundColor:
                                              const Color(0xffF28F8F),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundImage:
                                                NetworkImage(dev['image']),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(dev['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xffD95C76))),
                                        const SizedBox(height: 3),
                                        Text(dev['role'],
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ================= HUBUNGI KAMI =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.pets,
                                color: Color(0xffF28F8F), size: 18),
                            SizedBox(width: 8),
                            Text("Hubungi Kami",
                                style: TextStyle(
                                    color: Color(0xffE56B7B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))
                          ]),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffF28F8F),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onPressed: () {},
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text("Hubungi via WhatsApp",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
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
}

// =====================================
// DETAIL PAGE
// =====================================
class DetailDeveloperPage extends StatelessWidget {
  final String name;
  final String role;
  final String image;

  const DetailDeveloperPage(
      {super.key, required this.name, required this.role, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xffF28F8F),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("Detail Anggota", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 63,
                  backgroundColor: const Color(0xffF28F8F),
                  child: CircleAvatar(
                      radius: 59, backgroundImage: NetworkImage(image)),
                ),
                const SizedBox(height: 18),
                Text(name,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffD95C76))),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xffF6A5A5),
                      borderRadius: BorderRadius.circular(12)),
                  child:
                      Text(role, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 35),
                const Row(children: [
                  Icon(Icons.pets, color: Color(0xffF28F8F), size: 18),
                  SizedBox(width: 8),
                  Text("Tentang Saya",
                      style: TextStyle(
                          color: Color(0xffE56B7B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18))
                ]),
                const SizedBox(height: 18),
                Text(getDescription(role),
                    style: const TextStyle(fontSize: 15, height: 1.9)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF28F8F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Kembali",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String getDescription(String role) {
  switch (role) {
    case "Halaman Adopsi":
      return "NIM : 19241515\n\nBertugas membuat Tampilan halaman adopsi";
    case "Halaman Tentang":
      return "NIM : 19241781\n\nBertugas Membuat Tampilan Halaman Profil(Tentang kami).";
    case "Halaman Home":
      return "NIM : 19242053\n\nBertugas membuat Tampilan halaman Home Screen";
    case "Halaman Login & Register":
      return "NIM : 19240691\n\nBertugas membuat Tampilan halaman login & register serta splash screen.";
    case "Halaman Produk":
      return "NIM : 19240174\n\nBertugas membuat Tampilan halaman produk dan mengintegrasikan dengan database";
    default:
      return "Anggota Development Team PetShopCat";
  }
}
