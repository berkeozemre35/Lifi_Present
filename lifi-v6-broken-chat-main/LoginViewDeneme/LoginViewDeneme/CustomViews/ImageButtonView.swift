//
//  ImageButtonView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 13.12.2024.
//

import SwiftUI

struct ImageButtonView: View {
    
    var iconName : String
    var text : String
    
    var body: some View {
        Button {
            // Buton aksiyonu
        } label: {
            HStack(spacing: 10) { // İkon ve metin arasındaki boşluk
                Image(iconName)
                    .padding(.leading, 10) // İkon için hafif bir kenar boşluğu
                Text(text)
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
                    .padding(.vertical)
                    .padding(.horizontal, 20)
            }
            .frame(width: UIScreen.main.bounds.width - 60) // Genişliği artırdık
            .background(.white)
            .cornerRadius(20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.black, lineWidth: 0.4)
        )
        
    }
}

#Preview {
    ImageButtonView(iconName: "AppleIcon", text: "Continue with Apple ")
}


 
