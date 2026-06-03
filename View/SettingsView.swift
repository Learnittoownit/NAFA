import SwiftUI
import Supabase

// ═══════════════════════════════════════════════
// MARK: - SettingsView (Parent)
// ═══════════════════════════════════════════════

struct SettingsView: View {
    @EnvironmentObject var parentVM: ParentViewModel
    @EnvironmentObject var authVM:   AuthViewModel

    // ── Navigation
    @State private var showProfileEdit      = false
    @State private var selectedChildProfile: ChildProfile? = nil
    @State private var showAddChild         = false
    @State private var showDeleteAccount    = false
    @State private var showLogoutSheet      = false

    // ── Data
    @State private var children: [ChildProfile] = []
    @State private var isLoadingChildren        = false

    // ── Notification toggles (local state — extend with push later)
    @State private var notifAll         = true
    @State private var notifChildReq    = true
    @State private var notifGoalDone    = true
    @State private var notifAllowance   = true

    var body: some View {
        ZStack(alignment: .top) {

            // ── Background (matches all other parent tabs)
            VStack(spacing: 0) {
                Color(hex: "2D6DAB")
                    .frame(height: UIScreen.main.bounds.height * 0.38)
                Color(hex: "E8EDF2")
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Blue header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Manage your preferences")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 24)

                // ── Scrollable body
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {

                        // ─── MY PROFILE ───────────────────────
                        SettingsSectionCard {
                            SectionHeader(title: "MY PROFILE")
                            Button {
                                showProfileEdit = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "DDE8F4"))
                                            .frame(width: 46, height: 46)
                                        Text(parentVM.parentAvatar.isEmpty ? "🧑🏽" : parentVM.parentAvatar)
                                            .font(.system(size: 26))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(parentVM.parentName.isEmpty
                                             ? "My Profile"
                                             : parentVM.parentName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Color(hex: "1B3A6B"))
                                        Text("Edit name, photo")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.nafTextGray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.nafTextGray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }

                        // ─── CHILDREN ─────────────────────────
                        SettingsSectionCard {
                            HStack {
                                SectionHeader(title: "CHILDREN")
                                Spacer()
                                Button {
                                    showAddChild = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 11, weight: .bold))
                                        Text("Add")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(Color(hex: "2D6DAB"))
                                    .padding(.trailing, 16)
                                    .padding(.top, 14)
                                }
                            }

                            if isLoadingChildren {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            } else if children.isEmpty {
                                Text("No children added yet")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.nafTextGray)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 14)
                            } else {
                                ForEach(Array(children.enumerated()), id: \.element.id) { idx, child in
                                    if idx > 0 { Divider().padding(.horizontal, 16) }
                                    Button {
                                        selectedChildProfile = child
                                    } label: {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                Circle()
                                                    .fill(avatarBg(for: idx))
                                                    .frame(width: 42, height: 42)
                                                if let avatar = child.avatarUrl, !avatar.isEmpty {
                                                    Text(avatar)
                                                        .font(.system(size: 22))
                                                } else {
                                                    Text(String(child.name.prefix(1)))
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            Text(child.name)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(Color(hex: "1B3A6B"))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color.nafTextGray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 11)
                                    }
                                }
                            }
                        }

                        // ─── NOTIFICATIONS ────────────────────
                        SettingsSectionCard {
                            SectionHeader(title: "NOTIFICATIONS")

                            NotifToggleRow(
                                title: "All notifications",
                                subtitle: "Master switch",
                                isOn: $notifAll)

                            Divider().padding(.horizontal, 16)

                            NotifToggleRow(
                                title: "Child requests",
                                subtitle: "When child sends a request",
                                isOn: $notifChildReq)
                                .disabled(!notifAll)
                                .opacity(notifAll ? 1 : 0.45)

                            Divider().padding(.horizontal, 16)

                            NotifToggleRow(
                                title: "Goal completed",
                                subtitle: "When child reaches their goal",
                                isOn: $notifGoalDone)
                                .disabled(!notifAll)
                                .opacity(notifAll ? 1 : 0.45)

                            Divider().padding(.horizontal, 16)

                            NotifToggleRow(
                                title: "Allowance reminder",
                                subtitle: "When scheduled allowance is due",
                                isOn: $notifAllowance)
                                .disabled(!notifAll)
                                .opacity(notifAll ? 1 : 0.45)
                        }

                        // ─── ACCOUNT ──────────────────────────
                        SettingsSectionCard {
                            SectionHeader(title: "ACCOUNT")

                            Button {
                                showLogoutSheet = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "2D6DAB").opacity(0.10))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "2D6DAB"))
                                    }
                                    Text("Log out")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(hex: "1B3A6B"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.nafTextGray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }

                            Divider().padding(.horizontal, 16)

                            Button {
                                showDeleteAccount = true
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "E05555").opacity(0.10))
                                            .frame(width: 34, height: 34)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "E05555"))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Delete account")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(hex: "E05555"))
                                        Text("Permanently delete everything")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "E05555").opacity(0.7))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.nafTextGray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }

                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color(hex: "E8EDF2")
                            .cornerRadius(50, corners: [.topLeft, .topRight])
                    )
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(hex: "E8EDF2"))
        .task { await fetchChildren() }

        // ── fullScreenCover: Add child (reuses onboarding AddChildView)
        .fullScreenCover(isPresented: $showAddChild) {
            AddChildFromSettingsView {
                await fetchChildren()
            }
            .environmentObject(authVM)
        }

        // ── Sheet: My Profile
        .sheet(isPresented: $showProfileEdit) {
            ParentProfileEditSheet(parentVM: parentVM, authVM: authVM)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }

        // ── Sheet: Child profile
        .sheet(item: $selectedChildProfile) { child in
            ChildProfileEditSheet(
                child: child,
                onSaved: { await fetchChildren() },
                onRemoved: { await fetchChildren() }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }

        // ── Full-screen: Delete account
        .fullScreenCover(isPresented: $showDeleteAccount) {
            DeleteAccountView(authVM: authVM, onDeleted: {
                // authVM.isLoggedIn = false will trigger root nav
            })
        }

        // ── Log out modal
        .overlay {
            if showLogoutSheet {
                LogoutOverlay(
                    onLogout: {
                        showLogoutSheet = false
                        Task { await authVM.logout() }
                    },
                    onCancel: { showLogoutSheet = false }
                )
            }
        }
    }

    // ── Fetch children
    private func fetchChildren() async {
        guard let parentId = authVM.currentUserId else { return }
        isLoadingChildren = true
        do {
            let result: [ChildProfile] = try await supabase
                .from("child_profile")
                .select()
                .eq("parent_id", value: parentId.uuidString)
                .execute()
                .value
            await MainActor.run { children = result }
        } catch {
            print("❌ SettingsView fetchChildren: \(error)")
        }
        await MainActor.run { isLoadingChildren = false }
    }

    private func avatarBg(for index: Int) -> Color {
        let colors = [
            Color(hex: "C8DCEF"),
            Color(hex: "B6D4C4"),
            Color(hex: "F4C0B8")
        ]
        return colors[index % colors.count]
    }
}

