import Foundation

enum OnboardingStep: Hashable {
    case roleSelection
    case parentInfo
    case createPassword(name: String, email: String)
    case addChild
    case myChildren
    case childPIN
    case allSet
    case login
    case forgotPassword(email: String)
}
