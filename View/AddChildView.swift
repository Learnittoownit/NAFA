import SwiftUI

struct AddChildView: View {
    @Binding var path: NavigationPath

    @State private var childName: String       = ""
    @State private var age: String             = ""
    @State private var grade: String           = ""
    @State private var allowanceAmount: String = ""
    @State private var selectedFrequency       = "Daily"
    @State private var selectedAvatar          = "🦁"

    let avatars = ["🦁", "🐺", "🦊", "🦋", "🐬"]
    let frequencies = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    OnboardingProgressBar(currentStep: 3)
                        .padding(.top, 20)

                    Spacer().frame(height: 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Child")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                        Text("Fill in your child's details")
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    // Avatar picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pick a character")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.nafNavy)
                            .padding(.horizontal, 24)

                        HStack(spacing: 12) {
                            ForEach(avatars, id: \.self) { avatar in
                                Button {
                                    selectedAvatar = avatar
                                } label: {
                                    Text(avatar)
                                        .font(.system(size: 28))
                                        .frame(width: 52, height: 52)
                                        .background(selectedAvatar == avatar
                                            ? Color.nafNavy.opacity(0.15)
                                            : Color.white)
                                        .cornerRadius(26)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 26)
                                                .stroke(selectedAvatar == avatar
                                                    ? Color.nafNavy : Color.clear,
                                                    lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer().frame(height: 24)

                    VStack(spacing: 20) {
                        NafField(label: "Child's name",
                                 placeholder: "lama",
                                 text: $childName)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading) {
                                NafField(label: "Age",
                                         placeholder: "7 – 12",
                                         text: $age,
                                         keyboardType: .numberPad)
                            }
                            VStack(alignment: .leading) {
                                NafField(label: "School Grade",
                                         placeholder: "Grade 3",
                                         text: $grade)
                            }
                        }

                        // Frequency picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allowance Frequency")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafNavy)

                            HStack(spacing: 8) {
                                ForEach(frequencies, id: \.self) { freq in
                                    Button {
                                        selectedFrequency = freq
                                    } label: {
                                        Text(freq)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedFrequency == freq
                                                ? .white : Color.nafNavy)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                            .background(selectedFrequency == freq
                                                ? Color.nafNavy : Color.white)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }

                        NafField(label: "Allowance Amount (SAR)",
                                 placeholder: "50",
                                 text: $allowanceAmount,
                                 keyboardType: .numberPad)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)

                    VStack(spacing: 12) {
                        Button {
                            path.append(OnboardingStep.myChildren)
                        } label: {
                            Text("Next child")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(childName.isEmpty
                                    ? Color.nafTextGray : Color.nafNavy)
                                .cornerRadius(27)
                        }
                        .disabled(childName.isEmpty)

                        Button {
                            path.append(OnboardingStep.myChildren)
                        } label: {
                            HStack(spacing: 4) {
                                Text("Skip")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.nafNavy)
                                Text("— Add more children later")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.nafTextGray)
                            }
                        }
                    }
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
}
