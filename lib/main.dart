import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login & register/splash_screen.dart'; // Pastikan import ini sesuai path kamu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PetshopCatApp());
}

class PetshopCatApp extends StatelessWidget {
  const PetshopCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetshopCat',
      theme: ThemeData(
        fontFamily: 'DM Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9A8A),
          primary: const Color(0xFFFF9A8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF5F3),
        useMaterial3: true,
      ),
      // KUNCINYA ADA DI SINI: Arahkan home ke SplashScreen
      home: const SplashScreen(), 
    );
  }
}