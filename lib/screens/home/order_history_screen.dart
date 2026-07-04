import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/theme/app_theme.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Dikirim':
        return Colors.teal;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule_outlined;
      case 'Diproses':
        return Icons.inventory_outlined;
      case 'Dikirim':
        return Icons.local_shipping_outlined;
      case 'Selesai':
        return Icons.check_circle_outline;
      case 'Dibatalkan':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // ✅ FUNGSI BARU: Konfirmasi & Batalkan Pesanan menggunakan TRANSACTION
  Future<void> _cancelOrder(BuildContext context, String docId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Batalkan Pesanan?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text(
                  'Apakah kamu yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat diurungkan.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child:
                      const Text('Tidak', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Ya, Batalkan',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirm) {
      try {
        DocumentReference orderRef =
            FirebaseFirestore.instance.collection('orders').doc(docId);

        // ✅ Gunakan Transaction agar pengecekan status dan update berjalan secara atomik
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(orderRef);

          if (snapshot.exists) {
            String currentStatus = snapshot['status'];

            // Cek lagi di dalam transaction, apakah statusnya masih bisa dibatalkan?
            if (currentStatus == 'Pending' || currentStatus == 'Diproses') {
              transaction.update(orderRef, {'status': 'Dibatalkan'});
            } else {
              // Jika status sudah berubah (misal jadi Dikirim/Selesai), lempar error
              throw Exception(
                  'Pesanan tidak dapat dibatalkan karena status sudah berubah menjadi $currentStatus');
            }
          }
        });

        // Jika transaction berhasil
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Pesanan berhasil dibatalkan'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        // Jika transaction gagal (karena status berubah atau error koneksi)
        if (context.mounted) {
          String errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Gagal membatalkan pesanan';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan',
            style: TextStyle(
                color: AppTheme.peachDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.peachDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.peachMain));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text('Gagal memuat pesanan',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                        'Cek Debug Console untuk link pembuatan Index Firestore.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                    Text(snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('Belum ada pesanan',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Riwayat pesananmu akan muncul di sini',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
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
              int totalPrice = data['totalPrice'] ?? 0;
              String status = data['status'] ?? 'Pending';
              Timestamp? createdAt = data['createdAt'];

              // ✅ Cek apakah tombol batal harus ditampilkan
              bool canCancel = status == 'Pending' || status == 'Diproses';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                  border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                      width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#$orderId',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1F2937))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(_getStatusIcon(status),
                                    size: 14, color: _getStatusColor(status)),
                                const SizedBox(width: 4),
                                Text(status,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _getStatusColor(status))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Date
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(_formatDate(createdAt),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Items Summary
                      ...(data['items'] as List<dynamic>? ?? [])
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item['name']} x${item['qty']}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF4B5563))),
                                    Text(
                                        'Rp ${formatRupiah((item['price'] as int) * (item['qty'] as int))}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF4B5563))),
                                  ],
                                ),
                              ))
                          .toList(),

                      const Divider(height: 24),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Rp ${formatRupiah(totalPrice)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.peachMain)),
                        ],
                      ),

                      // ✅ TOMBOL BATALKAN PESANAN
                      if (canCancel) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () => _cancelOrder(context, doc.id),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Batalkan Pesanan',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ],
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
