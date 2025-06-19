//
//  SignUp.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.12.2024.
//

import SwiftUI

struct RegisterView: View {
    
    
    @StateObject var viewModel = RegisterViewViewModel()
    
    var body: some View {
        VStack {
            // Header
            Text("Create an account")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
                .frame(height: 40)
            
            // Hata mesajını göstermek için ekledik
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                .foregroundColor(.red)
                .padding(.horizontal)
            }
            
            VStack (alignment: .leading , spacing: 12) {
                TitleTextFieldView(title: "Name", tfPlaceHolder: "Enter your name", textFieldInput: $viewModel.name)
                TitleTextFieldView(title: "Surname", tfPlaceHolder: "Enter your surname", textFieldInput: $viewModel.surname)
                TitleTextFieldView(title: "Email", tfPlaceHolder: "Enter your email", textFieldInput: $viewModel.email)
            }
            
            Spacer()
                .frame(height: 12)
            
            VStack (alignment: .leading , spacing: 12) {
                Text("Password")
                    .padding(.horizontal)
                
                PasswordFieldWithToggleView(password: $viewModel.password, tfPlaceHolder: "Enter your password")
                PasswordFieldWithToggleView(password: $viewModel.confirmPassword, tfPlaceHolder: "Confirm your password")
                 
                
            }//Password TextField Bitişi
            Spacer()
                .frame(height: 25)
            
            //
            CustomButtonView(buttonName: "Sign up") {
                viewModel.registerUser() // Giriş işlemini gerçekleştir
            }
            //CustomButtonView(buttonName: "Sign Up" )
            
            Divider()
                .frame(height: 1.5)
                .background(.gray)
                .padding(.top , 35 )
                .padding(.leading , 10 )
                .padding(.trailing , 10)
            
            Spacer()
                .frame(height: 35)
            
            ImageButtonView(iconName: "AppleIcon", text: "Sign up with Apple")
            
            Spacer()
                .frame(height: 15)
            
            ImageButtonView(iconName: "GoogleIcon", text: "Sign up with Google")
        }
    }
}

#Preview {
    RegisterView()
}


