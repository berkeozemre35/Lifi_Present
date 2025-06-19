//
//  PasswordFieldWithToggleView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 13.12.2024.
//

import SwiftUI

struct PasswordFieldWithToggleView: View {
    
    @Binding var password: String
    @State private var isPasswordVisible: Bool = false
    
    var tfPlaceHolder : String
    var body: some View {
        
        VStack{
        
            ZStack {
                if isPasswordVisible {
                    TextField(tfPlaceHolder, text: $password) // Şifreyi göster
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.black.opacity(1))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never) // iOS 15 ve sonrası için
                            .disableAutocorrection(true) // Otomatik düzeltmeyi de kapatmak isterseniz
                } else {
                    SecureField(tfPlaceHolder, text: $password) // Şifreyi gizle
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.black.opacity(1))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never) // iOS 15 ve sonrası için
                            .disableAutocorrection(true) // Otomatik düzeltmeyi de kapatmak isterseniz
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }.padding(.leading,300)
            }
            .padding(.horizontal)
            
        }
        
    }
}

#Preview {
    PasswordFieldWithToggleView(password:.constant(""), tfPlaceHolder:"")
}
