import Foundation
import Supabase

final class ChildViewModel: ObservableObject {

    @Published var isLoading: Bool      = false
    @Published var errorMessage: String?

    // ─────────────────────────────────────────────
    // CREATE CHILD PROFILE
    // Inserts into child_profile table.
    // Supabase trigger auto-creates 3 jars.
    // ─────────────────────────────────────────────
    @MainActor
    func createChildProfile(
        parentId: UUID,
        name: String,
        age: Int,
        gender: String,
        grade: String,
        avatarEmoji: String
    ) async -> Bool {

        isLoading    = true
        errorMessage = nil

        struct ChildRow: Encodable {
            let parent_id:          String
            let name:               String
            let age:                Int
            let gender:             String
            let grade:              String
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
                    gender:             gender,
                    grade:              grade,
                    avatar_url:         avatarEmoji,
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
}