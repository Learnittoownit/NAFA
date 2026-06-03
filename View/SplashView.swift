import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // App icon circle
                ZStack {
                    Circle()
                        .fill(Color.nafNavy)
                        .frame(width: 100, height: 100)
                    Text("🪙")
                        .font(.system(size: 48))
                }

                // App name
                VStack(spacing: 4) {
                    Text("Nafaqati")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.nafNavy)
                    Text("نفقاتي")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.nafNavy)
                }

                Spacer()

                Text("Trusted by Saudi families")
                    .font(.system(size: 14))
                    .foregroundColor(Color.nafTextGray)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Auto-advance after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
