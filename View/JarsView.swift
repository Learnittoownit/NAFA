import SwiftUI

struct JarsView: View {

    @State private var selectedJar: JarType = .saving
    @State private var showSheet            = false

    enum JarType { case saving, giving, spending }

    let savingBal   = 0.0
    let givingBal   = 0.0
    let spendingBal = 0.0

    struct HistoryItem: Identifiable {
        let id    = UUID()
        let name:  String
        let date:  String
        let amount: Double
    }

    let savingHistory: [HistoryItem] = []
    let givingHistory: [HistoryItem] = []
    let spendingHistory: [HistoryItem] = []

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

    // Pick correct jar image based on amount + color
    func jarImageName(amount: Double, color: String) -> String {
        if amount == 0         { return "Empty jar \(color)" }
        else if amount < 50    { return "one jar \(color)" }
        else if amount < 100   { return "two jar \(color)" }
        else                   { return "full jar \(color)" }
    }

    var body: some View {
        ZStack(alignment: .bottom)  {
            Color(hex: "EEF2F8").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // Title
                    HStack {
                        Text("My Jars")
                            .font(.system(
                                size: 22,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(Color(hex: "1B3A6B"))
                        Spacer()
                        Image(systemName: "info.circle")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "8A9BB0"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // 3 Jar cards
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

                    // Balance card
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
                            .foregroundColor(selectedColor.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(selectedBgColor)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)

                    // History
                    VStack(spacing: 0) {
                        HStack {
                            Text(historyTitle)
                                .font(.system(
                                    size: 13,
                                    weight: .semibold,
                                    design: .rounded))
                                .foregroundColor(Color(hex: "1B3A6B"))
                            Spacer()
                            Button {} label: {
                                Text("SEE ALL")
                                    .font(.system(
                                        size: 11,
                                        weight: .semibold,
                                        design: .rounded))
                                    .foregroundColor(Color(hex: "185FA5"))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)

                        Divider()

                        ForEach(selectedHistory) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.name)
                                        .font(.system(
                                            size: 14,
                                            weight: .medium,
                                            design: .rounded))
                                        .foregroundColor(Color(hex: "1B3A6B"))
                                    Text(item.date)
                                        .font(.system(
                                            size: 12,
                                            design: .rounded))
                                        .foregroundColor(Color(hex: "8A9BB0"))
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

                            if item.id != selectedHistory.last?.id {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 80)
                }
            }

            // FAB + button
            Button { showSheet = true } label: {
                ZStack {
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: selectedColor.opacity(0.4),
                            radius: 8, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 24)        }
        .sheet(isPresented: $showSheet) {
            JarActionSheet(
                jarType:   selectedJar,
                jarImage:  jarImageName(
                    amount: selectedBalance,
                    color:  selectedColorName),
                title:     sheetTitle,
                color:     selectedColor,
                bgColor:   selectedBgColor
            )
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(false)
        }    }
}

// ── Jar select card ──────────────────────
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
                        lineWidth: 2)
            )
        }
    }
}

// ── Jar action sheet ─────────────────────
struct JarActionSheet: View {
    let jarType:  JarsView.JarType
    let jarImage: String
    let title:    String
    let color:    Color
    let bgColor:  Color

    @State private var amount           = ""
    @State private var selectedCategory = "Food"
    @Environment(\.dismiss) var dismiss

    let categories: [(String, String)] = [
        ("🍔", "Food"),
        ("✏️", "School"),
        ("🎮", "Fun"),
        ("🛍️", "Other"),
    ]

    var body: some View {
        ZStack {
            // Full background same color as sheet
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Handle ─────────────────────
                Capsule()
                    .fill(color.opacity(0.4))
                    .frame(width: 44, height: 5)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // ── Jar image + title ──────────
                HStack(spacing: 20) {
                    Image(jarImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 100)

                    VStack(alignment: .leading,
                           spacing: 6) {
                        Text(title)
                            .font(.system(
                                size: 22,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(
                                Color(hex: "1B3A6B"))

                        // Category picker for spending
                        if jarType == .spending {
                            HStack(spacing: 10) {
                                ForEach(categories,
                                        id: \.1) { cat in
                                    Button {
                                        selectedCategory =
                                        cat.1
                                    } label: {
                                        VStack(spacing: 4) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        selectedCategory == cat.1
                                                        ? color
                                                        : Color.white)
                                                    .frame(
                                                        width: 44,
                                                        height: 44)
                                                    .shadow(
                                                        color: Color
                                                            .black
                                                            .opacity(
                                                                0.06),
                                                        radius: 4,
                                                        x: 0,
                                                        y: 2)
                                                Text(cat.0)
                                                    .font(.system(
                                                        size: 20))
                                            }
                                            Text(cat.1)
                                                .font(.system(
                                                    size: 10,
                                                    design:
                                                        .rounded))
                                                .foregroundColor(
                                                    selectedCategory == cat.1
                                                    ? color
                                                    : Color(hex:
                                                        "8A9BB0"))
                                        }
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 28)

                // ── Amount section ─────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount (SAR)")
                        .font(.system(
                            size: 13,
                            weight: .semibold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "8A9BB0"))
                        .padding(.horizontal, 24)

                    HStack {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(
                                size: 36,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(.black)
                            .tint(color)

                        Text("SAR")
                            .font(.system(
                                size: 18,
                                weight: .semibold,
                                design: .rounded))
                            .foregroundColor(
                                Color(hex: "8A9BB0"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 28)

                // ── Save button ────────────────
                Button {
                    dismiss()
                } label: {
                    Text(jarType == .spending
                         ? "Save purchase"
                         : "Save to jar")
                        .font(.system(
                            size: 17,
                            weight: .semibold,
                            design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            amount.isEmpty
                            ? color.opacity(0.4)
                            : color)
                        .cornerRadius(28)
                }
                .disabled(amount.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
