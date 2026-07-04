import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage;
  String? _base64Image;
  bool _isUploading = false;
  
  String _selectedGender = 'Male'; 
  final List<String> _genders = ['Male', 'Female'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400, imageQuality: 50);

    if (pickedFile != null) {
      var bytes = await pickedFile.readAsBytes();
      String base64String = base64Encode(bytes);
      setState(() {
        _base64Image = base64String;
        if (kIsWeb) { _webImage = bytes; _imageFile = null; } 
        else { _imageFile = File(pickedFile.path); _webImage = null; }
      });
    }
  }

  Future<void> _uploadCat() async {
    if (_base64Image == null || _nameController.text.trim().isEmpty || _ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data dan pilih foto kucing!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await FirebaseFirestore.instance.collection('cats').add({
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender,
        'desc': _descController.text.trim(),
        'imageBase64': _base64Image,
        'status': 'Ready Adopt',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kucing adopsi berhasil ditambahkan! 🐱'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(_webImage!, fit: BoxFit.cover, width: double.infinity)),
        Positioned(top: 8, right: 8, child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFFFF9A8A)))),
      ]);
    } else if (!kIsWeb && _imageFile != null) {
      return Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity)),
        Positioned(top: 8, right: 8, child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFFFF9A8A)))),
      ]);
    }
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
      SizedBox(height: 8),
      Text('Klik untuk pilih foto kucing', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Tambah Kucing Adopsi', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 220, width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _base64Image != null ? Color(0xFFFF9A8A) : Color(0xFFE5E7EB), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2))]),
              child: _buildImagePreview(),
            ),
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2))]),
            child: Column(children: [
              _buildInput(controller: _nameController, hint: 'Nama Kucing', icon: Icons.pets_outlined),
              SizedBox(height: 12),
              _buildInput(controller: _ageController, hint: 'Umur (cth: 2 Months)', icon: Icons.cake_outlined),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xFFE5E7EB))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender, isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF1F2937)),
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Row(children: [
                          Icon(gender == 'Male' ? Icons.male : Icons.female, color: Color(0xFFFF9A8A), size: 20),
                          SizedBox(width: 8),
                          Text(gender, style: TextStyle(color: Color(0xFF1F2937), fontSize: 14)),
                        ]),
                      );
                    }).toList(),
                    onChanged: (String? newValue) => setState(() => _selectedGender = newValue!),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _descController, maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Deskripsi/Kebiasaan Kucing (Opsional)', hintStyle: TextStyle(color: Colors.grey, fontSize: 14), filled: true, fillColor: Color(0xFFF9FAFB),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFFF9A8A), width: 1.5)),
                ),
              ),
            ]),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadCat,
              icon: _isUploading ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.cloud_upload_outlined, size: 20),
              label: Text(_isUploading ? 'Mengupload...' : 'Upload Data Kucing', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF9A8A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), disabledBackgroundColor: Color(0xFFFF9A8A).withOpacity(0.7)),
            ),
          ),
          SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: Colors.grey, fontSize: 14), prefixIcon: Icon(icon, color: Color(0xFFFF9A8A), size: 20),
        filled: true, fillColor: Color(0xFFF9FAFB), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFFF9A8A), width: 1.5)),
      ),
    );
  }
}