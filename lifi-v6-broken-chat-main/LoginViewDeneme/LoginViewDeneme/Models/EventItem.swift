//
//  EventItem.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 18.12.2024.
//

import Foundation
import FirebaseFirestore


struct EventItem: Identifiable {
    var id: String
    var name: String
    var createdBy: String? // Kullanıcının UID'si
    var createdByName: String? // Kullanıcının adı
    var createdBySurname: String? // Kullanıcının soyadı
    var startDate: Date?
    var endDate: Date?
    var location: String?
    var createdAt: Date?
    var latitude: Double?     // 📍 Haritada pin için enlem
    var longitude: Double?    // 📍 Haritada pin için boylam
    var description: String?
}


