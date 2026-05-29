import SwiftUI

enum GoalSheet: Identifiable {
    case setNew
    case edit(Goal)

    var id: String {
        switch self {
        case .setNew:      return "setNew"
        case .edit(let g): return "edit_\(g.id)"
        }
    }
}

struct GoalsView: View {

    @Binding var goals:    [Goal]
    @Binding var activity: [ActivityItem]
    var onGoalAdded:       () -> Void
    @State private var activeSheet: GoalSheet?
    let maxGoals = 5

    let goalIdeas: [(String, String)] = [
        ("📚", "Books"),
        ("🚲", "Bike"),
        ("✈️", "Trip"),
        ("🎧", "AirPods"),
    ]

    var body: some View {
        ZStack {
            Color(hex: "EEF2F8").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    HStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(
                                size: 20,
                                weight: .semibold))
                            .foregroundColor(Color(hex: "185FA5"))
                        Text("My Goal")
                            .font(.system(
                                size: 22,
                                weight: .bold,
                                design: .rounded))
                            .foregroundColor(Color(hex: "185FA5"))
                    }
                    .frame(maxWidth: .infinity,
                           alignment: .center)
                    .padding(.top, 20)

                    if goals.isEmpty {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "E8EDF5"))
                                    .frame(width: 64, height: 64)
                                Image(systemName: "target")
                                    .font(.system(
                                        size: 28,
                                        weight: .medium))
                                    .foregroundColor(
                                        Color(hex: "185FA5"))
                            }
                            Text("No goal yet")
                                .font(.system(
                                    size: 16,
                                    weight: .semibold,
                                    design: .rounded))
                                .foregroundColor(
                                    Color(hex: "1B3A6B"))
                            Text("Set a goal and start saving\ntoward something you love!")
                                .font(.system(
                                    size: 13,
                                    design: .rounded))
                                .foregroundColor(
                                    Color(hex: "8A9BB0"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 20)

                    } else {
                        let visibleGoals = Array(
                            goals.prefix(maxGoals))
                        let hiddenCount =
                            goals.count - visibleGoals.count

                        ForEach(
                            Array(visibleGoals.enumerated()),
                            id: \.element.id
                        ) { index, goal in
                            goalCard(goal: goal, index: index)
                        }

                        if hiddenCount > 0 {
                            HStack(spacing: 10) {
                                Image(systemName:
                                    "archivebox.fill")
                                    .foregroundColor(
                                        Color(hex: "185FA5"))
                                    .font(.system(size: 16))
                                VStack(alignment: .leading,
                                       spacing: 2) {
                                    Text("\(hiddenCount) more goal\(hiddenCount > 1 ? "s" : "") waiting")
                                        .font(.system(
                                            size: 14,
                                            weight: .semibold,
                                            design: .rounded))
                                        .foregroundColor(
                                            Color(hex: "1B3A6B"))
                                    Text("Delete a goal above to see the next one")
                                        .font(.system(
                                            size: 12,
                                            design: .rounded))
                                        .foregroundColor(
                                            Color(hex: "8A9BB0"))
                                }
                                Spacer()
                                Text("\(goals.count) total")
                                    .font(.system(
                                        size: 12,
                                        weight: .semibold,
                                        design: .rounded))
                                    .foregroundColor(
                                        Color(hex: "185FA5"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Color(hex: "EBF4FF"))
                                    .cornerRadius(10)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                    }

                    // Next goal ideas
                    VStack(alignment: .leading, spacing: 14) {
                        Text("NEXT GOAL IDEAS")
                            .font(.system(
                                size: 12,
                                weight: .semibold,
                                design: .rounded))
                            .foregroundColor(Color(hex: "8A9BB0"))
                            .tracking(1.2)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal,
                                   showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(goalIdeas,
                                        id: \.1) { idea in
                                    Button {
                                        activeSheet = .setNew
                                    } label: {
                                        VStack(spacing: 8) {
                                            Text(idea.0)
                                                .font(.system(
                                                    size: 32))
                                            Text(idea.1)
                                                .font(.system(
                                                    size: 12,
                                                    design:
                                                        .rounded))
                                                .foregroundColor(
                                                    Color(hex:
                                                        "1B3A6B"))
                                        }
                                        .frame(width: 88,
                                               height: 88)
                                        .background(
                                            Color(hex: "E0E6EF"))
                                        .cornerRadius(18)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Button {
                        activeSheet = .setNew
                    } label: {
                        Text("+ Set New Goal")
                            .font(.system(
                                size: 16,
                                weight: .semibold,
                                design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(hex: "185FA5"))
                            .cornerRadius(27)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .setNew:
                SetGoalView { newGoal in
                    goals.append(newGoal)
                    let item = ActivityItem(
                        name:      "New goal: \(newGoal.name)",
                        amount:    0,
                        jarColor:  "blue",
                        sfSymbol:  "target")
                    activity.insert(item, at: 0)
                    onGoalAdded()
                }

            case .edit(let goal):
                if let index = goals.firstIndex(
                    where: { $0.id == goal.id }) {
                    EditGoalView(
                        goal: $goals[index],
                        onSave: { editedGoal in
                            let item = ActivityItem(
                                name:      "Edited goal: \(editedGoal.name)",
                                amount:    0,
                                jarColor:  "purple",
                                sfSymbol:  "pencil")
                            activity.insert(item, at: 0)
                        })
                }
            }
        }
    }

    func goalCard(goal: Goal, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                    GoalIconView(icon: goal.icon, size: 32)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.name)
                        .font(.system(
                            size: 18,
                            weight: .bold,
                            design: .rounded))
                        .foregroundColor(.white)
                    Text("goal: \(Int(goal.target)) SAR")
                        .font(.system(
                            size: 13,
                            design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                }
                Spacer()
                Button {
                    activeSheet = .edit(goal)
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            HStack {
                Text("\(Int(goal.saved)) SAR")
                    .font(.system(
                        size: 22,
                        weight: .bold,
                        design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(goal.percent)%")
                    .font(.system(
                        size: 22,
                        weight: .bold,
                        design: .rounded))
                    .foregroundColor(.white)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "5B9BD5"))
                        .frame(
                            width: geo.size.width
                            * goal.progress,
                            height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("saved: \(Int(goal.saved))")
                    .font(.system(
                        size: 12,
                        design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
                Spacer()
                Text("\(Int(goal.target - goal.saved)) SAR to go!")
                    .font(.system(
                        size: 12,
                        design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
            }

            MilestoneDots(progress: goal.progress)

            Button {
                withAnimation {
                    let item = ActivityItem(
                        name:      "Deleted goal: \(goal.name)",
                        amount:    0,
                        jarColor:  "red",
                        sfSymbol:  "trash")
                    activity.insert(item, at: 0)
                    var i = index
                    goals.remove(at: i)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                    Text("Delete goal")
                        .font(.system(
                            size: 13,
                            weight: .medium,
                            design: .rounded))
                }
                .foregroundColor(Color(hex: "E05555"))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
            }
        }
        .padding(20)
        .background(Color(hex: "1B3A6B"))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

// ── Milestone dots ───────────────────────
struct MilestoneDots: View {
    let progress: Double
    let milestones = ["Start", "50%", "75%", "Done!"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(milestones.enumerated()),
                    id: \.offset) { i, milestone in
                VStack(spacing: 6) {
                    Circle()
                        .fill(dotColor(index: i))
                        .frame(width: 18, height: 18)
                    Text(milestone)
                        .font(.system(
                            size: 10,
                            design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                if i < milestones.count - 1 {
                    Rectangle()
                        .fill(lineColor(index: i))
                        .frame(height: 3)
                        .padding(.bottom, 20)
                }
            }
        }
    }

    func dotColor(index: Int) -> Color {
        let thresholds: [Double] = [0.0, 0.5, 0.75, 1.0]
        guard progress >= thresholds[index] else {
            return Color.white.opacity(0.3)
        }
        if index == 1 && progress >= 0.5
            && progress < 0.75 {
            return Color(hex: "F5C842")
        }
        if index == 2 && progress >= 0.75
            && progress < 1.0 {
            return Color(hex: "F5C842")
        }
        if index == 3 && progress >= 1.0 {
            return Color(hex: "F5C842")
        }
        return Color(hex: "4CAF50")
    }

    func lineColor(index: Int) -> Color {
        let thresholds: [Double] = [0.0, 0.5, 0.75]
        return progress > thresholds[index]
            ? Color(hex: "4CAF50")
            : Color.white.opacity(0.2)
    }
}