// ═══════════════════════════════════════════════
// MARK: - Settings Section Card wrapper
// ═══════════════════════════════════════════════

struct SettingsSectionCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .background(Color.white)
        .cornerRadius(16)
    }
}

// ═══════════════════════════════════════════════
// MARK: - Notification Toggle Row
// ═══════════════════════════════════════════════

struct NotifToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "1B3A6B"))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.nafTextGray)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "2D6DAB"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ═══════════════════════════════════════════════
// MARK: - Parent Profile Edit Sheet
// ═══════════════════════════════════════════════

struct ParentProfileEditSheet: View {
    @ObservedObject var parentVM: ParentViewModel
    @ObservedObject var authVM:   AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var nameText     = ""
    @State private var selectedEmoji = ""
    @State private var isSaving     = false
    @State private var nameError    = ""

    // All human emojis in every skin tone
    let parentEmojis: [String] = [
        "👩🏻","👩🏼","👩🏽","👩🏾","👩🏿",
        "👨🏻","👨🏼","👨🏽","👨🏾","👨🏿",
        "🧑🏻","🧑🏼","🧑🏽","🧑🏾","🧑🏿"
    ]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        VStack(spacing: 0) {

            // ── Drag handle
            Capsule()
                .fill(Color.nafTextGray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // ── Title
            Text("My Profile")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "1B3A6B"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            Divider()

            // ── Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Avatar preview — centred, no clipping
                    ZStack {
                        Circle()
                            .fill(Color(hex: "DDE8F4"))
                            .frame(width: 90, height: 90)
                        Text(selectedEmoji.isEmpty ? "🧑🏽" : selectedEmoji)
                            .font(.system(size: 52))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    // ── Emoji grid
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CHOOSE YOUR LOOK")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(Color.nafTextGray)
                            .padding(.horizontal, 24)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(parentEmojis, id: \.self) { emoji in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        selectedEmoji = emoji
                                    }
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 56, height: 56)
                                        .background(
                                            selectedEmoji == emoji
                                            ? Color(hex: "DDE8F4")
                                            : Color(hex: "F5F7FA")
                                        )
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    selectedEmoji == emoji
                                                    ? Color(hex: "2D6DAB")
                                                    : Color.clear,
                                                    lineWidth: 2.5)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    // ── Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                            .foregroundColor(Color.nafTextGray)

                        TextField("Your name", text: $nameText)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "1B3A6B"))
                            .padding(14)
                            .background(Color(hex: "F5F7FA"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        nameError.isEmpty
                                        ? Color.nafLightCard
                                        : Color(hex: "E05555"),
                                        lineWidth: 1)
                            )
                            .onChange(of: nameText) { _, _ in nameError = "" }

                        if !nameError.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(nameError)
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(Color(hex: "E05555"))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                }
            }

            // ── Save button pinned at bottom
            Divider()
            Button {
                guard validateName() else { return }
                Task { await saveProfile() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 27)
                        .fill(nameText.trimmingCharacters(in: .whitespaces).isEmpty
                              ? Color.nafTextGray
                              : Color(hex: "1B3A6B"))
                        .frame(height: 54)
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save changes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(nameText.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 36)
        }
        .background(Color.white)
        .onAppear {
            nameText      = parentVM.parentName
            selectedEmoji = parentVM.parentAvatar
        }
    }

    private func validateName() -> Bool {
        let trimmed = nameText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            nameError = "Name cannot be empty"
            return false
        }
        let allowed = CharacterSet.letters.union(.init(charactersIn: " -'"))
        if trimmed.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            nameError = "Please use letters only — no numbers or symbols"
            return false
        }
        return true
    }

    private func saveProfile() async {
        guard let parentId = authVM.currentUserId else { return }
        isSaving = true
        let trimmed = nameText.trimmingCharacters(in: .whitespaces)

        struct ParentProfileUpdate: Encodable {
            let name:       String
            let avatar_url: String
        }

        do {
            try await supabase
                .from("parent")
                .update(ParentProfileUpdate(
                    name:       trimmed,
                    avatar_url: selectedEmoji))
                .eq("id", value: parentId.uuidString)
                .execute()
            await MainActor.run {
                parentVM.parentName   = trimmed
                parentVM.parentAvatar = selectedEmoji
                dismiss()
            }
        } catch {
            print("❌ saveProfile: \(error)")
        }
        isSaving = false
    }
}

