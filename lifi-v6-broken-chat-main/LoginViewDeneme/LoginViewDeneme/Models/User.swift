//
//  User.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 15.12.2024.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let surname: String
    let email: String
    let joined: TimeInterval
}
