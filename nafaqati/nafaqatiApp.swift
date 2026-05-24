import SwiftUI

@main
struct nafaqatiApp: App {
    @StateObject private var authVM = AuthViewModel()
    @State private var showSplash = true
    @State private var path = NavigationPath()

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else if authVM.isLoggedIn {
                // TODO: replace with ParentHomeView() on Day 3
                Text("✅ Logged in — Home coming Day 3")
                    .onTapGesture {
                        Task { await authVM.logout() }
                    }
            } else {
                NavigationStack(path: $path) {
                    WelcomeView(path: $path)
                        .navigationDestination(for: OnboardingStep.self) { step in
                            switch step {

                            case .roleSelection:
                                RoleSelectionView(path: $path)

                            case .parentInfo:
                                ParentInfoView(path: $path)
                                    .environmentObject(authVM)

                            case .createPassword(let name, let email, let numberOfChildren):
                                CreatePasswordView(
                                    path: $path,
                                    name: name,
                                    email: email,
                                    numberOfChildren: numberOfChildren
                                )
                                .environmentObject(authVM)

                            case .addChild(let childIndex, let totalChildren):
                                AddChildView(
                                    path: $path,
                                    childIndex: childIndex,
                                    totalChildren: totalChildren
                                )
                                .environmentObject(authVM)

                            case .myChildren:
                                MyChildrenView(path: $path)

                            case .childPIN:
                                ChildPINView(path: $path)

                            case .allSet:
                                AllSetView(path: $path)
                                    .environmentObject(authVM)

                            case .login:
                                LoginView(path: $path)
                                    .environmentObject(authVM)

                            case .forgotPassword:
                                ForgotPasswordView(path: $path)
                                    .environmentObject(authVM)
                            }
                        }
                }
                .environmentObject(authVM)
                .task {
                    await authVM.checkSession()
                }
            }
        }
    }
}
