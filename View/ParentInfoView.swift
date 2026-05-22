import SwiftUI

struct ParentInfoView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    @State private var fullName: String      = ""
    @State private var email: String         = ""
    @State private var numberOfChildren: Int = 1
    @State private var showChildrenPicker    = false

    // ── Validation ───────────────────────
    var nameError: String? {
        if fullName.isEmpty { return nil }
        if fullName.contains(where: { $0.isNumber }) {
            return "Name should not contain numbers"
        }
        if fullName.count < 2 { return "Name is too short" }
        return nil
    }

    var emailError: String? {
        if email.isEmpty { return nil }
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let valid = email.range(of: pattern, options: .regularExpression) != nil
        if !valid { return "Please enter a valid email address" }
        return nil
    }

    var canContinue: Bool {
        !fullName.isEmpty && !email.isEmpty &&
        nameError == nil && emailError == nil
    }

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // ── Progress bar — sits high ───
                OnboardingProgressBar(currentStep: 2)
                    .padding(.top, 20)

                Spacer().frame(height: 28)

                // ── Title ──────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your information")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color.nafNavy)
                    Text("Tell us a bit about yourself")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color.nafTextGray)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 28)

                // ── Form ───────────────────────
                VStack(spacing: 18) {

                    // Full name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full name")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.nafNavy)

                        TextField("", text: $fullName)
                            .font(.system(size: 15, design: .rounded))
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        nameError != nil
                                        ? Color.red.opacity(0.6)
                                        : Color.clear,
                                        lineWidth: 1.5)
                            )
                            .onChange(of: fullName) { newValue in
                                let filtered = newValue.filter { !$0.isNumber }
                                if filtered != newValue { fullName = filtered }
                            }

                        if let error = nameError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.system(size: 12, design: .rounded))
                            }
                            .foregroundColor(.red)
                        }
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.nafNavy)

                        TextField("", text: $email)
                            .font(.system(size: 15, design: .rounded))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        emailError != nil
                                        ? Color.red.opacity(0.6)
                                        : Color.clear,
                                        lineWidth: 1.5)
                            )

                        if let error = emailError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.system(size: 12, design: .rounded))
                            }
                            .foregroundColor(.red)
                        }
                    }

                    // Number of children
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of children")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.nafNavy)

                        Button {
                            showChildrenPicker = true
                        } label: {
                            HStack {
                                Text("\(numberOfChildren) \(numberOfChildren == 1 ? "child" : "children")")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(Color.nafNavy)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.nafTextGray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }

                        Text("Maximum 10 children per account")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Color.nafTextGray)
                    }

                    Text("We'll walk you through adding their profiles in the next step.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color.nafTextGray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)

                Spacer()

                // ── Continue button ────────────
                Button {
                    path.append(OnboardingStep.createPassword(
                        name: fullName,
                        email: email
                    ))
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(canContinue ? Color.nafNavy : Color.nafTextGray)
                        .cornerRadius(27)
                }
                .disabled(!canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        // ── Children roller sheet ──────────
        .sheet(isPresented: $showChildrenPicker) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.nafTextGray.opacity(0.4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Text("Number of children")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.nafNavy)
                    .padding(.bottom, 8)

                Divider()

                Picker("Children", selection: $numberOfChildren) {
                    ForEach(1...10, id: \.self) { num in
                        Text("\(num) \(num == 1 ? "child" : "children")")
                            .font(.system(size: 15, design: .rounded))
                            .tag(num)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)

                Button {
                    showChildrenPicker = false
                } label: {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.nafNavy)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 8)
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { path.removeLast() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(.system(size: 15, design: .rounded))
                    }
                    .foregroundColor(Color.nafNavy)
                }
            }
        }
    }
}
