import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/app_theme.dart';
import '/widgets/petshop_logo.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ================= STATE & CONTROLLERS =================
  // Variabel untuk menyembunyikan/menampilkan teks password
  bool obscurePassword = true;
  bool obscureConfirm = true;

  // State untuk menampilkan loading spinner saat proses registrasi berjalan
  bool isLoading = false;

  // Controller untuk menangkap input teks dari form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  // Instance Firebase Auth & Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOGIC REGISTRASI =================
  Future<void> _register() async {
    // [1] VALIDASI: Cek apakah password dan konfirmasi password cocok
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password tidak cocok!'),
            backgroundColor: Colors.red),
      );
      return; // Hentikan proses jika tidak cocok
    }

    // Tampilkan loading
    setState(() => isLoading = true);

    try {
      // [2] AUTHENTICATION: Buat akun baru di Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // [3] FIRESTORE: Simpan data lengkap user ke Database Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),

        // ✅ INI BAGIAN PALING PENTING!
        // Menetapkan role default sebagai 'user'.
        // Jika ini tidak ditambahkan, saat login sistem tidak tahu dia user biasa atau admin.
        'role': 'user',

        'createdAt': FieldValue.serverTimestamp(), // Catat waktu registrasi
      });

      // [4] SIGN OUT: Setelah registrasi berhasil, langsung logout akun tersebut.
      // Ini ditujukan agar user tidak langsung masuk ke homepage tanpa melalui proses Login,
      // atau jika nanti kamu mau menambahkan verifikasi email.
      await _auth.signOut();

      if (mounted) {
        // [5] FEEDBACK & NAVIGASI: Beri pesan sukses dan arahkan ke halaman Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()), // Arahkan ke Login
        );
      }
    } on FirebaseAuthException catch (e) {
      // [6] ERROR HANDLING: Tangkap error spesifik dari Firebase Auth
      String message = 'Terjadi kesalahan';
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah (minimal 6 karakter)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Tangkap error umum lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      // [7] SELESAI: Matikan loading spinner baik sukses maupun gagal
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= DISPOSE =================
  // Selalu dispose controller saat halaman ditutup untuk mencegah memory leak
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ================= UI BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.peachDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PetshopLogo(size: 100),
                  const SizedBox(height: 16),
                  const Text('Registrasi',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.peachDark)),
                  const SizedBox(height: 24),

                  // Form Inputs
                  _buildInput(
                      controller: nameController,
                      hint: 'Nama Lengkap',
                      icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildInput(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildInput(
                      controller: phoneController,
                      hint: 'No. HP',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildInput(
                      controller: addressController,
                      hint: 'Alamat',
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _buildPasswordInput(
                    controller: passwordController,
                    hint: 'Password',
                    obscure: obscurePassword,
                    onTapEye: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordInput(
                    controller: confirmController,
                    hint: 'Konfirmasi Password',
                    obscure: obscureConfirm,
                    onTapEye: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Registrasi
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: AppTheme.peachMain,
                        borderRadius: BorderRadius.circular(16)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isLoading ? null : _register,
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: AppTheme.white)
                              : const Text('Registrasi',
                                  style: TextStyle(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? ',
                          style: TextStyle(color: AppTheme.grey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Login',
                            style: TextStyle(
                                color: AppTheme.peachDark,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPER WIDGETS =================

  // Widget helper untuk membuat input text field standar agar tidak menulis kode berulang-ulang
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.peachDark),
        filled: true,
        fillColor: const Color(0xFFFFE0E6), // Warna background input
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none, // Tanpa border saat idle
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppTheme.peachMain,
              width: 1.5), // Border pink saat difokuskan
        ),
      ),
    );
  }

  // Widget helper khusus untuk input password (memiliki ikon mata/visibility)
  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onTapEye,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure, // Sembunyikan teks jika true
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.peachDark),
        filled: true,
        fillColor: const Color(0xFFFFE0E6),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.peachMain, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppTheme.grey),
          onPressed: onTapEye, // Fungsi toggle visibility
        ),
      ),
    );
  }
}
