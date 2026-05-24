import SwiftUI

struct AllSetView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.nafLightCard)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.nafNavy)
                }

                Spacer().frame(height: 32)

                Group {
                    Text("You're all ")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.nafNavy)
                    + Text("set!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.nafOrange)
                }

                Spacer().frame(height: 12)

                Text("Children added successfully.\nYour financial literacy journey starts now.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.nafTextGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button {
                    // Now set isLoggedIn to go to dashboard
                    authVM.isLoggedIn = true
                } label: {
                    Text("Go to dashboard")
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
        .navigationBarHidden(true)
    }
}
