import SwiftUI
import Supabase

struct JarsView: View {

    @State private var selectedJar: JarType = .saving
    @State private var showSheet            = false

    enum JarType { case saving, giving, spending }

    @State var savingBal:   Double = 0.0
    @State var givingBal:   Double = 0.0
    @State var spendingBal: Double = 0.0
    @State private var showJarInfo = false
    @State private var savingHistory:   [HistoryItem] = []
    @State private var givingHistory:   [HistoryItem] = []
    @State private var spendingHistory: [HistoryItem] = []

    @State private var savingJarId:   UUID? = nil
    @State private var givingJarId:   UUID? = nil
    @State private var spendingJarId: UUID? = nil

    struct HistoryItem: Identifiable {
        let id      = UUID()
        let name:   String
        let date:   String
        let amount: Double
    }

    var selectedBalance: Double {
        switch selectedJar {
        case .saving:   return savingBal
        case .giving:   return givingBal
        case .spending: return spendingBal
        }
    }

    var selectedHistory: [HistoryItem] {
        switch selectedJar {
        case .saving:   return savingHistory
        case .giving:   return givingHistory
        case .spending: return spendingHistory
        }
    }

    var selectedColor: Color {
        switch selectedJar {
        case .saving:   return Color(hex: "C8923A")
        case .giving:   return Color(hex: "4CAF50")
        case .spending: return Color(hex: "E05555")
        }
    }

    var selectedBgColor: Color {
        switch selectedJar {
        case .saving:   return Color(hex: "FFF8EC")
        case .giving:   return Color(hex: "F0FAF0")
        case .spending: return Color(hex: "FFF0F0")
        }
    }

    var selectedColorName: String {
        switch selectedJar {
        case .saving:   return "yellow"
        case .giving:   return "green"
        case .spending: return "red"
        }
    }

    var selectedJarId: UUID? {
        switch selectedJar {
        case .saving:   return savingJarId
        case .giving:   return givingJarId
        case .spending: return spendingJarId
        }
    }

    var historyTitle: String {
        switch selectedJar {
        case .saving:   return "Saving history"
        case .giving:   return "Giving history"
        case .spending: return "What you spent"
        }
    }

    var balanceLabel: String {
        switch selectedJar {
        case .saving:   return "current balance"
        case .giving:   return "set aside for giving"
        case .spending: return "current balance"
        }
    }

    var sheetTitle: String {
        switch selectedJar {
        case .saving:   return "Add to savings"
        case .giving:   return "Add to giving"
        case .spending: return "Log a purchase"
        }
    }

