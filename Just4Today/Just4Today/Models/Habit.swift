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
    
    // Track completed weeks for weekly goals
    var completedWeeks: [Date] = []
    
    // To track the previous record before today's completion
    var previousRecord: Int?
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        let today = DateSimulator.shared.isSimulationActive ? DateSimulator.shared.currentDate : Date()
        
        // Check lastCompletedDate
        if let lastCompletedDate = lastCompletedDate {
            if calendar.isDate(lastCompletedDate, inSameDayAs: today) {
                return true
            }
        }
        
        // Check weeklyCompletions
        return weeklyCompletions.contains { calendar.isDate($0, inSameDayAs: today) }
    }
    
    // Get completed days for the current week
    func completedDaysThisWeek() -> [Weekday] {
        let calendar = Calendar.current
        let today = DateSimulator.shared.isSimulationActive ? DateSimulator.shared.currentDate : Date()
        
        // Find the start of the week (Sunday)
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        // Get all completions within this week
        return weeklyCompletions
            .filter { calendar.isDate($0, equalTo: startOfWeek, toGranularity: .weekOfYear) }
            .map { Weekday.fromDate($0) }
    }
    
    // Check if a week was completed successfully
    func isWeekCompleted(_ weekStartDate: Date) -> Bool {
        guard goal.type == .weekly else { return false }
        
        let calendar = Calendar.current
        let weekEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate)!
        
        // Get all completions for this week
        let weekCompletions = weeklyCompletions.filter { completion in
            completion >= weekStartDate && completion <= weekEndDate
        }
        
        if goal.isLenientTracking {
            // For lenient tracking, just need to meet the target number of completions
            return weekCompletions.count >= goal.selectedDays.count
        } else {
            // For strict tracking, need to complete all selected days
            let completedDays = Set(weekCompletions.map { Weekday.fromDate($0) })
            let selectedDays = Set(goal.selectedDays)
            return selectedDays.isSubset(of: completedDays)
        }
    }
    
    // Get the start date of the current week
    func getCurrentWeekStart() -> Date? {
        let calendar = Calendar.current
        let today = DateSimulator.shared.isSimulationActive ? DateSimulator.shared.currentDate : Date()
        
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))
    }
    
    // Get the start date of a specific week
    func getWeekStart(for date: Date) -> Date? {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))
    }
    
    // Get missed days (selected days that have already passed this week but weren't completed)
    func missedDaysThisWeek() -> [Weekday] {
        let calendar = Calendar.current
        let today = DateSimulator.shared.isSimulationActive ? DateSimulator.shared.currentDate : Date()
        
        // Find the start of the week (Sunday)
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        // Get all selected days that have already passed this week
        let passedSelectedDays = goal.selectedDays.filter { weekday in
            let weekdayDate = calendar.date(byAdding: .day, value: weekday.rawValue - 1, to: startOfWeek)!
            return weekdayDate <= today
        }
        
        // Get all completions within this week
        let completedDays = weeklyCompletions
            .filter { calendar.isDate($0, equalTo: today, toGranularity: .weekOfYear) }
            .map { Weekday.fromDate($0) }
        
        // Return selected days that have passed but weren't completed
        return passedSelectedDays.filter { !completedDays.contains($0) }
    }
} 