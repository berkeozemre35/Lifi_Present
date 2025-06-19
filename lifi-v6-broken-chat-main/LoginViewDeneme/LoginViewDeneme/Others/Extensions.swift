//
//  Extensions.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 15.12.2024.
//

import Foundation

extension Encodable {
    
    func asDictictionary() -> [String:Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            return json ?? [:]
        } catch {
            return [:]
        }
        
    }
    
}