    func jarImageName(amount: Double,
                      color: String) -> String {
        if amount == 0       { return "Empty jar \(color)" }
        else if amount < 50  { return "one jar \(color)" }
        else if amount < 100 { return "two jar \(color)" }
        else                 { return "full jar \(color)" }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "EEF2F8").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    HStack {
                        Text("My Jars")
                            .font(.system(
                                size: 22,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(
                                Color(hex: "1B3A6B"))
                        Spacer()
                        Button {
                            showJarInfo = true
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "185FA5"))
                        }                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    HStack(spacing: 12) {
                        JarSelectCard(
                            imageName: jarImageName(
                                amount: savingBal,
                                color: "yellow"),
                            label: "Saving",
                            amount: savingBal,
                            color: Color(hex: "C8923A"),
                            bgColor: Color(hex: "FFF8EC"),
                            isSelected: selectedJar == .saving
                        ) { selectedJar = .saving }

                        JarSelectCard(
                            imageName: jarImageName(
                                amount: givingBal,
                                color: "green"),
                            label: "Giving",
                            amount: givingBal,
                            color: Color(hex: "4CAF50"),
                            bgColor: Color(hex: "F0FAF0"),
                            isSelected: selectedJar == .giving
                        ) { selectedJar = .giving }

                        JarSelectCard(
                            imageName: jarImageName(
                                amount: spendingBal,
                                color: "red"),
                            label: "Spending",
                            amount: spendingBal,
                            color: Color(hex: "E05555"),
                            bgColor: Color(hex: "FFF0F0"),
                            isSelected: selectedJar == .spending
                        ) { selectedJar = .spending }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(selectedBalance)) SAR")
                            .font(.system(
                                size: 28,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(selectedColor)
                        Text(balanceLabel)
                            .font(.system(
                                size: 13,
                                design: .rounded))
                            .foregroundColor(
                                selectedColor.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity,
                           alignment: .leading)
                    .padding(20)
                    .background(selectedBgColor)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)

                    VStack(spacing: 0) {
                        HStack {
                            Text(historyTitle)
                                .font(.system(
                                    size: 13,
                                    weight: .semibold,
                                    design: .rounded))
                                .foregroundColor(
                                    Color(hex: "1B3A6B"))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        if selectedHistory.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.system(size: 28))
                                    .foregroundColor(
                                        Color(hex: "8A9BB0"))
                                Text("No history yet")
                                    .font(.system(
                                        size: 14,
                                        design: .rounded))
                                    .foregroundColor(
                                        Color(hex: "8A9BB0"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                        } else {
                            Divider()
                            ForEach(selectedHistory) { item in
                                HStack {
                                    VStack(
                                        alignment: .leading,
                                        spacing: 3) {
                                        Text(item.name)
                                            .font(.system(
                                                size: 14,
                                                weight: .medium,
                                                design: .rounded))
                                            .foregroundColor(
                                                Color(hex:
                                                    "1B3A6B"))
                                        Text(item.date)
                                            .font(.system(
                                                size: 12,
                                                design: .rounded))
                                            .foregroundColor(
                                                Color(hex:
                                                    "8A9BB0"))
                                    }
                                    Spacer()
                                    Text(item.amount > 0
                                         ? "+\(Int(item.amount)) SAR"
                                         : "\(Int(item.amount)) SAR")
                                        .font(.system(
                                            size: 13,
                                            weight: .semibold,
                                            design: .rounded))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedBgColor)
                                        .foregroundColor(selectedColor)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)

                                if item.id !=
                                    selectedHistory.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 80)
                }
            }

            Button { showSheet = true } label: {
                ZStack {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: selectedColor.opacity(0.4),
                            radius: 8, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(
                            size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            Task { await fetchJars() }
        }
        .sheet(isPresented: $showSheet) {
            JarActionSheet(
                jarType:   selectedJar,
                jarImage:  jarImageName(
                    amount: selectedBalance,
                    color:  selectedColorName),
                title:     sheetTitle,
                color:     selectedColor,
                bgColor:   selectedBgColor,
                jarId:     selectedJarId,
                onSaved: { _, _ in
                    Task { await fetchJars() }
                })
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showJarInfo) {
            JarInfoSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    func fetchJars() async {
        guard let childIdStr = UserDefaults.standard
            .string(forKey: "childId") else {
            print("❌ No childId in UserDefaults")
            return
        }
        guard let childId = UUID(uuidString: childIdStr)
        else {
            print("❌ Invalid childId")
            return
        }

        do {
            let jars: [Jar] = try await supabase
                .from("jars")
                .select()
                .eq("child_id", value: childId.uuidString)
                .execute()
                .value

            let transactions: [TransactionItem] =
                try await supabase
                .from("transactions")
                .select()
                .eq("child_id", value: childId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value

            await MainActor.run {
                for jar in jars {
                    switch jar.type {
                    case .saving:
                        savingBal   = jar.balance
                        savingJarId = jar.id
                    case .spending:
                        spendingBal   = jar.balance
                        spendingJarId = jar.id
                    case .giving:
                        givingBal   = jar.balance
                        givingJarId = jar.id
                    }
                }

                savingHistory   = []
                givingHistory   = []
                spendingHistory = []

                for t in transactions {
                    let item = HistoryItem(
                        name:   t.note ?? t.source,
                        date:   timeAgo(t.createdAt ?? Date()),
                        amount: t.type == "deposit"
                                ? t.amount : -t.amount)

                    if t.jarId == savingJarId {
                        savingHistory.append(item)
                    } else if t.jarId == givingJarId {
                        givingHistory.append(item)
                    } else if t.jarId == spendingJarId {
                        spendingHistory.append(item)
                    }
                }
            }
        } catch {
            print("❌ fetchJars error: \(error)")
        }
    }

    func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        switch seconds {
        case 0..<60:    return "Just now"
        case 60..<3600:
            let mins = seconds / 60
            return "\(mins) min\(mins > 1 ? "s" : "") ago"
        case 3600..<86400:
            let hours = seconds / 3600
            return "\(hours) hour\(hours > 1 ? "s" : "") ago"
        case 86400..<604800:
            let days = seconds / 86400
            return "\(days) day\(days > 1 ? "s" : "") ago"
        default:
            let weeks = seconds / 604800
            return "\(weeks) week\(weeks > 1 ? "s" : "") ago"
        }
    }
}

// ── Transaction item ──────────────────────
struct TransactionItem: Codable, Identifiable {
    let id:        UUID
    let jarId:     UUID?
    let type:      String
    let amount:    Double
    let source:    String
    let note:      String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case jarId     = "jar_id"
        case type
        case amount
        case source
        case note
        case createdAt = "created_at"
    }
}

// ── Jar select card ───────────────────────
struct JarSelectCard: View {
    let imageName:  String
    let label:      String
    let amount:     Double
    let color:      Color
    let bgColor:    Color
    let isSelected: Bool
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 80)
                    .padding(.top, 10)
                Text(label)
                    .font(.system(
                        size: 12,
                        weight: .semibold,
                        design: .rounded))
                    .foregroundColor(Color(hex: "1B3A6B"))
                Text("\(Int(amount)) SAR")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(color)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(isSelected ? bgColor : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? color : Color.clear,
                        lineWidth: 2))
        }
    }
}

