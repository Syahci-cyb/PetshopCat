import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '/theme/app_theme.dart';
import '../../utils/image_helper.dart';
import '../../services/cart_service.dart'; // ✅ Import CartService

class SearchScreen extends StatefulWidget {
  final String query;
  // ❌ HAPUS: final List<Map<String, dynamic>> cartItems; 

  // ✅ Konstruktor hanya butuh query sekarang
  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  
  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _launchWhatsApp(String message) async {
    final url = Uri.parse("https://wa.me/6281234567890?text=${Uri.encodeComponent(message)}");
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

  // ✅ GUNAKAN CartService + setState
  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      CartService.addToCart(item);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} ditambahkan! 🛒'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query produkQuery = FirebaseFirestore.instance
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: widget.query)
        .where('name', isLessThanOrEqualTo: widget.query + '\uf8ff')
        .limit(10);

    Query kucingQuery = FirebaseFirestore.instance
        .collection('cats')
        .where('name', isGreaterThanOrEqualTo: widget.query)
        .where('name', isLessThanOrEqualTo: widget.query + '\uf8ff')
        .limit(10);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text('Pencarian: "${widget.query}"', 
            style: const TextStyle(color: AppTheme.peachDark, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.peachDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Produk', Icons.shopping_bag_outlined),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: produkQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.peachMain));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState('Tidak ada produk ditemukan.');
                
                var products = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var data = products[index].data() as Map<String, dynamic>? ?? {};
                    return _buildProductCard(data);
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Kucing Adopsi', Icons.pets_rounded),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: kucingQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppTheme.peachMain));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState('Tidak ada kucing ditemukan.');
                
                var cats = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    var data = cats[index].data() as Map<String, dynamic>? ?? {};
                    return _buildCatCard(data);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.peachDark, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.peachDark)),
      ],
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageHelper.showImage(
              {'imageUrl': data['imageUrl'] ?? '', 'imageBase64': data['imageBase64']},
              width: 80, height: 80, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Rp ${formatRupiah(data['price'] ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.peachMain)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppTheme.peachMain, borderRadius: BorderRadius.circular(12)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _addToCart({
                  'name': data['name'], 'price': data['price'], 
                  'imageUrl': data['imageUrl'] ?? '', 'imageBase64': data['imageBase64'], 'qty': 1,
                }),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageHelper.showImage(
              {'imageUrl': data['imageUrl'] ?? '', 'imageBase64': data['imageBase64']},
              width: 80, height: 80, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${data['age'] ?? '-'} · ${data['gender'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(12)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _launchWhatsApp('Halo PetshopCat, saya tertarik dengan kucing ${data['name']} 🐱'),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}