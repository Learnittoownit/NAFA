import SwiftUI

struct GoalIconView: View {
    let icon: String
    let size: CGFloat

    var body: some View {
        if icon.hasPrefix("PHOTO:") {
            let key = String(icon.dropFirst(6))
            if let data = UserDefaults.standard.data(
                forKey: key),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size * 1.5,
                           height: size * 1.5)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .font(.system(size: size))
                    .foregroundColor(Color(hex: "8A9BB0"))
            }
        } else {
            Text(icon)
                .font(.system(size: size))
        }
    }
}
