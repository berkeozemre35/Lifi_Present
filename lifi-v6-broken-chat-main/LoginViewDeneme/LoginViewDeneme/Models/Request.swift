//
//  Request.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.04.2025.
//

import Foundation
import FirebaseCore


struct Request: Identifiable {
    let id: String
    let fromUserId: String
    let toUserId: String
    let eventId: String
    let status: String
    let timestamp: Timestamp
    let fromUserName: String
    let fromUserSurname: String
    let eventName: String
}
