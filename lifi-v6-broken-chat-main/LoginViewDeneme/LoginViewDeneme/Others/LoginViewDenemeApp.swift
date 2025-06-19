//
//  LoginViewDenemeApp.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.12.2024.
//


import SwiftUI
import Firebase

@main
struct LoginViewDenemeApp: App {
    let persistenceController = PersistenceController.shared // Core Data
    
    init() {
        FirebaseApp.configure() // Firebase'i başlatıyoruz
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light) // 🔥 Uygulama sadece light modda çalışacak
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
