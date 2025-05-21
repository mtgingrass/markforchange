import Foundation

struct Habit: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var currentStreak: Int
    var recordStreak: Int
    var goal: Goal
    var lastCompletedDate: Date?
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isCompletedToday() -> Bool {
        guard let lastCompletedDate = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompletedDate)
    }
} 