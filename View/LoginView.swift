import SwiftUI

struct LoginView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email:    String = ""
    @State private var password: String = ""

    var canLogin: Bool {
        !email.isEmpty && password.count >= 8
    }

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Spacer().frame(height: 10)

                    // ── Logo + heading ─────────────
                    HStack(spacing: 5) {
                        Image("AppLogoFull")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(10)
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Nafaqati")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.nafNavy)
                            Text("نفقتي")
                                .font(.system(size: 20))
                                .foregroundColor(Color.nafTextGray)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome back!")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                        Text("Log in to continue your journey")
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 20)

                    // ── Form ───────────────────────
                    VStack(spacing: 20) {

                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafNavy)
                            TextField("your@email.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafNavy)
                            SecureField("Your password", text: $password)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)

                            // Forgot password link
                            HStack {
                                Spacer()
                                Button {
                                    path.append(OnboardingStep.forgotPassword(email: email))
                                } label: {
                                    Text("Forgot password?")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color.nafOrange)
                                }
                            }
                        }

                        // Error message
                        if let error = authVM.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13))
                                Text(error)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }

            // ── Bottom buttons — fixed ─────────
            VStack {
                Spacer()
                VStack(spacing: 14) {

                    // Login button
                    Button {
                        Task {
                            await authVM.login(
                                email: email,
                                password: password
                            )
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 27)
                                .fill(canLogin ? Color.nafNavy : Color.nafTextGray)
                                .frame(height: 54)
                            if authVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Log in")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(!canLogin || authVM.isLoading)
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.nafTextGray.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nafTextGray)
                        Rectangle()
                            .fill(Color.nafTextGray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Register link
                    Button {
                        path.append(OnboardingStep.roleSelection)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(Color.nafTextGray)
                            Text("Register")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafOrange)
                        }
                    }
                }
                .padding(.bottom, 40)
                .background(Color.nafBackground)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { path.removeLast() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.nafNavy)
                }
            }
        }
        .onAppear {
            authVM.errorMessage = nil
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────

#Preview {
    NavigationStack {
        LoginView(path: .constant(NavigationPath()))
            .environmentObject(AuthViewModel())
    }
}