// ═══════════════════════════════════════════════
// MARK: - Child Profile Edit Sheet
// ═══════════════════════════════════════════════

struct ChildProfileEditSheet: View {
    let child: ChildProfile
    let onSaved:   () async -> Void
    let onRemoved: () async -> Void
    @Environment(\.dismiss) var dismiss

    @State private var nameText    = ""
    @State private var ageText     = ""
    @State private var isSaving    = false
    @State private var isRemoving  = false
    @State private var isUnlinking = false
    @State private var showRemoveConfirm  = false
    @State private var showUnlinkConfirm  = false
    @State private var showAvatarPicker   = false
    @State private var selectedAvatar     = ""
    @State private var savePercent = 50
    @State private var spendPercent = 30
    @State private var givePercent = 20
    @State private var nameError   = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Avatar — tappable to change
                    HStack {
                        Spacer()
                        Button { showAvatarPicker = true } label: {
                            ZStack(alignment: .bottomTrailing) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(hex: "2D6DAB"), lineWidth: 2)
                                        .frame(width: 80, height: 80)
                                    if !selectedAvatar.isEmpty {
                                        Text(selectedAvatar).font(.system(size: 44))
                                    } else if let av = child.avatarUrl, !av.isEmpty {
                                        Text(av).font(.system(size: 44))
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 36))
                                            .foregroundColor(Color(hex: "2D6DAB"))
                                    }
                                }
                                // Edit badge
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "2D6DAB"))
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .offset(x: 4, y: 4)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                    // Card
                    VStack(spacing: 0) {

                        // ── Name ────────────────────
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NAME")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color.nafTextGray)

                            TextField("Child's name", text: $nameText)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "1B3A6B"))
                                .padding(14)
                                .background(Color(hex: "F5F7FA"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            nameError.isEmpty
                                            ? Color.nafLightCard
                                            : Color(hex: "E05555"),
                                            lineWidth: 1)
                                )
                                .onChange(of: nameText) { _, _ in nameError = "" }

                            if !nameError.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text(nameError)
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(Color(hex: "E05555"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 18)

                        // ── Age ─────────────────────
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AGE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color.nafTextGray)

                            TextField("Age", text: $ageText)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "1B3A6B"))
                                .frame(width: 100)
                                .padding(14)
                                .background(Color(hex: "F5F7FA"))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.nafLightCard, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 18)

                        Divider().padding(.horizontal, 20)

                        // ── Invite code / link device ──
                        if let code = child.inviteCode, !code.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("CHILD LOGIN CODE")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(Color(hex: "2D6DAB"))

                                HStack(spacing: 8) {
                                    ForEach(Array(code.enumerated()), id: \.offset) { _, digit in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: "1B3A6B"))
                                                .frame(width: 36, height: 44)
                                            Text(String(digit))
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = code
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 13))
                                            Text("Copy")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundColor(Color(hex: "2D6DAB"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "EBF4FF"))
                                        .cornerRadius(10)
                                    }
                                }

                                Text("Share this code with \(nameText) so they can log in")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.nafTextGray)
                            }
                            .padding(16)
                            .background(Color(hex: "EBF4FF"))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        } else {
                            // Link device row
                            ChildSettingsNavRow(
                                icon: "iphone.and.arrow.forward",
                                iconColor: Color(hex: "2D6DAB"),
                                title: "Link child device",
                                subtitle: "Generate an invite code"
                            )
                        }

                        // Unlink device row
                        Button {
                            showUnlinkConfirm = true
                        } label: {
                            ChildSettingsNavRow(
                                icon: "iphone.slash",
                                iconColor: Color(hex: "E05555"),
                                title: isUnlinking ? "Unlinking..." : "Unlink device",
                                subtitle: "Remove device access",
                                titleColor: Color(hex: "E05555")
                            )
                        }
                        .disabled(isUnlinking)

                        Divider().padding(.horizontal, 20).padding(.top, 4)

                        // ── Jar split ───────────────
                        VStack(alignment: .leading, spacing: 14) {
                            Text("JAR SPLIT DEFAULTS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color.nafTextGray)

                            JarSplitBar(save: savePercent, spend: spendPercent, give: givePercent)

                            JarPercentRow(label: "Saving",   dot: Color(hex: "E8A020"), value: $savePercent)   { rebalanceFrom("save") }
                            JarPercentRow(label: "Giving",   dot: Color(hex: "4CAF50"), value: $givePercent)   { rebalanceFrom("give") }
                            JarPercentRow(label: "Spending", dot: Color(hex: "E05555"), value: $spendPercent)  { rebalanceFrom("spend") }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        Spacer().frame(height: 24)

                        // ── Save button ─────────────
                        Button {
                            guard validateChildName() else { return }
                            Task { await saveChildChanges() }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(Color(hex: "1B3A6B"))
                                    .frame(height: 54)
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Save changes")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(isSaving || isRemoving)
                        .padding(.horizontal, 20)

                        // ── Remove child button ──────
                        Button {
                            showRemoveConfirm = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(Color(hex: "FDEAEA"))
                                    .frame(height: 54)
                                if isRemoving {
                                    ProgressView().tint(Color(hex: "E05555"))
                                } else {
                                    Text("Remove \(nameText)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(hex: "E05555"))
                                }
                            }
                        }
                        .disabled(isSaving || isRemoving)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .padding(.top, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(hex: "EEF2F8").ignoresSafeArea())
            .navigationTitle("\(child.name)'s Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "1B3A6B"))
                    }
                }
            }
        }
        .onAppear {
            nameText     = child.name
            ageText      = "\(child.age)"
            selectedAvatar = child.avatarUrl ?? ""
            savePercent  = child.jarSavePercent  ?? 50
            spendPercent = child.jarSpendPercent ?? 30
            givePercent  = child.jarGivePercent  ?? 20
        }
        .sheet(isPresented: $showAvatarPicker) {
            AvatarPickerSheet(
                selectedAvatar: $selectedAvatar,
                showSheet: $showAvatarPicker)
        }
        .confirmationDialog(
            "Remove \(nameText)?",
            isPresented: $showRemoveConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove child", role: .destructive) {
                Task { await removeChild() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \(nameText)'s profile, jars, and goals.")
        }
        .confirmationDialog(
            "Unlink \(nameText)'s device?",
            isPresented: $showUnlinkConfirm,
            titleVisibility: .visible
        ) {
            Button("Unlink device", role: .destructive) {
                Task { await unlinkDevice() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(nameText) will be logged out and will need a new invite code to log back in.")
        }
    }

    // ── Jar rebalancing: keep total at 100
    private func rebalanceFrom(_ changed: String) {
        let total = savePercent + givePercent + spendPercent
        let diff  = total - 100
        guard diff != 0 else { return }
        switch changed {
        case "save":
            let half = diff / 2
            givePercent  = max(0, givePercent  - half)
            spendPercent = max(0, spendPercent - (diff - half))
        case "give":
            let half = diff / 2
            savePercent  = max(0, savePercent  - half)
            spendPercent = max(0, spendPercent - (diff - half))
        default:
            let half = diff / 2
            savePercent = max(0, savePercent - half)
            givePercent = max(0, givePercent - (diff - half))
        }
    }

    private func validateChildName() -> Bool {
        let trimmed = nameText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            nameError = "Name cannot be empty"
            return false
        }
        let allowed = CharacterSet.letters.union(.init(charactersIn: " -'"))
        if trimmed.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            nameError = "Please use letters only — no numbers or symbols"
            return false
        }
        return true
    }

    private func saveChildChanges() async {
        isSaving = true
        let trimmedName = nameText.trimmingCharacters(in: .whitespaces)
        let age = Int(ageText) ?? child.age

        struct ChildUpdate: Encodable {
            let name:              String
            let age:               Int
            let avatar_url:        String
            let jar_save_percent:  Int
            let jar_spend_percent: Int
            let jar_give_percent:  Int
        }

        do {
            try await supabase
                .from("child_profile")
                .update(ChildUpdate(
                    name:              trimmedName,
                    age:               age,
                    avatar_url:        selectedAvatar,
                    jar_save_percent:  savePercent,
                    jar_spend_percent: spendPercent,
                    jar_give_percent:  givePercent))
                .eq("id", value: child.id.uuidString)
                .execute()
            await onSaved()
            await MainActor.run { dismiss() }
        } catch {
            print("❌ saveChildChanges: \(error)")
        }
        isSaving = false
    }

    private func removeChild() async {
        isRemoving = true
        do {
            try await supabase.from("jars").delete().eq("child_id", value: child.id.uuidString).execute()
            try await supabase.from("goals").delete().eq("child_id", value: child.id.uuidString).execute()
            try await supabase.from("transactions").delete().eq("child_id", value: child.id.uuidString).execute()
            try await supabase.from("child_activity").delete().eq("child_id", value: child.id.uuidString).execute()
            try await supabase.from("child_profile").delete().eq("id", value: child.id.uuidString).execute()
            await onRemoved()
            await MainActor.run { dismiss() }
        } catch {
            print("❌ removeChild: \(error)")
        }
        isRemoving = false
    }

    private func unlinkDevice() async {
        isUnlinking = true
        do {
            // Clear invite_code and pin so child is effectively logged out
            struct UnlinkUpdate: Encodable {
                let invite_code:       String?
                let pin:               String?
                let pin_reset_required: Bool
            }
            try await supabase
                .from("child_profile")
                .update(UnlinkUpdate(
                    invite_code:        nil,
                    pin:                nil,
                    pin_reset_required: true))
                .eq("id", value: child.id.uuidString)
                .execute()

            // If this child is currently logged in on this device, log them out
            if UserDefaults.standard.string(forKey: "childId") == child.id.uuidString {
                UserDefaults.standard.removeObject(forKey: "childId")
                UserDefaults.standard.removeObject(forKey: "parentId")
                UserDefaults.standard.removeObject(forKey: "childName")
                UserDefaults.standard.removeObject(forKey: "childAvatar")
                UserDefaults.standard.set(false, forKey: "isChildLoggedIn")
            }

            await onSaved()
            await MainActor.run { dismiss() }
        } catch {
            print("❌ unlinkDevice: \(error)")
        }
        isUnlinking = false
    }
}

