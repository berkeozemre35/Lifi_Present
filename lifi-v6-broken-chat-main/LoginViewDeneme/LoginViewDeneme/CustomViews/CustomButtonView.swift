//
//  CustomButtonView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 13.12.2024.
//

import SwiftUI

struct CustomButtonView: View {
    var buttonName: String
    var action: () -> Void // Aksiyon için closure ekledik

    var body: some View {
        Button(action: action) { // Butonun aksiyonunu dışarıdan alır
            Text(buttonName) // Butonun ismi
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .padding(.vertical)
                .padding(.horizontal, 59)
                .frame(width: UIScreen.main.bounds.width - 50)
                .background(.colorTema)
                .cornerRadius(10)
        }
    }
}

#Preview {
    CustomButtonView(buttonName: "Button") {
        print("Button pressed!")
    }
}
