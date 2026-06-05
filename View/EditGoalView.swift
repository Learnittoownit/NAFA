import SwiftUI
import PhotosUI

struct EditGoalView: View {
    @Binding var goal: Goal
    var onSave: ((Goal) -> Void)? = nil
    @Environment(\.dismiss) var dismiss

    @State private var step             = 1
    @State private var goalName         = ""
    @State private var selectedIcon     = "🎯"
    @State private var targetAmount     = ""
    @State private var selectedDays     = 30
    @State private var customDays        = ""
    @State private var isCustomSelected  = false
    @State private var showCustomSheet   = false
    @State private var selectedPhoto:   PhotosPickerItem?
    @State private var goalImage:       UIImage?
    @State private var showCamera       = false
    @State private var useCustomPhoto   = false

    let icons = [
        "🎨","🎸","⚽","📚","🚲","🎮",
        "🎒","✏️","⌚","🎧","📱","💻",
        "✨","🏆","🎯","📷","🎹","🏀",
        "🎬","🎪","🎠","🎁","💎","⭐",
        "🎤","🥁","🎻","🎺","🎳","🎲",
    ]

    let deadlines: [(Int, String)] = [
        (30, "1 Month"),
        (60, "2 Months"),
        (90, "3 Months"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "EEF2F8").ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top bar ────────────────────
                HStack {
                    Button {
                        if step == 1 { dismiss() }
                        else { step = 1 }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .font(.system(
                                    size: 15,
                                    design: .rounded))
                        }
                        .foregroundColor(Color(hex: "1B3A6B"))
                    }
                    Spacer()
                    Text("Edit Goal")
                        .font(.system(
                            size: 16,
                            weight: .semibold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "1B3A6B"))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 16)

