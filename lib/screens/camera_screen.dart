import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'urun_ekleme_ekrani.dart';

class KameraEkrani extends StatefulWidget {
  const KameraEkrani({super.key});

  @override
  State<KameraEkrani> createState() => _KameraEkraniState();
}

class _KameraEkraniState extends State<KameraEkrani> {
  // Kamerayı durdurup başlatmak için kontrolcü
  final MobileScannerController _kameraMotoru = MobileScannerController();

  String _durumBaslik = 'Ürün Bekleniyor...';
  String _durumDetay = 'Lütfen ürünü veya barkodu çerçevenin içine yerleştirin.';
  Color _kartRengi = Colors.white;
  IconData _kartIkoni = Icons.document_scanner;
  bool _islemYapiliyor = false;

  Future<void> _barkoduVeritabanindaAra(String okunanBarkod) async {
    if (_islemYapiliyor) return; 
    
    setState(() {
      _islemYapiliyor = true;
      _durumBaslik = 'Aranıyor...';
      _durumDetay = 'Barkod: $okunanBarkod sorgulanıyor.';
      _kartIkoni = Icons.search;
    });

    try {
      var sonuc = await FirebaseFirestore.instance
          .collection('urunler')
          .where('barkod', isEqualTo: okunanBarkod)
          .limit(1)
          .get();

      if (sonuc.docs.isNotEmpty) {
        var urunBilgisi = sonuc.docs.first.data();
        setState(() {
          _durumBaslik = urunBilgisi['isim'];
          _durumDetay = 'Fiyat: ${urunBilgisi['fiyat']} TL | Stok: ${urunBilgisi['stok']}';
          _kartRengi = Colors.green.shade50;
          _kartIkoni = Icons.check_circle;
        });
      } else {
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
  void dispose() {
    _kameraMotoru.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar'ı kaldırdık, daha modern ve tam ekran bir görüntü sağladık
      body: Stack(
        children: [
          // 1. Katman: Akıllı Barkod Tarayıcı Kamera (Tam Ekran)
          MobileScanner(
            controller: _kameraMotoru,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _barkoduVeritabanindaAra(barcode.rawValue!);
                  break; 
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
          
          // 3. Katman (YENİ): Dinamik Bilgi Kartı (EKRANIN EN ÜSTÜNE TAŞINDI)
          Positioned(
            top: 50, // Üst kısımdan biraz boşluk
            left: 20,
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(15), // Biraz daha ince yaptık
              decoration: BoxDecoration(
                color: _kartRengi.withOpacity(0.90),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row( // Sığdırmak için Row (yatay) düzenine geçtik
                children: [
                  Icon(_kartIkoni, color: Colors.deepOrange, size: 35),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _durumBaslik,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _durumDetay,
                          style: TextStyle(color: Colors.grey[800], fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // YENİ MODEL: FloatingActionButton yerine bütünleşik Alt Bar Butonu
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border(top: BorderSide(color: Colors.grey.shade900, width: 1)),
        ),
        child: SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              _kameraMotoru.stop(); // Gitmeden önce buradaki kamerayı uyut
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UrunEklemeEkrani()),
              );
              _kameraMotoru.start(); // Geri dönünce kamerayı uyandır
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            label: const Text(
              'YENİ ÜRÜN EKLE',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
            ),
          ),
        ),
      ),
    );
  }
}