// ── Jar action sheet ──────────────────────
struct JarActionSheet: View {
    let jarType:  JarsView.JarType
    let jarImage: String
    let title:    String
    let color:    Color
    let bgColor:  Color
    let jarId:    UUID?
    var onSaved:  (Double, Bool) -> Void

    @State private var amount           = ""
    @State private var selectedCategory = "Food"
    @State private var isLoading        = false
    @State private var requestSent      = false
    @State private var insufficientFunds = false
    @Environment(\.dismiss) var dismiss

    let categories: [(String, String)] = [
        ("🍔", "Food"),
        ("✏️", "School"),
        ("🎮", "Fun"),
        ("🛍️", "Other"),
    ]

    // All jars require parent approval for adding money
    var isDepositRequest: Bool { true }

    // Spending jar shows "spend" language, others show "add"
    var buttonLabel: String {
        jarType == .spending ? "Send spend request 📨" : "Send request to parent 📨"
    }

    var actionVerb: String {
        jarType == .spending ? "spend" : "add"
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {

                Capsule()
                    .fill(color.opacity(0.4))
                    .frame(width: 44, height: 5)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                HStack(spacing: 20) {
                    Image(jarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 100)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1B3A6B"))

                        // ── Deposit request banner (all jars)
                        HStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "2D6DAB"))
                            Text("Your parent will approve this")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "2D6DAB"))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "EBF4FF"))
                        .cornerRadius(10)

                        // ── Spending categories (only for spending jar)
                        if jarType == .spending {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.1) { cat in
                                    Button { selectedCategory = cat.1 } label: {
                                        VStack(spacing: 4) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedCategory == cat.1 ? color : Color.white)
                                                    .frame(width: 44, height: 44)
                                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                                Text(cat.0).font(.system(size: 20))
                                            }
                                            Text(cat.1)
                                                .font(.system(size: 10, design: .rounded))
                                                .foregroundColor(selectedCategory == cat.1 ? color : Color(hex: "8A9BB0"))
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Amount (SAR)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "8A9BB0"))
                            HStack {
                                TextField("0", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                    .tint(color)
                                Spacer()
                                Text("SAR")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "8A9BB0"))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                            .background(Color.white).cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // ── Insufficient funds error (spending jar)
                if insufficientFunds {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Not enough money in your jar!")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "E05555"))
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .transition(.opacity)
                }

                // ── Success state after request sent
                if requestSent {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "4CAF50"))
                        Text("Request sent! 🎉")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1B3A6B"))
                        Text("Wait for your parent to approve it")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(Color(hex: "8A9BB0"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer().frame(height: 28)

                Button {
                    Task {
                        if isDepositRequest {
                            await sendDepositRequest()
                        } else {
                            await saveToJar()
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(amount.isEmpty ? color.opacity(0.4) : color)
                            .frame(height: 56)
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(buttonLabel)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(amount.isEmpty || isLoading || requestSent)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    // ── Send deposit REQUEST to parent (no jar balance change yet) ──
    func sendDepositRequest() async {
        guard let amt = Double(amount), amt > 0,
              let childIdStr  = UserDefaults.standard.string(forKey: "childId"),
              let parentIdStr = UserDefaults.standard.string(forKey: "parentId"),
              let parentId    = UUID(uuidString: parentIdStr)
        else { return }

        isLoading = true

        let childName = UserDefaults.standard.string(forKey: "childName") ?? "Your child"
        let jarName: String
        let jarColorStr: String
        switch jarType {
        case .saving:   jarName = "Saving";   jarColorStr = "yellow"
        case .giving:   jarName = "Giving";   jarColorStr = "green"
        case .spending: jarName = "Spending"; jarColorStr = "red"
        }

        struct ParentActivityInsert: Encodable {
            let parent_id: String; let title: String; let meta: String
        }
        struct ChildActivityInsert: Encodable {
            let child_id: String; let title: String; let meta: String
            let sf_symbol: String; let jar_color: String; let amount: Double
        }

        do {
            // ── Notify parent in their activity feed
            try await supabase
                .from("parent_activity")
                .insert(ParentActivityInsert(
                    parent_id: parentId.uuidString,
                    title:     jarType == .spending
                               ? "💸 \(childName) wants to spend \(Int(amt)) SAR from \(jarName) jar"
                               : "💰 \(childName) requested to add \(Int(amt)) SAR to \(jarName) jar",
                    meta:      jarType == .spending
                               ? "Deposit request · -\(Int(amt)) SAR · \(jarName) · \(childIdStr)"
                               : "Deposit request · \(Int(amt)) SAR · \(jarName) · \(childIdStr)"))
                .execute()

            // ── Log to child activity
            try? await supabase
                .from("child_activity")
                .insert(ChildActivityInsert(
                    child_id:  childIdStr,
                    title:     jarType == .spending
                               ? "Requested to spend \(Int(amt)) SAR from \(jarName) jar"
                               : "Requested \(Int(amt)) SAR for \(jarName) jar",
                    meta:      "Waiting for parent approval",
                    sf_symbol: "bell.badge.fill",
                    jar_color: jarColorStr,
                    amount:    0))
                .execute()

            await MainActor.run {
                isLoading = false
                withAnimation { requestSent = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
        } catch {
            print("❌ sendDepositRequest: \(error)")
            await MainActor.run { isLoading = false }
        }
    }

    // ── Direct withdrawal (spending jar only) ──
    func saveToJar() async {
        guard let jarId = jarId,
              let amt = Double(amount),
              amt > 0,
              let childIdStr = UserDefaults.standard.string(forKey: "childId"),
              let childId = UUID(uuidString: childIdStr)
        else { return }

        isLoading = true
        let finalAmount = -amt  // spending = always withdrawal

        struct JarTransactionInsert: Encodable {
            let child_id: String; let jar_id: String
            let type: String; let amount: Double
            let source: String; let note: String
        }
        struct ChildActivityInsert: Encodable {
            let child_id: String; let title: String; let meta: String
            let sf_symbol: String; let jar_color: String; let amount: Double
        }
        struct ParentActivityInsert: Encodable {
            let parent_id: String; let title: String; let meta: String
        }

        let childName = UserDefaults.standard.string(forKey: "childName") ?? "Your child"

        do {
            let jars: [Jar] = try await supabase
                .from("jars").select().eq("id", value: jarId.uuidString).execute().value

            if let jar = jars.first {
                // ── Check child has enough balance
                guard jar.balance >= amt else {
                    await MainActor.run {
                        isLoading = false
                        withAnimation { insufficientFunds = true }
                    }
                    return
                }
                let newBalance = jar.balance - amt
                try await supabase
                    .from("jars")
                    .update(["balance": newBalance])
                    .eq("id", value: jarId.uuidString).execute()
            }

            try await supabase.from("transactions")
                .insert(JarTransactionInsert(
                    child_id: childId.uuidString, jar_id: jarId.uuidString,
                    type: "withdrawal", amount: amt,
                    source: "manual", note: selectedCategory))
                .execute()

            try? await supabase.from("child_activity")
                .insert(ChildActivityInsert(
                    child_id:  childId.uuidString,
                    title:     "Spent \(Int(amt)) SAR from spending jar",
                    meta:      selectedCategory,
                    sf_symbol: "minus.circle.fill",
                    jar_color: "red",
                    amount:    -amt))
                .execute()

            // Notify parent about spending
            if let parentIdStr = UserDefaults.standard.string(forKey: "parentId"),
               let parentId = UUID(uuidString: parentIdStr) {
                try? await supabase.from("parent_activity")
                    .insert(ParentActivityInsert(
                        parent_id: parentId.uuidString,
                        title:     "\(childName) spent \(Int(amt)) SAR on \(selectedCategory)",
                        meta:      "Spending · \(selectedCategory)"))
                    .execute()
            }

            await MainActor.run {
                isLoading = false
                onSaved(amt, false)
                dismiss()
            }
        } catch {
            print("❌ saveToJar error: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}
