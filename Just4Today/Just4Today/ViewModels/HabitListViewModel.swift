import Foundation
import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // In a real app, we would load from persistent storage
        loadDemoData()
        
        // Check for streak resets at midnight
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAndResetStreaks()
            }
            .store(in: &cancellables)
    }
    
    func loadDemoData() {
        // Sample data for demonstration
        let calendar = Calendar.current
        let today = Date()
        
        // Create some past dates for demo purposes
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        
        var waterHabit = Habit(
            name: "Drink Water", 
            currentStreak: 5, 
            recordStreak: 12, 
            goal: Goal(type: .weekly, targetType: .timebound, 
                       selectedDays: [.monday, .wednesday, .friday], 
                       isLenientTracking: false, 
                       weeklyTargetWeeks: 4),
            previousRecord: nil
        )
        
        // Add demo completions for the current week
        // We'll add completions for Monday (and Wednesday if today is after Wednesday)
        if calendar.component(.weekday, from: today) > 1 { // If today is after Sunday
            waterHabit.weeklyCompletions.append(getDateForWeekday(.monday))
        }
        
        if calendar.component(.weekday, from: today) > 3 { // If today is after Tuesday
            // Missed Wednesday in this example
        }
        
        var readingHabit = Habit(
            name: "Read 10 Pages", 
            currentStreak: 2, 
            recordStreak: 8,
            goal: Goal(type: .justForToday),
            previousRecord: nil
        )
        
        var meditateHabit = Habit(
            name: "Meditate", 
            currentStreak: 0, 
            recordStreak: 5,
            goal: Goal(type: .totalDays, targetType: .timebound, 
                       isLenientTracking: true, totalDaysTarget: 100),
            previousRecord: nil
        )
        
        // Create an exercise habit that clearly shows missed days
        var exerciseHabit = Habit(
            name: "Exercise", 
            currentStreak: 3, 
            recordStreak: 15,
            goal: Goal(type: .weekly, targetType: .forever, 
                       selectedDays: [.monday, .wednesday, .friday, .saturday], 
                       isLenientTracking: true),
            previousRecord: nil
        )
        
        // Determine if we've passed Monday in the current week
        let todayWeekday = calendar.component(.weekday, from: today)
        let mondayHasPassed = todayWeekday > 2 // 2 is Monday
        let wednesdayHasPassed = todayWeekday > 4 // 4 is Wednesday
        
        // If we've passed Monday in this week, mark it as missed
        // (by not adding it to weeklyCompletions while it's in selectedDays)
        
        // Add completion for Tuesday (non-selected day, demonstrates lenient tracking)
        if todayWeekday > 3 { // If we've passed Tuesday
            exerciseHabit.weeklyCompletions.append(getDateForWeekday(.tuesday))
        }
        
        // If we've passed Wednesday, add it as completed (to show contrast with missed Monday)
        if wednesdayHasPassed {
            exerciseHabit.weeklyCompletions.append(getDateForWeekday(.wednesday))
        }
        
        // Set completion for reading habit
        if calendar.component(.weekday, from: today) == 3 { // If today is Tuesday
            readingHabit.lastCompletedDate = today
        }
        
        habits = [waterHabit, readingHabit, meditateHabit, exerciseHabit]
    }
    
    // Helper to get a date for a specific weekday in the current week
    private func getDateForWeekday(_ weekday: Weekday) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // Find the starting Sunday of this week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return today
        }
        
        // Add the appropriate number of days to get to the desired weekday
        return calendar.date(byAdding: .day, value: weekday.rawValue - 1, to: startOfWeek)!
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        let today = Date()
        
        if updatedHabit.isCompletedToday() {
            // Uncheck: Remove today's completion
            updatedHabit.lastCompletedDate = nil
            
            // Remove today from weekly completions
            let calendar = Calendar.current
            updatedHabit.weeklyCompletions.removeAll { completion in
                return calendar.isDate(completion, inSameDayAs: today)
            }
            
            // Decrement streak if this was the only streak day
            if updatedHabit.currentStreak > 0 {
                updatedHabit.currentStreak -= 1
            }
            
            // If there's a saved previous record and we completed today caused a record update
            // revert the record to the previous value
            if let previousRecord = updatedHabit.previousRecord {
                updatedHabit.recordStreak = previousRecord
                updatedHabit.previousRecord = nil // Clear the saved previous record
            }
        } else {
            // Check: Mark as completed today
            updatedHabit.lastCompletedDate = today
            
            // Add today to weekly completions
            updatedHabit.weeklyCompletions.append(today)
            
            updatedHabit.currentStreak += 1
            
            // Update record if needed
            if updatedHabit.currentStreak > updatedHabit.recordStreak {
                // Save the previous record before updating
                updatedHabit.previousRecord = updatedHabit.recordStreak
                updatedHabit.recordStreak = updatedHabit.currentStreak
            }
        }
        
        habits[index] = updatedHabit
    }
    
    func setRepeatOption(for habit: Habit, option: RepeatOption) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        updatedHabit.repeatOption = option
        
        switch option {
        case .tomorrow:
            // Set the goal type to .justForToday
            updatedHabit.goal.type = .justForToday
            
        case .forever:
            // Set the goal type to .totalDays with no target (continuous)
            updatedHabit.goal.type = .totalDays
            updatedHabit.goal.targetType = .forever
            updatedHabit.goal.totalDaysTarget = nil
            
        case .none:
            // Keep the current goal type, but ensure it's marked as completed for today
            break
        }
        
        habits[index] = updatedHabit
    }
    
    // This method is now deprecated, use toggleHabitCompletion instead
    func markHabitComplete(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        let now = Date()
        
        // Only update if not already completed today
        if !updatedHabit.isCompletedToday() {
            updatedHabit.lastCompletedDate = now
            updatedHabit.currentStreak += 1
            
            // Update record if needed
            if updatedHabit.currentStreak > updatedHabit.recordStreak {
                updatedHabit.recordStreak = updatedHabit.currentStreak
            }
            
            habits[index] = updatedHabit
        }
    }
    
    func resetStreak(for habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        updatedHabit.currentStreak = 0
        habits[index] = updatedHabit
    }
    
    func resetRecord(for habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        // Reset record to current streak instead of zero
        updatedHabit.recordStreak = updatedHabit.currentStreak
        habits[index] = updatedHabit
    }
    
    func overrideStreak(for habit: Habit, startDate: Date) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: Date())
        
        if let days = components.day, days >= 0 {
            updatedHabit.currentStreak = days
            
            // Update record if needed
            if updatedHabit.currentStreak > updatedHabit.recordStreak {
                updatedHabit.recordStreak = updatedHabit.currentStreak
            }
            
            habits[index] = updatedHabit
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
    
    private func checkAndResetStreaks() {
        let calendar = Calendar.current
        
        for i in 0..<habits.count {
            var habit = habits[i]
            
            // Skip "Just for Today" goals
            if habit.goal.type == .justForToday { continue }
            
            // Check if the habit is lenient tracking
            if habit.goal.isLenientTracking {
                // Check if the weekly quota was met for lenient tracking
                // For this sample, we'll skip the implementation
                continue
            }
            
            // For regular tracking, check if completed yesterday or today
            guard let lastCompleted = habit.lastCompletedDate else {
                // Never completed, no action needed
                continue
            }
            
            let isYesterday = calendar.isDateInYesterday(lastCompleted)
            let isToday = calendar.isDateInToday(lastCompleted)
            
            // If last completion is not yesterday or today, reset streak
            if !isYesterday && !isToday {
                habit.currentStreak = 0
                habits[i] = habit
            }
        }
    }
} 