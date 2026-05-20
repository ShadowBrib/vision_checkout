import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class UrunEklemeEkrani extends StatefulWidget {
  const UrunEklemeEkrani({super.key});

  @override
  State<UrunEklemeEkrani> createState() => _UrunEklemeEkraniState();
}

class _UrunEklemeEkraniState extends State<UrunEklemeEkrani> {
  // Form içine yazılacak yazıları kontrol eden araçlar
  final TextEditingController _barkodController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();

  bool _kameraAcik = true;
  bool _kaydediliyor = false;

  // Verileri toplayıp Firebase'e gönderen fonksiyon
  Future<void> _urunuKaydet() async {
    // Güvenlik: İsim veya barkod boşsa uyarı ver ve işlemi durdur
    if (_barkodController.text.isEmpty || _isimController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen barkod ve isim alanlarını doldurun!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _kaydediliyor = true; }); // Butonu yükleniyor animasyonuna çevir

    try {
      await FirebaseFirestore.instance.collection('urunler').add({
        'barkod': _barkodController.text,
        'isim': _isimController.text,
        'fiyat': double.tryParse(_fiyatController.text) ?? 0.0, // Harf girilirse 0.0 kabul et
        'stok': int.tryParse(_stokController.text) ?? 0,
        'skt': _sktController.text,
        'eklenmeTarihi': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ürün başarıyla eklendi! 🎉'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Başarılı olursa eski ekrana (kasiyer ekranına) geri dön
      }
    } catch (e) {
      debugPrint("Kaydetme hatası: $e");
    } finally {
      if (mounted) setState(() { _kaydediliyor = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Yeni Ürün Kaydı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.deepOrange), // Geri tuşu rengi
      ),
      body: SingleChildScrollView( // Klavye açılınca ekranı kaydırabilmek için
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. KAMERA BÖLÜMÜ ---
            if (_kameraAcik)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepOrange, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        setState(() {
                          _barkodController.text = barcode.rawValue!; // Barkodu yakala ve forma yaz
                          _kameraAcik = false; // Yakaladıktan sonra kamerayı kapat ki form rahat dolsun
                        });
                        break;
                      }
                    }
                  },
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => setState(() => _kameraAcik = true),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamerayı Tekrar Aç'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
              ),

            const SizedBox(height: 20),

            // --- 2. FORM BÖLÜMÜ ---
            TextField(
              controller: _barkodController,
              decoration: const InputDecoration(labelText: 'Barkod Numarası', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _isimController,
              decoration: const InputDecoration(labelText: 'Ürün İsmi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fiyatController,
                    decoration: const InputDecoration(labelText: 'Fiyat (TL)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stokController,
                    decoration: const InputDecoration(labelText: 'Stok Adedi', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sktController,
              decoration: const InputDecoration(labelText: 'Son Tüketim Tarihi (Örn: 12/2026)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),

            // --- 3. KAYDET BUTONU ---
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _kaydediliyor ? null : _urunuKaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: _kaydediliyor 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ürünü Veritabanına Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}