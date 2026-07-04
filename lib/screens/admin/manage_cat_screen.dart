import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_cat_screen.dart';
import '../../utils/image_helper.dart';

class ManageCatScreen extends StatelessWidget {
  const ManageCatScreen({super.key});

  // ================= FUNGSI HAPUS KUCING (DENGAN KONFIRMASI) =================
  Future<void> _deleteCat(
      BuildContext context, String docId, String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Data Kucing?',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                const TextSpan(
                    text: 'Apakah Anda yakin ingin menghapus data kucing '),
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
        await FirebaseFirestore.instance.collection('cats').doc(docId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Data kucing berhasil dihapus'),
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
        title: const Text('Kelola Kucing Adopsi',
            style: TextStyle(
                color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= LIST KUCING =================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cats')
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
                  Icon(Icons.pets_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('Belum ada kucing adopsi',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Klik tombol + untuk menambahkan kucing baru',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          var cats = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              var doc = cats[index];
              var data = doc.data() as Map<String, dynamic>? ?? {};

              String docId = doc.id;
              String name = data['name'] ?? 'Tanpa Nama';
              String age = data['age'] ?? '-';
              String gender = data['gender'] ?? '-';
              // ❌ HAPUS: String imageUrl = data['imageUrl'] ?? ''; (Sudah tidak dipakai)
              String status = data['status'] ?? 'Ready Adopt';

              // Warna badge status
              Color statusColor =
                  status == 'Ready Adopt' ? Colors.green : Colors.orange;
              IconData genderIcon =
                  gender.toLowerCase() == 'male' ? Icons.male : Icons.female;

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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(genderIcon, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('$age • $gender',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent.withOpacity(0.7), size: 22),
                    onPressed: () => _deleteCat(context, docId, name),
                    tooltip: 'Hapus Kucing',
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
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddCatScreen()));
        },
        backgroundColor: const Color(0xFFFF9A8A),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Kucing',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}