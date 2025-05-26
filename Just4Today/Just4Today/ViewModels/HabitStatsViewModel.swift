import Foundation

class HabitStatsViewModel: ObservableObject {
    @Published var habit: Habit
    private let onDelete: () -> Void
    private let onResetRecord: () -> Void
    private let onOverrideStreak: (Date) -> Void
    
    init(habit: Habit,
         onDelete: @escaping () -> Void,
         onResetRecord: @escaping () -> Void,
         onOverrideStreak: @escaping (Date) -> Void) {
        self.habit = habit
        self.onDelete = onDelete
        self.onResetRecord = onResetRecord
        self.onOverrideStreak = onOverrideStreak
    }
    
    // MARK: - Computed Properties
    
    var selectedDaysText: String {
        guard habit.goal.type == .weekly else { return "N/A" }
        return habit.goal.selectedDays
            .sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortName }
            .joined(separator: ", ")
    }
    
    var completedDaysThisWeek: [Weekday] {
        guard habit.goal.type == .weekly else { return [] }
        let calendar = Calendar.current
        return habit.weeklyCompletions
            .filter { calendar.isDateInThisWeek($0) }
            .compactMap { Weekday(rawValue: calendar.component(.weekday, from: $0)) }
    }
    
    var missedDaysThisWeek: [Weekday] {
        guard habit.goal.type == .weekly else { return [] }
        let completedSet = Set(completedDaysThisWeek)
        let selectedSet = Set(habit.goal.selectedDays)
        return Array(selectedSet.subtracting(completedSet))
    }
    
    var weeklyCompletionRate: String {
        guard habit.goal.type == .weekly else { return "N/A" }
        let completed = completedDaysThisWeek.count
        let total = habit.goal.selectedDays.count
        guard total > 0 else { return "0%" }
        return "\(Int((Double(completed) / Double(total)) * 100))%"
    }
    
    var goalTypeDescription: String {
        switch habit.goal.type {
        case .justForToday:
            return "Daily Task"
        case .weekly:
            return "Weekly Goal"
        case .totalDays:
            if habit.goal.targetType == .forever {
                return "Continuous"
            } else {
                return "Total Days Goal"
            }
        }
    }
    
    // MARK: - Actions
    
    func deleteHabit() {
        onDelete()
    }
    
    func resetRecord() {
        onResetRecord()
    }
    
    func overrideStreak(_ date: Date) {
        onOverrideStreak(date)
    }
}

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        if DateSimulator.shared.isSimulationActive {
            return isDate(date, equalTo: DateSimulator.shared.currentDate, toGranularity: .weekOfYear)
        } else {
            return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        }
    }
} 