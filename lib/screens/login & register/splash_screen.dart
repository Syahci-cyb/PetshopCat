import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahan 1: Import Firebase Auth
import '/widgets/petshop_logo.dart';
import 'login_screen.dart';
import '../home/home_screen.dart'; // Tambahan 2: Import HomeScreen (sesuaikan path jika beda)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _bounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return; // Tambahan 3: Pengaman agar tidak error

      // Tambahan 4: Cek apakah user sudah login atau belum
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Kalau sudah login -> ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Kalau belum login -> ke LoginScreen (seperti kode aslimu)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BAGIAN INI 100% TIDAK DISENTUH SAMA SEKALI
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tulisan Atas
            FadeTransition(
              opacity: _fadeOut,
              child: const Text(
                'Selamat datang di PetshopCat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFCC80), // Peach gelap
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Logo
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeOut,
                  child: Transform.scale(
                    scale: _bounce.value,
                    child: child,
                  ),
                );
              },
              child: const PetshopLogo(size: 180),
            ),

            const SizedBox(height: 30),

            // Tulisan Bawah
            FadeTransition(
              opacity: _fadeOut,
              child: const Text(
                'Temukan kebutuhan terbaik\nuntuk kucing kesayanganmu 🐾',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E), // Abu-abu
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