// ═══════════════════════════════════════════════
// MARK: - Child Settings Nav Row
// ═══════════════════════════════════════════════

struct ChildSettingsNavRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var titleColor: Color = Color(hex: "1B3A6B")

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.10))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(titleColor)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.nafTextGray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color.nafTextGray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// ═══════════════════════════════════════════════
// MARK: - Jar Split Bar & Percent Row
// ═══════════════════════════════════════════════

struct JarSplitBar: View {
    let save: Int
    let spend: Int
    let give: Int

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "E8A020"))
                    .frame(width: geo.size.width * CGFloat(save) / 100)
                Rectangle()
                    .fill(Color(hex: "4CAF50"))
                    .frame(width: geo.size.width * CGFloat(give) / 100)
                Rectangle()
                    .fill(Color(hex: "E05555"))
            }
        }
        .frame(height: 10)
        .cornerRadius(5)
    }
}

struct JarPercentRow: View {
    let label: String
    let dot: Color
    @Binding var value: Int
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(dot)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "1B3A6B"))
                .frame(width: 68, alignment: .leading)
            Spacer()
            // Stepper
            HStack(spacing: 0) {
                Button {
                    if value > 0 { value -= 5; onChange() }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "1B3A6B"))
                        .frame(width: 32, height: 36)
                }
                Text("\(value)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "1B3A6B"))
                    .frame(width: 40)
                    .multilineTextAlignment(.center)
                Button {
                    if value < 100 { value += 5; onChange() }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "1B3A6B"))
                        .frame(width: 32, height: 36)
                }
                Text("%")
                    .font(.system(size: 14))
                    .foregroundColor(Color.nafTextGray)
                    .frame(width: 20)
            }
            .background(Color(hex: "F5F7FA"))
            .cornerRadius(10)
        }
    }
}

