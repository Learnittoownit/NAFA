import SwiftUI

struct MyChildrenView: View {
    @Binding var path: NavigationPath

    let mockChildren = [
        ("🦁", "lama", "Grade 3 · 45 SAR"),
        ("🦊", "lama", "Grade 3 · 45 SAR"),
        ("🐬", "lama", "Grade 3 · 45 SAR"),
    ]

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                OnboardingProgressBar(currentStep: 4)
                    .padding(.top, 20)

                Spacer().frame(height: 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text("My Children")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.nafNavy)
                    Text("Tap any child to manage their PIN")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nafTextGray)
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                Text("Registered Children")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.nafOrange)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 16)

                VStack(spacing: 12) {
                    ForEach(mockChildren, id: \.1) { child in
                        Button {
                            path.append(OnboardingStep.childPIN)
                        } label: {
                            HStack(spacing: 16) {
                                Text(child.0)
                                    .font(.system(size: 28))
                                    .frame(width: 48, height: 48)
                                    .background(Color.nafLightCard)
                                    .cornerRadius(24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(child.1)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.nafNavy)
                                    Text(child.2)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.nafTextGray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.nafTextGray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
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
}
