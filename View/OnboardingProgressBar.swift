import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int = 4

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...totalSteps, id: \.self) { step in
                ZStack {
                    Circle()
                        .fill(step <= currentStep
                              ? Color.nafOrange
                              : Color.nafLightCard)
                        .frame(width: 28, height: 28)
                    Text("\(step)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(step <= currentStep
                                         ? .white
                                         : Color.nafTextGray)
                }

                if step < totalSteps {
                    Rectangle()
                        .fill(step < currentStep
                              ? Color.nafOrange
                              : Color.nafLightCard)
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
