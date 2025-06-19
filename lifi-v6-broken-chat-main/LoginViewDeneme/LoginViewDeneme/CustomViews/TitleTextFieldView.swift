//
//  TitleTextField.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 13.12.2024.
//

import SwiftUI

struct TitleTextFieldView: View {
    
    var title : String
    var tfPlaceHolder : String
    @Binding var textFieldInput: String
    
    var body: some View {
        
            Text(title)
                .padding(.horizontal)
            TextField(tfPlaceHolder, text:$textFieldInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.black.opacity(1))
                .cornerRadius(10)
                .padding(.horizontal)
                .textInputAutocapitalization(.never) // iOS 15 ve sonrası için
                .disableAutocorrection(true) // Otomatik düzeltmeyi de kapatmak isterseniz
                    
    }
}

#Preview {
    TitleTextFieldView(title: "Title", tfPlaceHolder: "PlaceHolder", textFieldInput: .constant(""))
}
