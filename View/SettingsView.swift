import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var parentVM: ParentViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showLogoutConfirm = false

    var body: some View {
        ZStack {
            Color(hex: "E8EDF2").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── HEADER ────────────────────────────
                Color(hex: "2D6DAB")
                    .frame(height: 120)
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Manage your preferences")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                    )

                ScrollView {
                    VStack(spacing: 14) {

                        // ── ACCOUNT SECTION ───────────────────
                        VStack(spacing: 0) {
                            SectionHeader(title: "ACCOUNT")

                            // Log out
                            SettingsRow(
                                icon: "arrow.right.square",
                                iconColor: Color(hex: "E05555"),
                                title: "Log out"
                            ) {
                                showLogoutConfirm = true
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)

                        // more sections coming soon
                        Text("More settings coming soon")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nafTextGray)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                Task { await authVM.logout() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Section Header
// ─────────────────────────────────────────────
struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .tracking(1)
            .foregroundColor(Color.nafTextGray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 4)
    }
}

// ─────────────────────────────────────────────
// MARK: - Settings Row
// ─────────────────────────────────────────────
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(iconColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color.nafTextGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
