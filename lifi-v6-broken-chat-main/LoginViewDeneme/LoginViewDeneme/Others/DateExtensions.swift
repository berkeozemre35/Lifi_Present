//
//  DateExtensions.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 18.12.2024.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    func formattedDateValue() -> String {
        let date = self.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
