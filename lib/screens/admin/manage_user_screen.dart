import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/app_theme.dart';

class ManageUserScreen extends StatelessWidget {
  const ManageUserScreen({super.key});

  // ✅ Fungsi Nonaktifkan/Aktifkan User
  Future<void> _toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Kelola Pengguna',
            style: TextStyle(
                color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.peachMain));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Belum ada pengguna terdaftar.',
                    style: TextStyle(color: Colors.grey)));
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var doc = users[index];
              var data = doc.data() as Map<String, dynamic>? ??
                  {}; // ✅ Anti error null

              // ✅ Cek apakah field ada, jika tidak ada beri default
              String name = data.containsKey('name')
                  ? data['name'] ?? 'Tanpa Nama'
                  : 'Tanpa Nama';
              String email =
                  data.containsKey('email') ? data['email'] ?? '-' : '-';
              String role =
                  data.containsKey('role') ? data['role'] ?? 'user' : 'user';
              bool isActive = data.containsKey('isActive')
                  ? data['isActive'] ?? true
                  : true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? null
                      : Border.all(
                          color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          isActive ? AppTheme.peachMain : Colors.grey,
                      child: Text(name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isActive
                                      ? const Color(0xFF1F2937)
                                      : Colors.grey)),
                          Text(email,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          // Badge Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: role == 'admin'
                                  ? Colors.deepPurple.withOpacity(0.1)
                                  : Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: role == 'admin'
                                      ? Colors.deepPurple
                                      : Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ SWITCH NONAKTIFKAN USER
                    Column(
                      children: [
                        Switch(
                          value: isActive,
                          activeColor: Colors.green,
                          onChanged: (value) =>
                              _toggleUserStatus(doc.id, isActive),
                        ),
                        Text(isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                                fontSize: 10,
                                color:
                                    isActive ? Colors.green : Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
