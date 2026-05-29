import Foundation
import Supabase
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var isLoggedIn: Bool     = false
    @Published var isLoading: Bool      = false
    @Published var errorMessage: String?
    @Published var currentUserId: UUID?

    // ─────────────────────────────────────
    // REGISTER
    // ─────────────────────────────────────
    func register(name: String, email: String, password: String) async {
        isLoading    = true
        errorMessage = nil

        do {
            // Step 1: create auth account
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            let userId = response.user.id

            // Step 2: insert into parent table
            struct ParentRow: Encodable {
                let id: String
                let name: String
                let email: String
                let default_save_percent: Int
                let default_spend_percent: Int
                let default_give_percent: Int
            }

            try await supabase
                .from("parent")
                .insert(ParentRow(
                    id: userId.uuidString,
                    name: name,
                    email: email,
                    default_save_percent: 50,
                    default_spend_percent: 30,
                    default_give_percent: 20
                ))
                .execute()

            // ── Set userId but NOT isLoggedIn yet ──
            // isLoggedIn is set in AllSetView after children are added
            currentUserId = userId

        } catch {
            let message = error.localizedDescription
            if message.contains("duplicate") || message.contains("already") {
                errorMessage = "An account with this email already exists."
            } else if message.contains("rate limit") || message.contains("email rate") {
                errorMessage = "Too many attempts. Please wait a few minutes and try again."
            } else if message.contains("invalid") || message.contains("API") {
                errorMessage = "Connection error. Please check your internet and try again."
            } else if message.contains("password") {
                errorMessage = "Password must be at least 8 characters."
            } else {
                errorMessage = message
            }
        }

        isLoading = false
    }

    // ─────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────
    func login(email: String, password: String) async {
        isLoading    = true
        errorMessage = nil

        do {
            let session   = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            currentUserId = session.user.id
            isLoggedIn    = true

        } catch {
            let message = error.localizedDescription
            if message.contains("Invalid login") || message.contains("credentials") {
                errorMessage = "Incorrect email or password. Please try again."
            } else if message.contains("not found") || message.contains("No user") {
                errorMessage = "No account found with this email. Please register first."
            } else {
                errorMessage = "Incorrect email or password. Please try again."
            }
        }

        isLoading = false
    }

    // ─────────────────────────────────────
    // LOGOUT
    // ─────────────────────────────────────
    func logout() async {
        do {
            try await supabase.auth.signOut()
            isLoggedIn    = false
            currentUserId = nil
            errorMessage  = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // ─────────────────────────────────────
    // CHECK SESSION — called on app launch
    // ─────────────────────────────────────
    func checkSession() async {
        do {
            let session   = try await supabase.auth.session
            currentUserId = session.user.id
            isLoggedIn    = true
        } catch {
            isLoggedIn = false
        }
    }
}
