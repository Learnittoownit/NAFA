import SwiftUI

struct ChildPINView: View {
    @Binding var path: NavigationPath

    @State private var pin: [String] = ["", "", "", ""]
    @State private var isConfirming  = false
    @State private var confirmPin: [String] = ["", "", "", ""]
    @FocusState private var focusedIndex: Int?

    var currentPin: [String] { isConfirming ? confirmPin : pin }

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.nafLightCard)
                        .frame(width: 100, height: 100)
                    Text("🦁")
                        .font(.system(size: 50))
                }

                Spacer().frame(height: 32)

                Text("Your secret PIN is ready!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.nafNavy)
                    .multilineTextAlignment(.center)

                Text(isConfirming
                     ? "Enter it again to confirm"
                     : "This is your personal PIN — only you should know it!")
                    .font(.system(size: 14))
                    .foregroundColor(Color.nafTextGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

                Spacer().frame(height: 40)

                // 4 PIN boxes
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        SecureField("", text: isConfirming
                            ? $confirmPin[index]
                            : $pin[index])
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold))
                            .frame(width: 64, height: 64)
                            .background(Color.white)
                            .cornerRadius(12)
                            .focused($focusedIndex, equals: index)
                            .onChange(of: isConfirming
                                ? confirmPin[index]
                                : pin[index]) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                let limited  = String(filtered.prefix(1))
                                if isConfirming {
                                    confirmPin[index] = limited
                                } else {
                                    pin[index] = limited
                                }
                                if limited.count == 1 && index < 3 {
                                    focusedIndex = index + 1
                                }
                            }
                    }
                }

                Spacer()

                Button {
                    if !isConfirming {
                        isConfirming = true
                        focusedIndex = 0
                    } else {
                        path.append(OnboardingStep.allSet)
                    }
                } label: {
                    Text("Confirm PIN")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.nafNavy)
                        .cornerRadius(27)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
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
        .onAppear { focusedIndex = 0 }
    }
}
