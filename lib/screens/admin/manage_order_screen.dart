import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_detail_screen.dart';

class ManageOrderScreen extends StatelessWidget {
  const ManageOrderScreen({super.key});

  // ✅ Helper Format Rupiah
  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // ✅ Helper Format Tanggal
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ✅ Warna & Ikon berdasarkan status pesanan
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Diproses': return Colors.blue;
      case 'Dikirim': return Colors.teal;
      case 'Selesai': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending': return Icons.schedule_outlined;
      case 'Diproses': return Icons.inventory_outlined;
      case 'Dikirim': return Icons.local_shipping_outlined;
      case 'Selesai': return Icons.check_circle_outline;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Abu-abu terang profesional
      appBar: AppBar(
        title: const Text('Pesanan Masuk', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A8A)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('Belum ada pesanan masuk', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Pesanan akan muncul di sini setelah User checkout', style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center,),
                ],
              ),
            );
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var doc = orders[index];
              var data = doc.data() as Map<String, dynamic>? ?? {};
              
              String orderId = doc.id.substring(0, 8).toUpperCase();
              String userName = data['userName'] ?? 'Customer';
              int totalPrice = data['totalPrice'] ?? 0;
              String status = data['status'] ?? 'Pending';
              Timestamp? createdAt = data['createdAt'];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: doc.id),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Ikon Status
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 24),
                          ),
                          const SizedBox(width: 16),
                          
                          // Info Pesanan
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('#$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                                const SizedBox(height: 4),
                                Text(userName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(_formatDate(createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                              ],
                            ),
                          ),
                          
                          // Harga & Status Badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rp ${formatRupiah(totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status, 
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _getStatusColor(status))
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}