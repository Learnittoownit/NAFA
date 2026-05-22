import SwiftUI
import Supabase

struct ForgotPasswordView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email: String        = ""
    @State private var emailSent: Bool      = false
    @State private var isLoading: Bool      = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Spacer().frame(height: 60)

                if emailSent {

                    // ── Success state ──────────────
                    VStack(spacing: 0) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Color.nafNavy.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.nafNavy)
                        }

                        Spacer().frame(height: 32)

                        Text("Check your inbox!")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        Spacer().frame(height: 12)

                        Text("We sent a password reset link to\n\(email)")
                            .font(.system(size: 15))
                            .foregroundColor(Color.nafTextGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity)

                        Spacer().frame(height: 8)

                        Text("Check your spam folder if you don't see it.")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nafTextGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .frame(maxWidth: .infinity)

                        Spacer()

                        VStack(spacing: 14) {
                            Button {
                                path.removeLast()
                            } label: {
                                Text("Back to login")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color.nafNavy)
                                    .cornerRadius(27)
                            }
                            .padding(.horizontal, 24)

                            Button {
                                Task { await sendReset() }
                            } label: {
                                Text("Resend email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.nafOrange)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .frame(maxWidth: .infinity)

                } else {

                    // ── Input state ────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Forgot password?")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                        Text("Enter your email and we'll send you a reset link.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)

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

                        if let error = errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13))
                                Text(error)
                                    .font(.system(size: 13))
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Button {
                        Task { await sendReset() }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 27)
                                .fill(email.isEmpty
                                      ? Color.nafTextGray
                                      : Color.nafNavy)
                                .frame(height: 54)
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Send reset link")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(email.isEmpty || isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
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
    }

    // ── Send reset email via Supabase ──────
    func sendReset() async {
        isLoading    = true
        errorMessage = nil
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            emailSent = true
        } catch {
            let message = error.localizedDescription
            if message.contains("rate limit") {
                errorMessage = "Too many attempts. Please wait a few minutes and try again."
            } else if message.contains("not found") || message.contains("User not found") {
                errorMessage = "No account found with this email. Please register first."
            } else {
                errorMessage = "No account found with this email. Please register first."
            }
        }
        isLoading = false
    }
}