// ═══════════════════════════════════════════════
// MARK: - Jar Defaults Sheet (global)
// ═══════════════════════════════════════════════

struct JarDefaultsSheet: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var savePercent   = 50
    @State private var spendPercent  = 30
    @State private var givePercent   = 20
    @State private var isSaving      = false

    let presets: [(String, Int, Int, Int)] = [
        ("Default\n50/20/30", 50, 20, 30),
        ("Equal\n33/33/34",   33, 33, 34),
        ("Save heavy\n70/20/10", 70, 20, 10)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.nafTextGray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 4) {
                Text("Transfers Defaults")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "1B3A6B"))
                Text("Jar split & quick amounts")
                    .font(.system(size: 13))
                    .foregroundColor(Color.nafTextGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 14) {
                Text("DEFAULT JAR SPLIT")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(Color.nafTextGray)

                // Preset chips
                HStack(spacing: 10) {
                    ForEach(presets, id: \.0) { preset in
                        let isSelected = savePercent == preset.1
                            && givePercent == preset.2
                            && spendPercent == preset.3
                        Button {
                            withAnimation {
                                savePercent  = preset.1
                                givePercent  = preset.2
                                spendPercent = preset.3
                            }
                        } label: {
                            Text(preset.0)
                                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : Color(hex: "1B3A6B"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(isSelected ? Color(hex: "1B3A6B") : Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.nafLightCard, lineWidth: 1)
                                )
                        }
                    }
                }

                JarSplitBar(save: savePercent, spend: spendPercent, give: givePercent)
                    .padding(.vertical, 4)

                JarPercentRow(label: "Saving",   dot: Color(hex: "E8A020"), value: $savePercent)   { }
                JarPercentRow(label: "Giving",   dot: Color(hex: "4CAF50"), value: $givePercent)   { }
                JarPercentRow(label: "Spending", dot: Color(hex: "E05555"), value: $spendPercent)  { }
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 28)

            Button {
                Task { await saveDefaults() }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 27)
                        .fill(Color(hex: "1B3A6B"))
                        .frame(height: 54)
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save defaults")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color.white)
    }

    private func saveDefaults() async {
        guard let parentId = authVM.currentUserId else { return }
        isSaving = true
        struct ParentUpdate: Encodable {
            let default_save_percent:  Int
            let default_spend_percent: Int
            let default_give_percent:  Int
        }
        do {
            try await supabase
                .from("parent")
                .update(ParentUpdate(
                    default_save_percent:  savePercent,
                    default_spend_percent: spendPercent,
                    default_give_percent:  givePercent))
                .eq("id", value: parentId.uuidString)
                .execute()
            await MainActor.run { dismiss() }
        } catch {
            print("❌ saveDefaults: \(error)")
        }
        isSaving = false
    }
}

