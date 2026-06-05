import SwiftUI
import PhotosUI

struct SetGoalView: View {
    @Environment(\.dismiss) var dismiss
    var onGoalCreated: (Goal) -> Void

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
    @FocusState private var isAmountFocused: Bool

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

                // ── Full page scroll ───────────
                ScrollView(showsIndicators: false) {
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
                            Text("Set New Goal")
                                .font(.system(
                                    size: 22,
                                    weight: .bold,
                                    design: .rounded))
                                .foregroundColor(Color(hex: "1B3A6B"))
                            Text("Create your savings goal")
                                .font(.system(
                                    size: 13,
                                    design: .rounded))
                                .foregroundColor(Color(hex: "8A9BB0"))
                        }
                        .padding(.bottom, 20)

                        // ── Content ────────────────────
                        if step == 1 { step1Content }
                        else { step2Content }
                    }
                }
                .scrollDismissesKeyboard(.immediately)

                // ── Bottom button ──────────────
                Button {
                    if step == 1 {
                        step = 2
                    } else {
                        // Save image to UserDefaults if custom photo selected
                        var iconToSave = selectedIcon
                        if useCustomPhoto, let img = goalImage,
                           let imageData = img.jpegData(
                            compressionQuality: 0.8) {
                            let key = "goalImage_\(UUID().uuidString)"
                            UserDefaults.standard.set(imageData, forKey: key)
                            iconToSave = "PHOTO:\(key)"
                        }

                        let newGoal = Goal(
                            name:   goalName,
                            icon:   iconToSave,
                            target: Double(targetAmount) ?? 100,
                            saved:  0,
                            days:   selectedDays
                        )
                        onGoalCreated(newGoal)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        if step == 2 {
                            Image(systemName: "target")
                        }
                        Text(step == 1 ? "Next" : "Create Goal")
                            .font(.system(
                                size: 16,
                                weight: .semibold,
                                design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        (goalName.isEmpty && step == 1) ||
                        (step == 2 && (targetAmount.isEmpty || (Double(targetAmount) ?? 0) <= 0))
                        ? Color(hex: "8A9BB0")
                        : Color(hex: "185FA5"))
                    .cornerRadius(27)
                }
                .disabled(
                    (goalName.isEmpty && step == 1) ||
                    (step == 2 && (targetAmount.isEmpty || (Double(targetAmount) ?? 0) <= 0))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .padding(.top, 12)
            }
        }
        .overlay {
            if showCustomSheet {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showCustomSheet = false }

                    VStack(spacing: 20) {
                        Text("How long is your goal? 🎯")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1B3A6B"))

                        HStack {
                            TextField("e.g. 45", text: $customDays)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "185FA5"))
                                .frame(width: 120)
                            Text("days")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "8A9BB0"))
                        }
                        .padding(16)
                        .background(Color(hex: "F4F6FA"))
                        .cornerRadius(14)

                        Button {
                            if let d = Int(customDays), d > 0 {
                                selectedDays     = d
                                isCustomSelected = true
                            }
                            showCustomSheet = false
                        } label: {
                            Text("Confirm")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    customDays.isEmpty || Int(customDays) == nil
                                    ? Color(hex: "8A9BB0")
                                    : Color(hex: "185FA5"))
                                .cornerRadius(25)
                        }
                        .disabled(customDays.isEmpty || Int(customDays) == nil)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 32)
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

    // ── Step 1 ───────────────────────────
    var step1Content: some View {
        VStack(spacing: 16) {

            // Goal icon display
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "D8E6F5"))
                        .frame(width: 100, height: 100)
                    if useCustomPhoto, let img = goalImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20))
                    } else {
                        Text(selectedIcon)
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

            // Goal name
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
                    .font(.system(size: 15, design: .rounded))
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
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color(hex: "8A9BB0"))
                    .frame(maxWidth: .infinity,
                           alignment: .trailing)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .padding(.horizontal, 20)

            // Choose icon grid
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

                // Upload photo
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo")
                            .foregroundColor(Color(hex: "185FA5"))
                        Text("Or Upload Your Own Photo")
                            .font(.system(
                                size: 13,
                                weight: .medium,
                                design: .rounded))
                            .foregroundColor(Color(hex: "185FA5"))
                    }
                    HStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "photo")
                                Text("Choose from Gallery")
                                    .font(.system(
                                        size: 13,
                                        design: .rounded))
                            }
                            .foregroundColor(Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "D0D7E4"),
                                            lineWidth: 1)
                            )
                        }
                        Button { showCamera = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "camera")
                                Text("Take a Photo")
                                    .font(.system(
                                        size: 13,
                                        design: .rounded))
                            }
                            .foregroundColor(Color(hex: "1B3A6B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "D0D7E4"),
                                            lineWidth: 1)
                            )
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

            // Goal preview
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "D8E6F5"))
                        .frame(width: 52, height: 52)
                    if useCustomPhoto, let img = goalImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text(selectedIcon)
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
                    Text("Your new goal")
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

            // Target amount
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
                        .focused($isAmountFocused)
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

            // Deadline
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
// MARK: - Custom Days Sheet
// ─────────────────────────────────────────────

struct CustomDaysSheet: View {
    @Binding var customDays: String
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            Text("How long is your goal? 🎯")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1B3A6B"))
                .padding(.bottom, 20)

            HStack {
                TextField("e.g. 45", text: $customDays)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "185FA5"))
                    .focused($isFocused)
                Text("days")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "8A9BB0"))
            }
            .padding(16)
            .background(Color(hex: "F4F6FA"))
            .cornerRadius(14)
            .padding(.horizontal, 24)

            Spacer().frame(height: 20)

            Button {
                onConfirm()
                dismiss()
            } label: {
                Text("Confirm")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        customDays.isEmpty || Int(customDays) == nil || Int(customDays)! <= 0
                        ? Color(hex: "8A9BB0")
                        : Color(hex: "185FA5"))
                    .cornerRadius(27)
            }
            .disabled(customDays.isEmpty || Int(customDays) == nil || Int(customDays)! <= 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onAppear { isFocused = true }
    }
}

// ─────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────

#Preview {
    SetGoalView { _ in }
}

// ── Camera view ──────────────────────────
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var useCustomPhoto: Bool
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let picker        = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate   = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context) {}

    class Coordinator: NSObject,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {

        let parent: CameraView
        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [
                UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[
                .originalImage] as? UIImage {
                parent.image          = image
                parent.useCustomPhoto = true
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.dismiss()
        }
    }
}

