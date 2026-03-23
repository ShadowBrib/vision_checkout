import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // YENİ EKLENDİ
import 'firebase_options.dart'; // YENİ EKLENDİ

List<CameraDescription> kameralar = [];

Future<void> main() async {
  // Flutter motorunun tam olarak yüklendiğinden emin ol
  WidgetsFlutterBinding.ensureInitialized();
  
  // FİREBASE BAŞLATMA KODU (YENİ EKLENDİ)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Cihazdaki kameraları bul ve listeye at
  kameralar = await availableCameras();

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
      home: KameraEkrani(kameralar: kameralar),
    );
  }
}