// ═══════════════════════════════════════════════
// MARK: - Logout Overlay
// ═══════════════════════════════════════════════

struct LogoutOverlay: View {
    let onLogout: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "EBF0F8"))
                        .frame(width: 64, height: 64)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "2D6DAB"))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Log out of Nafaqati?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1B3A6B"))

                Text("Your children's sessions will not be affected")
                    .font(.system(size: 13))
                    .foregroundColor(Color.nafTextGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 6)
                    .padding(.bottom, 24)

                Divider()

                Button(action: onLogout) {
                    Text("Yes, log out")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "1B3A6B"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "1B3A6B"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "E8EDF2"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal, 28)
        }
    }
}

// ═══════════════════════════════════════════════
// MARK: - Delete Account Full Screen
// ═══════════════════════════════════════════════

struct DeleteAccountView: View {
    @ObservedObject var authVM: AuthViewModel
    let onDeleted: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var showFinalConfirm = false
    @State private var isDeleting       = false
    @State private var childCount       = 0

    let deletionItems: [(String, String, String)] = [
        ("person.2.fill",       "Parent account and all children profiles",
         "Your profile, login, and all children's profiles"),
        ("bag.fill",            "All jars & balances",
         "Saving, giving, and spending balances"),
        ("scope",               "Goals & transactions",
         "All history and progress"),
        ("mic.fill",            "Voice notes & Eidiya records",
         "Permanently removed")
    ]

