import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart'
    as pw; // Wajib pakai 'as pw' agar tidak bentrok
import 'package:printing/printing.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  // ✅ Helper Format Rupiah
  String formatRupiah(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // ✅ Logika Update Status ke Firestore
  Future<void> _updateStatus(String currentStatus) async {
    List<String> statuses = ['Pending', 'Diproses', 'Dikirim', 'Selesai'];
    int currentIndex = statuses.indexOf(currentStatus);

    if (currentIndex < statuses.length - 1) {
      String nextStatus = statuses[currentIndex + 1];
      try {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({'status': nextStatus});
      } catch (e) {
        debugPrint('Gagal update status: $e');
      }
    }
  }

  // ✅ Logika Cetak Struk PDF
  Future<void> _printReceipt(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    List items = data['items'] ?? [];
    int totalPrice = data['totalPrice'] ?? 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('PETSHOPCAT',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Center(
                  child: pw.Text('Struk Pesanan',
                      style: const pw.TextStyle(fontSize: 14)),
                ),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Text('Order ID: #${orderId.substring(0, 8).toUpperCase()}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Customer: ${data['userName'] ?? '-'}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Alamat: ${data['address'] ?? '-'}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 24),
                pw.Table.fromTextArray(
                  headers: ['Item', 'Qty', 'Harga', 'Subtotal'],
                  data: items
                      .map((item) => [
                            item['name'],
                            '${item['qty']}',
                            'Rp ${formatRupiah(item['price'])}',
                            'Rp ${formatRupiah((item['price'] as int) * (item['qty'] as int))}',
                          ])
                      .toList(),
                  border: pw.TableBorder.all(),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                  },
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total: ',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text('Rp ${formatRupiah(totalPrice)}',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ],
                ),
                pw.Divider(),
                pw.Center(
                  child: pw.Text('Terima kasih telah berbelanja!',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Tampilkan dialog print
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Detail Pesanan',
            style: TextStyle(
                color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9A8A)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          List items = data['items'] ?? [];
          String status = data['status'] ?? 'Pending';
          int totalPrice = data['totalPrice'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= INFO CUSTOMER =================
                _buildSection(
                  title: 'Informasi Customer',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${data['userName'] ?? '-'}',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Alamat: ${data['address'] ?? '-'}',
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ================= STATUS & ACTIONS =================
                _buildSection(
                  title: 'Status Pesanan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            backgroundColor: _getStatusColor(status),
                          ),
                          const Spacer(),
                          // ✅ TOMBOL DISEMBUNYIKAN JIKA SUDAH SELESAI ATAU DIBATALKAN
                          if (status != 'Selesai' && status != 'Dibatalkan')
                            ElevatedButton.icon(
                              onPressed: () => _updateStatus(status),
                              icon: const Icon(Icons.arrow_forward_rounded,
                                  size: 16),
                              label: Text('Ubah ke ${_getNextStatus(status)}'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9A8A),
                                  foregroundColor: Colors.white),
                            ),
                        ],
                      ),
                      // ✅ Info tambahan jika pesanan dibatalkan
                      if (status == 'Dibatalkan') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Pesanan ini telah dibatalkan oleh Customer.',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ================= DAFTAR ITEM =================
                _buildSection(
                  title: 'Daftar Produk',
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      var item = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item['name'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Qty: ${item['qty']}'),
                        trailing: Text(
                            'Rp ${formatRupiah((item['price'] as int) * (item['qty'] as int))}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ================= TOTAL & CETAK =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Harga',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Rp ${formatRupiah(totalPrice)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9A8A))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: () => _printReceipt(data),
                          icon: const Icon(Icons.print_rounded),
                          label: const Text('Cetak Struk',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1F2937),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
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
        return Colors.redAccent; // ✅ Tambahkan warna Dibatalkan
      default:
        return Colors.grey;
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Diproses';
      case 'Diproses':
        return 'Dikirim';
      case 'Dikirim':
        return 'Selesai';
      default:
        return '';
    }
  }
}
