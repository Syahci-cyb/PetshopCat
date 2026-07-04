import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_screen.dart';
import '../../utils/image_helper.dart';

class ManageProductScreen extends StatelessWidget {
  const ManageProductScreen({super.key});

  // ✅ Helper Format Rupiah
  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // ================= FUNGSI HAPUS PRODUK (DENGAN KONFIRMASI) =================
  Future<void> _deleteProduct(
      BuildContext context, String docId, String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Produk?',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                const TextSpan(
                    text: 'Apakah Anda yakin ingin menghapus produk '),
                TextSpan(
                    text: name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(docId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Produk berhasil dihapus'),
                backgroundColor: Colors.redAccent),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menghapus: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Abu-abu terang profesional
      appBar: AppBar(
        title: const Text('Kelola Produk',
            style: TextStyle(
                color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= LIST PRODUK =================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9A8A)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('Belum ada produk',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Klik tombol + untuk menambah produk baru',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          var products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var doc = products[index];
              var data = doc.data() as Map<String, dynamic>; // ✅ Ekstrak data sekali saja
              
              String docId = doc.id;
              String name = data['name'] ?? 'Tanpa Nama';
              int price = data['price'] ?? 0;
              String category = data['category'] ?? 'Umum';
              // ❌ HAPUS: String imageUrl = doc['imageUrl'] ?? ''; (Tidak dipakai lagi)

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  // ✅ UBAH: Langsung pakai ImageHelper tanpa Container/ClipRRect tambahan
                  leading: ImageHelper.showImage(
                    data, 
                    width: 60, 
                    height: 60, 
                    borderRadius: 10,
                  ),
                  title: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2937))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(category,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF9A8A))),
                      ),
                      const SizedBox(height: 4),
                      Text('Rp ${formatRupiah(price)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFFFF9A8A))),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent.withOpacity(0.7), size: 22),
                    onPressed: () => _deleteProduct(context, docId, name),
                    tooltip: 'Hapus Produk',
                  ),
                ),
              );
            },
          );
        },
      ),

      // ================= TOMBOL FLOATING TAMBAH =================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()));
        },
        backgroundColor: const Color(0xFFFF9A8A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Produk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}