    var body: some View {
        ZStack {
            Color(hex: "EEF2F8").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Back bar
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(isDeleting ? Color.nafTextGray : Color(hex: "1B3A6B"))
                    }
                    .disabled(isDeleting)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)

                // ── Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FDEAEA"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "trash.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "E05555"))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Delete Account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "1B3A6B"))
                        Text("This cannot be undone")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nafTextGray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {

                        // What will be deleted
                        VStack(alignment: .leading, spacing: 0) {
                            Text("WHAT WILL BE DELETED")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color.nafTextGray)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                .padding(.bottom, 12)

                            ForEach(Array(deletionItems.enumerated()), id: \.offset) { idx, item in
                                if idx > 0 { Divider().padding(.horizontal, 20) }
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "FDEAEA"))
                                            .frame(width: 42, height: 42)
                                        Image(systemName: item.0)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "E05555"))
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.1)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(hex: "1B3A6B"))
                                        Text(item.2)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.nafTextGray)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                            }

                            Spacer().frame(height: 8)
                        }
                        .background(Color.white)
                        .cornerRadius(16)

                        Spacer().frame(height: 8)

                        // Delete button
                        Button {
                            showFinalConfirm = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(Color(hex: "C0392B"))
                                    .frame(height: 54)
                                if isDeleting {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Delete my account")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(isDeleting)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 60)
                }
            }

            // Final confirm overlay
            if showFinalConfirm {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FDEAEA"))
                            .frame(width: 64, height: 64)
                        Image(systemName: "trash.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(hex: "E05555"))
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 16)

                    Text("Are you sure?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "1B3A6B"))

                    Text("Everything will be permanently deleted.\nThis action cannot be reversed.")
                        .font(.system(size: 13))
                        .foregroundColor(Color.nafTextGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    Divider()

                    Button {
                        showFinalConfirm = false
                        Task { await deleteEverything() }
                    } label: {
                        Text("Yes, delete everything")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "C0392B"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Button {
                        showFinalConfirm = false
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "E8EDF2"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 28)
                }
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal, 28)
            }
        }
    }

    private func deleteEverything() async {
        guard let parentId = authVM.currentUserId else { return }
        isDeleting = true

        do {
            // 1. Get all children
            let children: [ChildProfile] = try await supabase
                .from("child_profile")
                .select()
                .eq("parent_id", value: parentId.uuidString)
                .execute()
                .value

            for child in children {
                // Delete child's jars
                try? await supabase
                    .from("jars")
                    .delete()
                    .eq("child_id", value: child.id.uuidString)
                    .execute()
                // Delete child's goals
                try? await supabase
                    .from("goals")
                    .delete()
                    .eq("child_id", value: child.id.uuidString)
                    .execute()
                // Delete child's transactions
                try? await supabase
                    .from("transactions")
                    .delete()
                    .eq("child_id", value: child.id.uuidString)
                    .execute()
                // Delete child activity
                try? await supabase
                    .from("child_activity")
                    .delete()
                    .eq("child_id", value: child.id.uuidString)
                    .execute()
                // Delete child profile
                try? await supabase
                    .from("child_profile")
                    .delete()
                    .eq("id", value: child.id.uuidString)
                    .execute()
            }

            // 2. Delete parent activity
            try? await supabase
                .from("parent_activity")
                .delete()
                .eq("parent_id", value: parentId.uuidString)
                .execute()

            // 3. Delete parent row
            try? await supabase
                .from("parent")
                .delete()
                .eq("id", value: parentId.uuidString)
                .execute()

            // 4. Delete auth user (sign out — Supabase auth.admin.deleteUser requires service key;
            //    signing out is the safe client-side action)
            try await supabase.auth.signOut()

            await MainActor.run {
                authVM.isLoggedIn    = false
                authVM.currentUserId = nil
                onDeleted()
                dismiss()
            }

        } catch {
            print("❌ deleteEverything: \(error)")
            await MainActor.run { isDeleting = false }
        }
    }
}

