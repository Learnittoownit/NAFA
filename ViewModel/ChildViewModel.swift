import Foundation
import Combine
import Supabase

@MainActor
final class ChildViewModel: ObservableObject {

    var isLoading: Bool      = false
    var errorMessage: String?

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
        objectWillChange.send()

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
                    avatar_url:         avatarEmoji,
                    pin_reset_required: true
                ))
                .execute()

            isLoading = false
            objectWillChange.send()
            return true

        } catch {
            errorMessage = error.localizedDescription
            isLoading    = false
            objectWillChange.send()
            return false
        }
    }
}
