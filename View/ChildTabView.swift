import SwiftUI


struct ChildTabView: View {
    @State private var selectedTab  = 0
    @State private var goals:       [Goal]         = []
    @State private var activity: [ChildActivityItem] = []
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ChildHomeView(
                    goals:    $goals,
                    activity: $activity)
                    .tabItem {
                        Image(systemName: selectedTab == 0
                              ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(0)

                JarsView()
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Jars")
                    }
                    .tag(1)

                GoalsView(
                    goals:    $goals,
                    activity: $activity,
                    onGoalAdded: {
                        withAnimation {
                            showConfetti = true
                        }
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 3) {
                            withAnimation {
                                showConfetti = false
                            }
                        }
                    })
                    .tabItem {
                        Image(systemName: "target")
                        Text("Goals")
                    }
                    .tag(2)
            }
            .tint(Color(hex: "1B3A6B"))

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { loadData() }
        .onChange(of: goals)    { _, _ in saveGoals() }
        .onChange(of: activity) { _, _ in saveActivity() }
    }

    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(
                encoded, forKey: "savedGoals")
        }
    }

    func saveActivity() {
        if let encoded = try? JSONEncoder().encode(activity) {
            UserDefaults.standard.set(
                encoded, forKey: "savedActivity")
        }
    }

    func loadData() {
        if let data = UserDefaults.standard.data(
            forKey: "savedGoals"),
           let decoded = try? JSONDecoder().decode(
            [Goal].self, from: data) {
            goals = decoded
        }
        if let data = UserDefaults.standard.data(
            forKey: "savedActivity"),
           let decoded = try? JSONDecoder().decode(
               [ChildActivityItem].self, from: data) {
               activity = decoded
        }
    }
}
