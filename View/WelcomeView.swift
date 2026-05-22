import SwiftUI

struct WelcomeView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.nafBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Top logo row ───────────────
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.nafNavy)
                                .frame(width: 44, height: 44)
                            Text("🪙")
                                .font(.system(size: 22))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Nafaqati")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color.nafNavy)
                            Text("نفقاتي")
                                .font(.system(size: 12))
                                .foregroundColor(Color.nafTextGray)
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 48)

                    // ── Headline ───────────────────
                    Group {
                        Text("Turn allowance into ")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafNavy)
                        + Text("a skill that lasts a lifetime.")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.nafblue)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 12)

                    Text("Financial literacy for Saudi children (7–12) and their parents. Saving, smart spending, and goal-setting — made into a daily habit.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nafTextGray)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 36)

                    // ── Section label ──────────────
                    Text("WHAT HAPPENS AFTER YOU START")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.nafblue)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 16)

                    // ── Timeline cards ─────────────
                    VStack(spacing: 12) {
                        TimelineCard(
                            badge: "week 1",
                            text: "Your child makes their first saving decision — on their own."
                        )
                        TimelineCard(
                            badge: "week 2",
                            text: "They start setting goals without being asked. Spending slows down naturally."
                        )
                        TimelineCard(
                            badge: "month 2",
                            text: "They develop a savings habit most Saudi adults don't have."
                        )
                    }
                    .padding(.horizontal, 24)

                    // Extra space so content
                    // doesn't hide behind bottom buttons
                    Spacer().frame(height: 180)
                }
            }

            // ── Bottom buttons — fixed ─────────
            VStack {
                Spacer()

                VStack(spacing: 12) {

                    // Main CTA
                    Button {
                        path.append(OnboardingStep.roleSelection)
                    } label: {
                        HStack {
                            Text("Start Your child's Journey")
                                .font(.system(size: 16, weight: .semibold))
                            Text("→")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.nafNavy)
                        .cornerRadius(27)
                    }
                    .padding(.horizontal, 24)

                    // Already have account
                    Button {
                        path.append(OnboardingStep.login)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(Color.nafTextGray)
                            Text("Log in")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.nafblue)
                        }
                    }

                    // Trusted label
                    (
                        Text("Trusted by ")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nafTextGray)
                        + Text("Saudi families")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.nafblue)
                    )
                }
                .padding(.bottom, 40)
                .padding(.top, 16)
                .background(Color.nafBackground)
            }
        }
        .navigationBarHidden(true)
    }
}

// ── Timeline card component ──────────────
struct TimelineCard: View {
    let badge: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Text(badge)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.nafNavy)
                .cornerRadius(20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color.nafNavy)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.nafLightCard)
        .cornerRadius(16)
    }
}
