import Foundation
import Combine
import Supabase
import UIKit

@MainActor
final class ChildViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func createChildProfile(
        name:     String,
        age:      Int,
        avatar:   String,        // emoji or empty
        photo:    UIImage? = nil, // real photo if taken
        pin:      String,
        parentId: UUID
    ) async -> Bool {

        isLoading    = true
        errorMessage = nil

        // ── 1. Upload photo to Supabase Storage if provided
        var avatarUrl = avatar  // start with emoji
        if let image = photo {
            if let url = await uploadChildPhoto(image, parentId: parentId, childName: name) {
                avatarUrl = url  // override with real photo URL
            }
        }

        struct ChildRow: Encodable {
            let parent_id:          String
            let name:               String
            let age:                Int
            let avatar_url:         String
            let pin_reset_required: Bool
        }

        do {
            try await supabase
                .from("child_profile")
                .insert(ChildRow(
                    parent_id:          parentId.uuidString,
                    name:               name,
                    age:                age,
                    avatar_url:         avatarUrl,
                    pin_reset_required: true
                ))
                .execute()

            isLoading = false
            return true

        } catch {
            errorMessage = error.localizedDescription
            isLoading    = false
            return false
        }
    }

    // ── Upload child photo to Supabase Storage ────────────
    func uploadChildPhoto(_ image: UIImage, parentId: UUID, childName: String) async -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            print("❌ uploadChildPhoto: failed to convert image to JPEG")
            return nil
        }
        let safeName = childName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        let fileName = "child_\(parentId.uuidString)_\(safeName)_\(UUID().uuidString).jpg"

        do {
            try await supabase.storage
                .from("child-avatars")
                .upload(
                    fileName,
                    data: data,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true))

            let publicUrl = try supabase.storage
                .from("child-avatars")
                .getPublicURL(path: fileName)

            print("✅ Child photo uploaded: \(publicUrl.absoluteString)")
            return publicUrl.absoluteString
        } catch {
            print("❌ uploadChildPhoto: \(error)")
            return nil
        }
    }

    // ── Update existing child avatar ─────────────────────
    func updateChildAvatar(childId: UUID, photo: UIImage?, emoji: String) async -> String? {
        if let image = photo {
            // Upload new photo
            if let url = await uploadChildPhoto(image, parentId: UUID(), childName: childId.uuidString) {
                do {
                    try await supabase
                        .from("child_profile")
                        .update(["avatar_url": url])
                        .eq("id", value: childId.uuidString)
                        .execute()
                    return url
                } catch {
                    print("❌ updateChildAvatar: \(error)")
                }
            }
        } else if !emoji.isEmpty {
            do {
                try await supabase
                    .from("child_profile")
                    .update(["avatar_url": emoji])
                    .eq("id", value: childId.uuidString)
                    .execute()
                return emoji
            } catch {
                print("❌ updateChildAvatar emoji: \(error)")
            }
        }
        return nil
    }
}
