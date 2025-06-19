//
//  ChatMessage.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.04.2025.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let fromUserId: String
    let content: String
    let timestamp: Date
}
