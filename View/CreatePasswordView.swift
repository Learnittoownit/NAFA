import SwiftUI

struct CreatePasswordView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    let name: String
    let email: String

    @State private var password: String        = ""
    @State private var confirmPassword: String = ""

    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var passwordTooShort: Bool {
        !password.isEmpty && password.count < 8
    }

    var canContinue: Bool {
        passwordsMatch && password.count >= 8
    }

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    OnboardingProgressBar(currentStep: 3)
                        .padding(.top, 20)

                    Spacer().frame(height: 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create a password")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                        Text("Keep your account safe")
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 36)

                    VStack(spacing: 20) {

                        // ── Password field ─────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafNavy)

                            SecureField("Min 8 characters", text: $password)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(passwordTooShort
                                            ? Color.red.opacity(0.6)
                                            : Color.clear,
                                                lineWidth: 1.5)
                                )

                            if passwordTooShort {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Password must be at least 8 characters")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.red)
                            }
                        }

                        // ── Confirm password field ─────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafNavy)

                            SecureField("Repeat your password", text: $confirmPassword)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            !confirmPassword.isEmpty && !passwordsMatch
                                            ? Color.red.opacity(0.6)
                                            : Color.clear,
                                            lineWidth: 1.5)
                                )

                            if !confirmPassword.isEmpty && !passwordsMatch {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text("Passwords do not match")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.red)
                            }
                        }

                        // ── Password strength indicator ─
                        if !password.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password strength")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.nafTextGray)

                                HStack(spacing: 4) {
                                    ForEach(0..<4, id: \.self) { index in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(strengthColor(for: index))
                                            .frame(height: 4)
                                    }
                                }

                                Text(strengthLabel)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(strengthColor(for: 0))
                            }
                        }

                        // ── Error from Supabase ─────────
                        if let error = authVM.errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 13))
                                    Text(error)
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                if error.contains("already exists") {
                                    Button {
                                        path.append(OnboardingStep.login)
                                    } label: {
                                        Text("Log in instead →")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color.nafOrange)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }

            // ── Continue button fixed at bottom ─
            VStack {
                Spacer()
                Button {
                    Task {
                        await authVM.register(
                            name: name,
                            email: email,
                            password: password
                        )
                        if authVM.isLoggedIn {
                            path.append(OnboardingStep.addChild)
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 27)
                            .fill(canContinue ? Color.nafNavy : Color.nafTextGray)
                            .frame(height: 54)
                        if authVM.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(!canContinue || authVM.isLoading)
                .padding(.horizontal, 24)
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

    // ── Password strength logic ──────────────
    var strengthScore: Int {
        var score = 0
        if password.count >= 8  { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.contains(where: { $0.isNumber })               { score += 1 }
        if password.contains(where: { "!@#$%^&*".contains($0) })   { score += 1 }
        return score
    }

    var strengthLabel: String {
        switch strengthScore {
        case 0, 1: return "Weak"
        case 2:    return "Fair"
        case 3:    return "Good"
        default:   return "Strong"
        }
    }

    func strengthColor(for index: Int) -> Color {
        let filled = index < strengthScore
        switch strengthScore {
        case 0, 1: return filled ? .red         : Color.nafLightCard
        case 2:    return filled ? .orange      : Color.nafLightCard
        case 3:    return filled ? .yellow      : Color.nafLightCard
        default:   return filled ? Color.green  : Color.nafLightCard
        }
    }
}
