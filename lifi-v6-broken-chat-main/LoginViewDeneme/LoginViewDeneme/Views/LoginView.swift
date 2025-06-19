import SwiftUI
import FirebaseAuth
import FirebaseAnalytics

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    @State private var remember: Bool = false
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // App Logo
                Image("Lifi2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.top, 40)

                Spacer().frame(height: 12)

                // Email Field
                VStack(alignment: .leading, spacing: 12) {
                    TitleTextFieldView(title: "Email", tfPlaceHolder: "Enter your email", textFieldInput: $viewModel.email)
                }

                Spacer().frame(height: 12)

                // Password Field
                VStack(alignment: .leading, spacing: 12) {
                    Text("Password")
                        .padding(.horizontal)
                    PasswordFieldWithToggleView(password: $viewModel.password, tfPlaceHolder: "Enter your password")
                }

                Spacer().frame(height: 4)

                // Forgot Password
                HStack {
                    Spacer()
                    Button {
                        print("Forget Password tapped")
                    } label: {
                        Text("Forgot Password ?")
                            .foregroundStyle(.colorTema)
                            .padding(.top)
                            .padding(.trailing)
                    }
                }

                Spacer().frame(height: 15)

                // Log In Button
                CustomButtonView(buttonName: "Log In") {
                    print("Log In button tapped. Calling viewModel.login()")
                    Analytics.logEvent("login_button_tapped", parameters: [
                        "button": "Log In"
                    ])
                    viewModel.login()
                }

                Divider()
                    .frame(height: 1.5)
                    .background(Color.gray)
                    .padding(.top, 35)
                    .padding(.horizontal, 10)

                Spacer().frame(height: 35)

                // Social Logins
                ImageButtonView(iconName: "AppleIcon", text: "Continue with Apple")
                Spacer().frame(height: 15)
                ImageButtonView(iconName: "GoogleIcon", text: "Continue with Google")

                Spacer().frame(height: 35)

                // Sign Up
                HStack {
                    Text("Don't have an account ?")
                        .font(.system(size: 18))
                    NavigationLink(destination: RegisterView()) {
                        Text("Sign Up")
                            .font(.system(size: 18))
                            .foregroundStyle(.colorTema)
                    }
                }

                let _ = print("LoginView body rendering. showAlert: \(viewModel.showAlert), errorMessage: '\(viewModel.errorMessage)'")
            }
            .onAppear {
                Analytics.logEvent("login_view_opened", parameters: [
                    "screen": "LoginView"
                ])
            }
            .alert("Login Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}





