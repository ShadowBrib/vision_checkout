import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KameraEkrani extends StatefulWidget {
  final List<CameraDescription> kameralar;

  const KameraEkrani({super.key, required this.kameralar});

  @override
  State<KameraEkrani> createState() => _KameraEkraniState();
}

class _KameraEkraniState extends State<KameraEkrani> {
  late CameraController _controller;
  bool _isReady = false;

  // Geçici test verisi ekleme fonksiyonu
  Future<void> _testUrunuEkle() async {
    try {
      await FirebaseFirestore.instance.collection('urunler').add({
        'isim': 'Portakal',
        'fiyat': 24.50,
        'stok': 50,
        'kategori': 'Meyve',
        'eklenmeTarihi': FieldValue.serverTimestamp(),
      });
      
      // Başarılı olursa ekranda küçük bir uyarı gösterelim
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portakal başarıyla veritabanına eklendi! 🍊'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    }
  }
  
  @override
  void initState() {
    super.initState();
    // İlk kamerayı (genelde arka kamera) seç ve başlat
    _controller = CameraController(widget.kameralar[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        debugPrint('Kamera hatası: ${e.description}');
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
    if (!_isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    // Ekran boyutlarını alıyoruz (Çerçeveyi ortalamak için)
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ürün Tanıma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        centerTitle: true,
        // BUTON BURAYA EKLENDİ
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
            onPressed: _testUrunuEkle, 
            tooltip: 'Test Ürünü Ekle',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Katman: Kameradan gelen tam ekran canlı görüntü
          SizedBox(
            width: size.width,
            height: size.height,
            child: CameraPreview(_controller),
          ),
          
          // 2. Katman: Tarama Çerçevesi (Ortadaki turuncu kare)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrange, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          // 3. Katman: Alt kısımdaki bilgi ve durum kartı
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.document_scanner, color: Colors.deepOrange, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Ürün Bekleniyor...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Lütfen ürünü veya barkodu çerçevenin içine yerleştirin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}