import Foundation

struct Habit: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var currentStreak: Int
    var recordStreak: Int
    var goal: Goal
    var lastCompletedDate: Date?
    
    // Add tracking for weekly completions
    var weeklyCompletions: [Date] = []
    
    // To track the previous record before today's completion
    var previousRecord: Int?
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isCompletedToday() -> Bool {
        guard let lastCompletedDate = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompletedDate)
    }
    
    // Get completed days for the current week
    func completedDaysThisWeek() -> [Weekday] {
        let calendar = Calendar.current
        let today = Date()
        
        // Find the start of the week (Sunday)
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        // Get all completions within this week
        return weeklyCompletions
            .filter { calendar.isDate($0, equalTo: today, toGranularity: .weekOfYear) }
            .map { Weekday.fromDate($0) }
    }
    
    // Get missed days (selected days that have already passed this week but weren't completed)
    func missedDaysThisWeek() -> [Weekday] {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = Weekday.fromDate(today).rawValue
        
        // Only consider days that have already passed (excluding today)
        // This ensures we don't show today as "missed" until the day is over
        let pastDays = Weekday.allCases.filter { $0.rawValue < todayWeekday }
        
        // Of the selected days that have passed, which ones weren't completed?
        let completedWeekdays = completedDaysThisWeek()
        return goal.selectedDays
            .filter { pastDays.contains($0) }
            .filter { !completedWeekdays.contains($0) }
    }
} 