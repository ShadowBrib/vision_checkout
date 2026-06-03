# 🛒 Vision-Checkout: Akıllı Barkod Okuyucu ve Kasa Sistemi

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-%23FF6F00.svg?style=for-the-badge&logo=TensorFlow&logoColor=white)

**Vision-Checkout**, donanım maliyetlerini ortadan kaldırarak akıllı telefon kameralarını güçlü birer barkod tarayıcı ve stok yönetim cihazına dönüştüren bulut tabanlı bir mobil uygulamadır. Geleneksel market kasalarının hantallığına karşı, küçük işletmeler ve saha çalışanları için hızlı, ergonomik ve yapay zeka altyapısına sahip bir çözüm sunar.

---

## 🌟 Temel Özellikler

* 📸 **Anlık Akıllı Tarama:** `mobile_scanner` paketi ile saniyeler içinde barkod yakalama ve çift okumayı engelleyen akıllı kilit mekanizması.
* ☁️ **Gerçek Zamanlı Veritabanı:** Firebase Cloud Firestore entegrasyonu sayesinde okunan ürünün fiyat ve stok bilgisini anında ekrana yansıtma.
* ➕ **Dinamik Ürün Kaydı:** Sistemde bulunmayan ürünler için asenkron kamera yönetimiyle çalışan, kesintisiz yeni ürün ekleme modülü.
* 📱 **Ergonomik Arayüz (UI/UX):** Market görevlisinin tek elle rahatça kullanabilmesi için tasarlanmış "Dengeli Ekran" modeli (Üstte bilgi kartı, altta eylem butonu).
* 🧠 **Yapay Zeka Altyapısı (TFLite):** Barkodsuz ürünlerin görüntüden tanınması için TensorFlow Lite model entegrasyon altyapısı.

---

## 📸 Ekran Görüntüleri

Uygulamanın temel işlevlerini gösteren ekran görüntüleri (Ana tarama ekranı, kayıtsız ürün uyarısı ve yeni ürün ekleme formu):

<img width="1024" height="412" alt="image" src="https://github.com/user-attachments/assets/39d9aaf2-33a7-481d-be8c-e8e41fb4520e" />


---

## 🛠️ Kullanılan Teknolojiler

* **Framework:** Flutter
* **Dil:** Dart
* **Veritabanı:** Firebase Cloud Firestore
* **Kamera Motoru:** mobile_scanner
* **Makine Öğrenmesi (ML):** TensorFlow Lite (tflite_v2)

---

## 🚀 Kurulum ve Çalıştırma Talimatları

Projeyi kendi bilgisayarınızda derlemek ve test etmek için aşağıdaki adımları izleyin:

### Gereksinimler
* Flutter SDK (Güncel sürüm)
* Android Studio / VS Code
* Aktif bir Firebase Projesi

### Adım Adım Kurulum

1.  **Projeyi Klonlayın:**
    ```bash
    git clone [https://github.com/ShadowBrib/vision-checkout.git](https://github.com/ShadowBrib/vision-checkout.git)
    cd vision-checkout
    ```

2.  **Bağımlılıkları Yükleyin:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Yapılandırması:**
    * Kendi Firebase projenizi oluşturun ve Firestore veritabanını aktif edin.
    * Projeye Android uygulamasını ekleyin ve indirdiğiniz `google-services.json` dosyasını `android/app/` dizininin içine yerleştirin.
    * Firestore kurallarını (Rules) test için aşağıdaki gibi güncelleyin:
      ```javascript
      allow read, write: if true;
      ```

4.  **Uygulamayı Başlatın:**
    Fiziksel bir cihaz bağlayın (Kamera kullanımı için emülatör önerilmez) ve derleyin:
    ```bash
    flutter run
    ```

---

## 💡 Karşılaşılan Zorluklar ve Çözümler
* **Gradle & Sürüm Çakışmaları:** TFLite ve modern Kotlin DSL (`build.gradle.kts`) arasındaki namespace çakışmaları, Android build aşamasında `plugins.withId` yöntemiyle dinamik olarak çözülmüştür.
* **Kamera Yaşam Döngüsü:** Sayfa geçişlerinde kameranın donanımı kilitlemesini engellemek için `MobileScannerController` üzerinden asenkron `stop()` ve `start()` metotları entegre edilmiştir.

---

## 🔮 Gelecek Planları (Roadmap)
- [ ] TFLite yapay zeka modelinin canlı arayüze tam entegrasyonu (Barkodsuz meyve/sebze tanıma).
- [ ] Sepet oluşturma ve PDF formatında fiş/fatura kesme özelliği.
- [ ] Firebase Auth ile Yönetici / Kasiyer rol ve giriş yetkilendirmeleri.

---

**Geliştirici:** Enes Çalış  
**İletişim & Portfolyo:** [GitHub - ShadowBrib](https://github.com/ShadowBrib)
