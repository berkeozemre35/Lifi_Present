import Foundation
import CoreLocation
import Combine // ObservableObject için
import MapKit // MKCoordinateRegion ve diğer MapKit türleri için gerekli

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil // Kullanıcının konumu
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var region = MKCoordinateRegion( // Başlangıç bölgesi (örneğin İzmir)
        center: CLLocationCoordinate2D(latitude: 38.4237, longitude: 27.1428),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        // locationManager.authorizationStatus çağrılmadan önce super.init() çağrılmalı
        // ve authorizationStatus atanmalı. Ancak delegate ayarlanmadan önce status almak
        // her zaman en güncel olmayabilir. Delegate ayarlandıktan sonra
        // locationManagerDidChangeAuthorization tetiklenecektir.
        self.authorizationStatus = locationManager.authorizationStatus // Başlangıç durumu al
        super.init() // NSObject'nin init'ini çağır
        locationManager.delegate = self // Delegate'i ayarla (Bu satırdan sonra didChangeAuthorization tetiklenebilir)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // İstenilen hassasiyet
        locationManager.distanceFilter = kCLDistanceFilterNone // Güncelleme sıklığı (her hareket)

        // Eğer başlangıçta durum .notDetermined ise hemen izin isteyelim.
        if authorizationStatus == .notDetermined {
             requestLocationPermission()
        } else if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
             // Eğer izin zaten varsa, güncellemeleri başlatmayı deneyebiliriz.
             // Ancak startUpdatingLocation içinde de kontrol var, bu yüzden burada
             // tekrar çağırmak şart değil, didChangeAuthorization halleder.
             // startUpdatingLocation() // İsteğe bağlı olarak burada başlatılabilir
        }
    }

    func requestLocationPermission() {
        // Sadece .notDetermined durumunda izin istemek daha doğru
        if locationManager.authorizationStatus == .notDetermined {
           print("DEBUG: Konum izni isteniyor (.whenInUse)...")
           locationManager.requestWhenInUseAuthorization()
        }
    }

    func startUpdatingLocation() {
        let currentStatus = locationManager.authorizationStatus // En güncel durumu al
        if currentStatus == .authorizedWhenInUse || currentStatus == .authorizedAlways {
            print("DEBUG: Konum güncellemeleri başlatılıyor...")
            locationManager.startUpdatingLocation()
        } else {
            print("DEBUG: Konum güncellemeleri başlatılamadı, izin durumu: \(currentStatus). İzin isteniyor...")
            requestLocationPermission() // İzin yoksa veya henüz belirlenmediyse tekrar iste
        }
    }

    func stopUpdatingLocation() {
        print("DEBUG: Konum güncellemeleri durduruluyor.")
        locationManager.stopUpdatingLocation()
    }

    // --- CLLocationManagerDelegate Metotları ---

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Bu metot, izin durumu değiştiğinde VEYA delegate ilk ayarlandığında çağrılır.
        authorizationStatus = manager.authorizationStatus // @Published property'yi güncelle
        print("DEBUG: Konum yetki durumu değişti: \(authorizationStatus.rawValue)") // RawValue daha okunabilir olabilir

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // İzin verildi, güncellemeleri başlat (veya devam etmesini sağla)
            print("DEBUG: İzin verildi, konum güncellemeleri başlatılıyor/devam ediyor.")
            startUpdatingLocation()
        case .denied, .restricted:
            // İzin reddedildi veya kısıtlandı
            print("DEBUG: Konum izni reddedildi veya kısıtlandı.")
            // Kullanıcıya bilgi verilebilir, belki varsayılan bir bölgeye odaklanılabilir.
            // stopUpdatingLocation() çağrılabilir (ancak startUpdatingLocation zaten başlamayacaktır)
        case .notDetermined:
            // Henüz karar verilmedi, izin iste
            print("DEBUG: Konum izni henüz belirlenmedi, izin isteniyor.")
            requestLocationPermission()
        @unknown default:
            // Gelecekte eklenebilecek yeni durumlar için
            print("DEBUG: Bilinmeyen konum yetki durumu.")
            // stopUpdatingLocation() çağrılabilir
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
             print("DEBUG: Konum güncellemesi alındı ancak geçerli konum yok.")
             return
        }

        // **** DEBUG İÇİN PRINT İFADESİ ****
        print("DEBUG: Yeni konum alındı - Koordinatlar: \(latestLocation.coordinate), Zaman: \(latestLocation.timestamp)")

        // Konum verisini ve harita bölgesini ana thread'de güncelle (UI güncellemeleri için)
        DispatchQueue.main.async {
            self.location = latestLocation
            self.userLocation = latestLocation.coordinate
            let newRegion = MKCoordinateRegion(
                center: latestLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) // Daha yakın bir zoom
            )
            // Sadece bölge gerçekten değiştiyse güncellemek performansı artırabilir (isteğe bağlı)
            // if self.region.center.latitude != newRegion.center.latitude || self.region.center.longitude != newRegion.center.longitude {
                 self.region = newRegion
                 // **** DEBUG İÇİN PRINT İFADESİ ****
                 print("DEBUG: Harita bölgesi güncellendi - Merkez: \(self.region.center)")
            // }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // **** HATA DURUMUNU GÖRMEK İÇİN PRINT İFADESİ ****
        print("DEBUG: Konum hatası alındı: \(error.localizedDescription)")

        // Hata yönetimi: Örneğin, kullanıcıya bir hata mesajı gösterebilir veya
        // belirli hata kodlarına göre farklı işlemler yapabilirsiniz (örn: CLlocationError.denied)
        if let clError = error as? CLError {
            if clError.code == .denied {
                 print("DEBUG: CLError - Konum erişimi reddedildi (muhtemelen ayarlardan kapatıldı).")
                 // Yetki durumu zaten .denied olmalı, didChangeAuthorization bunu ele alır.
                 // stopUpdatingLocation() çağrılabilir.
            } else if clError.code == .locationUnknown {
                 print("DEBUG: CLError - Konum şu anda belirlenemiyor, ancak tekrar deneyin.")
                 // Geçici bir sorun olabilir.
            }
            // Diğer CLError kodları da ele alınabilir.
        }
    }
} // Class LocationManager Sonu
