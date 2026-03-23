import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class KameraEkrani extends StatefulWidget {
  const KameraEkrani({super.key});

  @override
  State<KameraEkrani> createState() => _KameraEkraniState();
}

class _KameraEkraniState extends State<KameraEkrani> {
  // Ekranda göstereceğimiz durum değişkenleri
  String _durumBaslik = 'Ürün Bekleniyor...';
  String _durumDetay = 'Lütfen ürünü veya barkodu çerçevenin içine yerleştirin.';
  Color _kartRengi = Colors.white;
  IconData _kartIkoni = Icons.document_scanner;
  
  // Kameranın saniyede onlarca kez aynı barkodu okumasını engellemek için bir kilit
  bool _islemYapiliyor = false;

  // Barkod okunduğunda çalışacak ana fonksiyon
  Future<void> _barkoduVeritabanindaAra(String okunanBarkod) async {
    if (_islemYapiliyor) return; // Zaten bir ürün aranıyorsa dur
    
    setState(() {
      _islemYapiliyor = true;
      _durumBaslik = 'Aranıyor...';
      _durumDetay = 'Barkod: $okunanBarkod sorgulanıyor.';
      _kartIkoni = Icons.search;
    });

    try {
      // Firebase'e gidip 'barkod' alanı okunan barkoda eşit olan ürünü getir
      var sonuc = await FirebaseFirestore.instance
          .collection('urunler')
          .where('barkod', isEqualTo: okunanBarkod)
          .limit(1)
          .get();

      if (sonuc.docs.isNotEmpty) {
        // Ürün bulundu!
        var urunBilgisi = sonuc.docs.first.data();
        setState(() {
          _durumBaslik = urunBilgisi['isim'];
          _durumDetay = 'Fiyat: ${urunBilgisi['fiyat']} TL | Stok: ${urunBilgisi['stok']}';
          _kartRengi = Colors.green.shade50;
          _kartIkoni = Icons.check_circle;
        });
      } else {
        // Barkod okundu ama Firebase'de yok
        setState(() {
          _durumBaslik = 'Kayıtsız Ürün';
          _durumDetay = 'Bu barkod ($okunanBarkod) sistemde bulunamadı.';
          _kartRengi = Colors.red.shade50;
          _kartIkoni = Icons.error;
        });
      }
    } catch (e) {
      debugPrint("Arama hatası: $e");
    }

    // 3 saniye sonra ekranı tekrar yeni ürün okumaya hazır hale getir
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _islemYapiliyor = false;
          _durumBaslik = 'Sıradaki Ürün...';
          _durumDetay = 'Yeni bir barkod okutabilirsiniz.';
          _kartRengi = Colors.white;
          _kartIkoni = Icons.document_scanner;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ürün Tanıma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Katman: Akıllı Barkod Tarayıcı Kamera
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _barkoduVeritabanindaAra(barcode.rawValue!);
                  break; // İlk bulduğu barkodu alıp döngüden çıkması yeterli
                }
              }
            },
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
          
          // 3. Katman: Dinamik Bilgi Kartı
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kartRengi.withOpacity(0.95),
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
                  Icon(_kartIkoni, color: Colors.deepOrange, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _durumBaslik,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _durumDetay,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[800], fontSize: 15),
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