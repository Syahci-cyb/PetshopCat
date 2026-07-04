import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/app_theme.dart';
import 'manage_category_screen.dart';
import 'manage_product_screen.dart';
import 'manage_cat_screen.dart';
import 'manage_user_screen.dart';
import 'manage_order_screen.dart';
import '../login & register/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Abu-abu terang profesional
      appBar: AppBar(
        title: const Text('PetshopCat Admin',
            style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STATISTIK DATA =================
            Row(
              children: [
                _buildStatCard(
                  title: 'Total Produk',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Kucing Adopsi',
                  icon: Icons.pets_outlined,
                  color: Colors.orange,
                  stream:
                      FirebaseFirestore.instance.collection('cats').snapshots(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  title: 'Total User',
                  icon: Icons.people_alt_outlined,
                  color: Colors.green,
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Pesanan Baru',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.purple,
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('status', isEqualTo: 'Pending')
                      .snapshots(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ================= MENU KELOLA =================
            const Text('Manajemen Menu',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151))),
            const SizedBox(height: 16),
            _buildMenuCard(context,
                icon: Icons.category_outlined,
                title: 'Kelola Kategori',
                subtitle: 'Tambah, edit, atau hapus kategori produk',
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageCategoryScreen()))),
            _buildMenuCard(context,
                icon: Icons.shopping_bag_outlined,
                title: 'Kelola Produk',
                subtitle: 'Upload dan kelola produk toko',
                color: Colors.orange,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageProductScreen()))),
            _buildMenuCard(context,
                icon: Icons.pets_outlined,
                title: 'Kelola Adopsi',
                subtitle: 'Upload dan kelola data kucing',
                color: Colors.blue,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageCatScreen()))),
            _buildMenuCard(context,
                icon: Icons.people_alt_outlined,
                title: 'Kelola User',
                subtitle: 'Lihat dan nonaktifkan akun user',
                color: Colors.green,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageUserScreen()))),
            _buildMenuCard(context,
                icon: Icons.receipt_long_outlined,
                title: 'Kelola Pesanan',
                subtitle: 'Proses pesanan masuk & cetak',
                color: Colors.redAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageOrderScreen()))),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET STATISTIK =================
  Widget _buildStatCard(
      {required String title,
      required IconData icon,
      required Color color,
      required Stream<QuerySnapshot> stream}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Text(count.toString(),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)));
              },
            ),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET MENU LIST =================
  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1F2937))),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
