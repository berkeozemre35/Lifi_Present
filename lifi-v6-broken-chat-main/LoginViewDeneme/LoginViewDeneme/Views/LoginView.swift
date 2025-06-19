//
//  LoginView.swift
//  LoginViewDeneme
//
//  Created by Berke Özemre on 6.12.2024.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    @State private var remember: Bool = false // Bu değişken şu anda kullanılmıyor gibi görünüyor.
    @State private var isPasswordVisible: Bool = false // Bu değişken de doğrudan bu view'da kullanılmıyor, muhtemelen PasswordFieldWithToggleView içinde.

    var body: some View {
        NavigationStack {
            VStack {
                // App Logo
                Image("Lifi2") // Bu görselin projenizde olduğundan emin olun.
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.top, 40)

                

                Spacer().frame(height: 12)

                // Email Alanı
                VStack(alignment: .leading, spacing: 12) {
                    // TitleTextFieldView'ın doğru çalıştığından ve viewModel.email'i güncellediğinden emin olun.
                    TitleTextFieldView(title: "Email", tfPlaceHolder: "Enter your email", textFieldInput: $viewModel.email)
                }

                Spacer().frame(height: 12)

                // Şifre Alanı
                VStack(alignment: .leading, spacing: 12) {
                    Text("Password") // Bu Text için padding(.horizontal) vardı, TitleTextFieldView'a benzer bir yapı düşünülebilir.
                        .padding(.horizontal) // Eğer TitleTextFieldView başlığı kendi içinde yönetiyorsa bu Text'e gerek olmayabilir.
                    // PasswordFieldWithToggleView'ın doğru çalıştığından ve viewModel.password'u güncellediğinden emin olun.
                    PasswordFieldWithToggleView(password: $viewModel.password, tfPlaceHolder: "Enter your password")
                }

                Spacer().frame(height: 4)

                // Şifremi Unuttum Butonu
                HStack {
                    Spacer()
                    Button {
                        print("Forget Password tapped")
                        // Şifremi unuttum işlevselliği buraya eklenecek.
                    } label: {
                        Text("Forgot Password ?")
                            .foregroundStyle(.colorTema) // .colorTema'nın projenizde tanımlı olduğundan emin olun.
                            .padding(.top)
                            .padding(.trailing)
                    }
                }

                Spacer().frame(height: 15)

                // Giriş Butonu
                // CustomButtonView'ın action closure'ının viewModel.login()'i çağırdığından emin olun.
                CustomButtonView(buttonName: "Log In") {
                    print("Log In button tapped. Calling viewModel.login()")
                    viewModel.login()
                }

                Divider()
                    .frame(height: 1.5)
                    .background(Color.gray) // .gray yerine Color.gray kullanmak daha doğru.
                    .padding(.top , 35)
                    .padding(.horizontal , 10)

                Spacer().frame(height: 35)

                // Sosyal Medya Giriş Butonları
                // ImageButtonView'ların işlevsellikleri henüz eklenmemiş gibi duruyor.
                ImageButtonView(iconName: "AppleIcon", text: "Continue with Apple")
                Spacer().frame(height: 15)
                ImageButtonView(iconName: "GoogleIcon", text: "Continue with Google")

                Spacer().frame(height: 35)

                // Kayıt Olma Yönlendirmesi
                HStack {
                    Text("Don't have an account ?")
                        .font(.system(size: 18))
                    NavigationLink(destination: RegisterView()) { // RegisterView'ın projenizde olduğundan emin olun.
                        Text("Sign Up")
                            .font(.system(size: 18))
                            .foregroundStyle(.colorTema)
                    }
                }
                // Hata ayıklama için print ifadesi eklendi.
                // Bu print, View'ın her render olduğunda ve showAlert/errorMessage değiştiğinde konsolda görünecektir.
                let _ = print("LoginView body rendering. showAlert: \(viewModel.showAlert), errorMessage: '\(viewModel.errorMessage)'")
            }
            // .alert modifier'ı ana VStack'e taşındı.
            .alert("Login Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    // OK butonuna basıldığında showAlert otomatik olarak false olur.
                    // Ek bir işlem gerekirse buraya eklenebilir.
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            // .padding() ve .ignoresSafeArea() gibi modifier'lar gerekirse buraya eklenebilir.
        }
    }
}

// TitleTextFieldView, PasswordFieldWithToggleView, CustomButtonView, ImageButtonView ve RegisterView
// tanımlamalarının projenizde olması gerekmektedir.
// Ayrıca "Li-Fi", "AppleIcon", "GoogleIcon" assetlerinin ve .colorTema'nın projenizde tanımlı olması gerekir.




/*
 #Preview {
     LoginView()
 }
 */





