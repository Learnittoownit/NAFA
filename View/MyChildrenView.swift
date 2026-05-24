import SwiftUI
import Supabase

struct MyChildrenView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var authVM: AuthViewModel

    @State private var children: [ChildProfile] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

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
                    Text("Your children have been added successfully")
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

                if isLoading {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity)
                    Spacer()

                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 32))
                            .foregroundColor(Color.nafTextGray)
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    Spacer()

                } else if children.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.2")
                            .font(.system(size: 32))
                            .foregroundColor(Color.nafTextGray)
                        Text("No children found")
                            .font(.system(size: 14))
                            .foregroundColor(Color.nafTextGray)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()

                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(children) { child in
                                ChildRowCard(child: child)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }

                Spacer()

                // ── Continue to AllSet ─────────────
                Button {
                    path.append(OnboardingStep.allSet)
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(children.isEmpty ? Color.nafTextGray : Color.nafNavy)
                        .cornerRadius(27)
                }
                .disabled(children.isEmpty)
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
        .task {
            await fetchChildren()
        }
    }

    // ── Fetch children from Supabase ───────
    private func fetchChildren() async {
        guard let parentId = authVM.currentUserId else { return }

        isLoading    = true
        errorMessage = nil

        do {
            let result: [ChildProfile] = try await supabase
                .from("child_profile")
                .select()
                .eq("parent_id", value: parentId.uuidString)
                .execute()
                .value

            children = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// ─────────────────────────────────────────────
// MARK: - Child Row Card
// ─────────────────────────────────────────────
struct ChildRowCard: View {
    let child: ChildProfile

    var body: some View {
        HStack(spacing: 16) {

            // ── Avatar ─────────────────────
            ZStack {
                Circle()
                    .fill(Color.nafLightCard)
                    .frame(width: 48, height: 48)
                if let avatar = child.avatarUrl, !avatar.isEmpty {
                    Text(avatar)
                        .font(.system(size: 26))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.nafTextGray)
                }
            }

            // ── Info ───────────────────────
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.nafNavy)
                Text("Age \(child.age)")
                    .font(.system(size: 13))
                    .foregroundColor(Color.nafTextGray)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }
}