// ─────────────────────────────────────────────
// Keep existing SectionHeader & SettingsRow
// (already defined in this file above)
// ─────────────────────────────────────────────

// ═══════════════════════════════════════════════
// MARK: - Add Child From Settings
// ═══════════════════════════════════════════════

struct AddChildFromSettingsView: View {
    let onDone: () async -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var childVM = ChildViewModel()

    @State private var childName      = ""
    @State private var age            = ""
    @State private var grade          = ""
    @State private var selectedGender = ""
    @State private var selectedAvatar = ""
    @State private var showAvatarSheet = false
    @State private var isSaving       = false
    @State private var saveError      = ""

    var canSave: Bool {
        !childName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !age.isEmpty &&
        !selectedGender.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.nafBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        Spacer().frame(height: 24)

                        // Avatar picker
                        Button { showAvatarSheet = true } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.nafLightCard)
                                        .frame(width: 72, height: 72)
                                        .overlay(Circle().stroke(Color.nafNavy.opacity(0.15), lineWidth: 2))
                                    if selectedAvatar.isEmpty {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(Color.nafTextGray)
                                    } else {
                                        Text(selectedAvatar).font(.system(size: 36))
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Child's character")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color.nafNavy)
                                    Text("Tap to pick a character or photo")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.nafTextGray)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 20)

                        VStack(spacing: 18) {
                            NafField(label: "Child's name", placeholder: "e.g. Shahad", text: $childName)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.nafNavy)
                                HStack(spacing: 10) {
                                    GenderButton(emoji: "👦", label: "Boy",  isSelected: selectedGender == "Boy")  { selectedGender = "Boy" }
                                    GenderButton(emoji: "👧", label: "Girl", isSelected: selectedGender == "Girl") { selectedGender = "Girl" }
                                    Spacer()
                                }
                            }

                            HStack(spacing: 12) {
                                NafField(label: "Age", placeholder: "7 – 12", text: $age, keyboardType: .numberPad)
                                NafField(label: "School Grade", placeholder: "Grade 3", text: $grade)
                            }

                            if !saveError.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 13))
                                    Text(saveError).font(.system(size: 13))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 24)

                        Spacer().frame(height: 32)

                        Button {
                            Task { await saveChild() }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 27)
                                    .fill(canSave ? Color.nafNavy : Color.nafTextGray)
                                    .frame(height: 54)
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Add child")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(!canSave || isSaving)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color.nafNavy)
                    }
                }
            }
            .sheet(isPresented: $showAvatarSheet) {
                AvatarPickerSheet(selectedAvatar: $selectedAvatar, showSheet: $showAvatarSheet)
            }
        }
    }

    private func saveChild() async {
        guard let parentId = authVM.currentUserId else { return }
        isSaving   = true
        saveError  = ""
        let success = await childVM.createChildProfile(
            parentId:    parentId,
            name:        childName.trimmingCharacters(in: .whitespaces),
            age:         Int(age) ?? 0,
            gender:      selectedGender,
            grade:       grade,
            avatarEmoji: selectedAvatar
        )
        if success {
            await onDone()
            await MainActor.run { dismiss() }
        } else {
            saveError = childVM.errorMessage ?? "Failed to add child. Please try again."
        }
        isSaving = false
    }
}

// ═══════════════════════════════════════════════
// MARK: - Shared subviews (kept from original)
// ═══════════════════════════════════════════════

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
