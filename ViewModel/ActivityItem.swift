import SwiftUI
import Combine

// ─────────────────────────────────────────────
// MARK: - Activity Item
// ─────────────────────────────────────────────
struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let meta: String
    let isToday: Bool
}

// ─────────────────────────────────────────────
// MARK: - Allowance Schedule (for reminder)
// ─────────────────────────────────────────────
struct AllowanceSchedule {
    let childName: String
    let nextDueDate: Date
}

// ─────────────────────────────────────────────
// MARK: - ParentViewModel
// ─────────────────────────────────────────────
@MainActor
final class ParentViewModel: ObservableObject {

    @Published var parentName: String = "MOM"
    @Published var balance: Double    = 0
    @Published var activeChildren: Int = 0
    @Published var moneySent: Double   = 0
    @Published var activeGoals: Int    = 0
    @Published var activity: [ActivityItem] = []
    @Published var allowanceSchedule: AllowanceSchedule? = nil

    // ── Reminder logic ─────────────────────
    var reminderText: String? {
        guard let schedule = allowanceSchedule else { return nil }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to:   Calendar.current.startOfDay(for: schedule.nextDueDate)
        ).day ?? 999

        switch days {
        case 0:  return "\(schedule.childName)'s allowance is due today!"
        case 1:  return "\(schedule.childName)'s allowance is due tomorrow"
        case 2:  return "\(schedule.childName)'s allowance is due in 2 days"
        default: return nil
        }
    }

    // ── Add money to own balance ────────────
    // Does NOT update moneySent
    func addToBalance(_ amount: Double) {
        balance += amount
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        activity.insert(ActivityItem(
            title:   "You added \(formatted) SAR to balance",
            meta:    "Today · Just now",
            isToday: true
        ), at: 0)
    }

    // ── Send money to child ─────────────────
    // Updates moneySent + balance + activity
    func sendMoney(to childName: String, amount: Double, type: String) {
        balance    -= amount
        moneySent  += amount
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        activity.insert(ActivityItem(
            title:   "You transferred \(formatted) SAR to \(childName)",
            meta:    "Today · \(type)",
            isToday: true
        ), at: 0)
    }

    // ── Set reminder schedule ───────────────
    func setReminder(childName: String, nextDueDate: Date) {
        allowanceSchedule = AllowanceSchedule(
            childName:   childName,
            nextDueDate: nextDueDate
        )
        activity.insert(ActivityItem(
            title:   "You set up a reminder",
            meta:    "Today · \(childName)",
            isToday: true
        ), at: 0)
    }

    // ── Demo data loader ────────────────────
    func loadFakeData() {
        balance        = 1900
        moneySent      = 1000
        activeChildren = 3
        activeGoals    = 3
        activity = [
            ActivityItem(title: "You added 500 SAR to balance",     meta: "Today · 10 min ago",               isToday: true),
            ActivityItem(title: "You transferred 50 SAR to Shahad", meta: "Today · Allowance",                isToday: true),
            ActivityItem(title: "Shahad set up a goal",              meta: "Yesterday · PlayStation · 150 SAR", isToday: false),
            ActivityItem(title: "Shahad achieved her goal",          meta: "Yesterday · PlayStation",          isToday: false),
            ActivityItem(title: "You set up a reminder",             meta: "Mon · Every Thursday · weekly",    isToday: false),
            ActivityItem(title: "You sent Eidiya to all children",   meta: "Last week · 300 SAR",              isToday: false),
        ]
        allowanceSchedule = AllowanceSchedule(
            childName:   "Shahad",
            nextDueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        )
    }
}
