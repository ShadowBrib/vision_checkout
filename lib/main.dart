import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/camera_screen.dart';

Future<void> main() async {
  // Flutter motorunun tam olarak yüklendiğinden emin ol
  WidgetsFlutterBinding.ensureInitialized();
  
  // FİREBASE BAŞLATMA KODU
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const VisionCheckoutApp());
}

class VisionCheckoutApp extends StatelessWidget {
  const VisionCheckoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Checkout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      // YENİ SİSTEM: Kamera listesi göndermemize gerek kalmadı, doğrudan sayfayı çağırıyoruz
      home: const KameraEkrani(),
    );
  }
}