                // ── Progress bar ───────────────
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "185FA5"))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(step == 2
                              ? Color(hex: "185FA5")
                              : Color(hex: "D0D7E4"))
                        .frame(height: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // ── Title ──────────────────────
                VStack(spacing: 4) {
                    Text("Edit Goal")
                        .font(.system(
                            size: 22,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "1B3A6B"))
                    Text("Update your savings goal")
                        .font(.system(
                            size: 13,
                            design: .rounded))
                        .foregroundColor(Color(hex: "8A9BB0"))
                }
                .padding(.bottom, 20)

                // ── Content ────────────────────
                ScrollView(showsIndicators: false) {
                    if step == 1 { step1Content }
                    else { step2Content }
                }

                // ── Bottom button ──────────────
                Button {
                    if step == 1 { step = 2 }
                    else { saveChanges() }
                } label: {
                    HStack(spacing: 8) {
                        if step == 2 {
                            Image(systemName:
                                "checkmark.circle.fill")
                        }
                        Text(step == 1
                             ? "Next"
                             : "Save changes")
                            .font(.system(
                                size: 16,
                                weight: .semibold,
                                design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        goalName.isEmpty && step == 1
                        ? Color(hex: "8A9BB0")
                        : Color(hex: "185FA5"))
                    .cornerRadius(27)
                }
                .disabled(goalName.isEmpty && step == 1)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 12)
            }
        }
        .onAppear {
            goalName     = goal.name
            selectedIcon = goal.icon
            targetAmount = String(Int(goal.target))
            selectedDays = goal.days
            if goal.icon.hasPrefix("PHOTO:") {
                let key = String(goal.icon.dropFirst(6))
                if let data = UserDefaults.standard.data(
                    forKey: key),
                   let img = UIImage(data: data) {
                    goalImage      = img
                    useCustomPhoto = true
                    selectedIcon   = goal.icon
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?
                    .loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    goalImage      = image
                    useCustomPhoto = true
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(
                image: $goalImage,
                useCustomPhoto: $useCustomPhoto)
            .ignoresSafeArea()
        }
    }

    // ── Save changes ─────────────────────
    func saveChanges() {
        var iconToSave = selectedIcon
        if useCustomPhoto,
           let img = goalImage,
           !goal.icon.hasPrefix("PHOTO:"),
           let imageData = img.jpegData(
            compressionQuality: 0.8) {
            let key = "goalImage_\(UUID().uuidString)"
            UserDefaults.standard.set(
                imageData, forKey: key)
            iconToSave = "PHOTO:\(key)"
        } else if useCustomPhoto
                    && goal.icon.hasPrefix("PHOTO:") {
            iconToSave = goal.icon
        }
        goal.name   = goalName
        goal.icon   = iconToSave
        goal.target = Double(targetAmount) ?? goal.target
        goal.days   = selectedDays
        onSave?(goal)
        dismiss()
    }

    // ── Step 1 ───────────────────────────
    var step1Content: some View {
        VStack(spacing: 16) {

            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "D8E6F5"))
                        .frame(width: 100, height: 100)
                    if useCustomPhoto,
                       let img = goalImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(
                                cornerRadius: 20))
                    } else {
                        Text(selectedIcon.hasPrefix("PHOTO:")
                             ? "📷" : selectedIcon)
                            .font(.system(size: 52))
                    }
                }
                Text("YOUR GOAL ICON")
                    .font(.system(
                        size: 11,
                        weight: .semibold,
                        design: .rounded))
                    .foregroundColor(Color(hex: "8A9BB0"))
                    .tracking(1)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text("✨")
                    Text("GOAL NAME")
                        .font(.system(
                            size: 12,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "185FA5"))
                        .tracking(1)
                }
                TextField("e.g., New PlayStation",
                          text: $goalName)
                    .font(.system(
                        size: 15,
                        design: .rounded))
                    .foregroundColor(.black)
                    .tint(.black)
                    .padding(14)
                    .background(Color(hex: "F4F6FA"))
                    .cornerRadius(12)
                    .onChange(of: goalName) { _, new in
                        if new.count > 30 {
                            goalName = String(new.prefix(30))
                        }
                    }
                Text("\(goalName.count)/30")
                    .font(.system(
                        size: 11,
                        design: .rounded))
                    .foregroundColor(Color(hex: "8A9BB0"))
                    .frame(maxWidth: .infinity,
                           alignment: .trailing)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .foregroundColor(Color(hex: "185FA5"))
                    Text("CHOOSE ICON")
                        .font(.system(
                            size: 12,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "185FA5"))
                        .tracking(1)
                }
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible()),
                        count: 6),
                    spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon   = icon
                            useCustomPhoto = false
                            goalImage      = nil
                        } label: {
                            Text(icon)
                                .font(.system(size: 26))
                                .frame(width: 44, height: 44)
                                .background(
                                    selectedIcon == icon
                                    && !useCustomPhoto
                                    ? Color(hex: "185FA5")
                                    : Color(hex: "F4F6FA"))
                                .cornerRadius(12)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo")
                            .foregroundColor(Color(hex: "185FA5"))
                        Text("Or Upload Your Own Photo")
                            .font(.system(
                                size: 13,
                                weight: .medium,
                                design: .rounded))
                            .foregroundColor(
                                Color(hex: "185FA5"))
                    }
                    HStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images) {
                            HStack(spacing: 6) {
                                Image(systemName: "photo")
                                Text("Choose from Gallery")
                                    .font(.system(
                                        size: 13,
                                        design: .rounded))
                            }
                            .foregroundColor(
                                Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: 12)
                                    .stroke(
                                        Color(hex: "D0D7E4"),
                                        lineWidth: 1))
                        }
                        Button {
                            showCamera = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "camera")
                                Text("Take a Photo")
                                    .font(.system(
                                        size: 13,
                                        design: .rounded))
                            }
                            .foregroundColor(
                                Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: 12)
                                    .stroke(
                                        Color(hex: "D0D7E4"),
                                        lineWidth: 1))
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            Spacer().frame(height: 8)
        }
    }

    // ── Step 2 ───────────────────────────
    var step2Content: some View {
        VStack(spacing: 16) {

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "D8E6F5"))
                        .frame(width: 52, height: 52)
                    if useCustomPhoto,
                       let img = goalImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(
                                cornerRadius: 12))
                    } else {
                        Text(selectedIcon.hasPrefix("PHOTO:")
                             ? "📷" : selectedIcon)
                            .font(.system(size: 28))
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(goalName.isEmpty
                         ? "Your goal" : goalName)
                        .font(.system(
                            size: 16,
                            weight: .semibold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "1B3A6B"))
                    Text("Your goal")
                        .font(.system(
                            size: 12,
                            design: .rounded))
                        .foregroundColor(Color(hex: "8A9BB0"))
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Text("$")
                        .font(.system(
                            size: 14,
                            weight: .bold))
                        .foregroundColor(Color(hex: "185FA5"))
                    Text("TARGET AMOUNT")
                        .font(.system(
                            size: 12,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "185FA5"))
                        .tracking(1)
                }
                HStack {
                    TextField("0", text: $targetAmount)
                        .keyboardType(.numberPad)
                        .font(.system(
                            size: 32,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(.black)
                        .tint(.black)
                    Spacer()
                    Text("SAR")
                        .font(.system(
                            size: 16,
                            weight: .semibold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "8A9BB0"))
                }
                .padding(16)
                .background(Color(hex: "F4F6FA"))
                .cornerRadius(12)

                HStack(spacing: 10) {
                    ForEach(["50","100","200","500"],
                            id: \.self) { val in
                        Button { targetAmount = val } label: {
                            Text(val)
                                .font(.system(
                                    size: 14,
                                    weight: .medium,
                                    design: .rounded))
                                .foregroundColor(
                                    targetAmount == val
                                    ? .white
                                    : Color(hex: "1B3A6B"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    targetAmount == val
                                    ? Color(hex: "185FA5")
                                    : Color(hex: "F4F6FA"))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(hex: "185FA5"))
                    Text("DEADLINE")
                        .font(.system(
                            size: 12,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(Color(hex: "185FA5"))
                        .tracking(1)
                }
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 10) {
                    ForEach(deadlines, id: \.0) { deadline in
                        Button {
                            selectedDays     = deadline.0
                            isCustomSelected = false
                            customDays       = ""
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(deadline.0)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                Text(deadline.1)
                                    .font(.system(size: 13, design: .rounded))
                            }
                            .foregroundColor(
                                selectedDays == deadline.0 && !isCustomSelected
                                ? .white : Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(
                                selectedDays == deadline.0 && !isCustomSelected
                                ? Color(hex: "185FA5") : Color(hex: "F4F6FA"))
                            .cornerRadius(16)
                        }
                    }

                    // ── Custom option ──────────────
                    Button {
                        showCustomSheet = true
                    } label: {
                        VStack(spacing: 4) {
                            if isCustomSelected, let d = Int(customDays), d > 0 {
                                Text("\(d)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                            } else {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 22))
                                    .foregroundColor(isCustomSelected ? .white : Color(hex: "1B3A6B"))
                            }
                            Text("Custom")
                                .font(.system(size: 13, design: .rounded))
                        }
                        .foregroundColor(isCustomSelected ? .white : Color(hex: "1B3A6B"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 72)
                        .background(isCustomSelected ? Color(hex: "185FA5") : Color(hex: "F4F6FA"))
                        .cornerRadius(16)
                    }
                    .sheet(isPresented: $showCustomSheet) {
                        CustomDaysSheet(customDays: $customDays) {
                            if let d = Int(customDays), d > 0 {
                                selectedDays     = d
                                isCustomSelected = true
                            }
                        }
                        .presentationDetents([.height(280)])
                        .presentationDragIndicator(.hidden)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            Spacer().frame(height: 8)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────

#Preview {
    EditGoalView(goal: .constant(Goal(
        name:   "New PlayStation",
        icon:   "🎮",
        target: 500,
        saved:  120,
        days:   30
    )))
}

