import Foundation
import SwiftUI
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    private var cancellables = Set<AnyCancellable>()
    @ObservedObject private var dateSimulator = DateSimulator.shared
    private let calendar = Calendar.current
    
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
        
        // Listen for date simulation changes
        dateSimulator.$simulatedDate
            .sink { [weak self] _ in
                self?.checkAndResetStreaks()
            }
            .store(in: &cancellables)
    }
    
    func loadDemoData() {
        // Sample data for demonstration
        let calendar = Calendar.current
        let today = dateSimulator.isSimulationActive ? dateSimulator.currentDate : Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        
        // Create some past dates for demo purposes
        _ = calendar.date(byAdding: .day, value: -1, to: today)!
        _ = calendar.date(byAdding: .day, value: -2, to: today)!
        _ = calendar.date(byAdding: .day, value: -3, to: today)!
        
        // Call Dad habit - strict tracking
        var waterHabit = Habit(
            name: "Call Dad", 
            currentStreak: 0,
            recordStreak: 0, 
            goal: Goal(type: .weekly, targetType: .timebound, 
                       selectedDays: [.monday, .wednesday, .friday], 
                       isLenientTracking: false, 
                       weeklyTargetWeeks: 4),
            previousRecord: nil
        )
        
        // Add demo completions for the current week
        if todayWeekday > 1 { // If today is after Sunday
            waterHabit.weeklyCompletions.append(getDateForWeekday(.monday))
            waterHabit.currentStreak = 1
        }
        
        // Reading habit - daily task
        var readingHabit = Habit(
            name: "Read 10 Pages", 
            currentStreak: 0,
            recordStreak: 0,
            goal: Goal(type: .justForToday, targetType: .forever),
            previousRecord: nil
        )
        
        // Meditation habit - total days
        let meditateHabit = Habit(
            name: "Meditate", 
            currentStreak: 0,
            recordStreak: 0,
            goal: Goal(type: .totalDays, targetType: .timebound, 
                       isLenientTracking: true, totalDaysTarget: 100),
            previousRecord: nil
        )
        
        // Exercise habit - lenient tracking
        var exerciseHabit = Habit(
            name: "Exercise", 
            currentStreak: 0,
            recordStreak: 0,
            goal: Goal(type: .weekly, targetType: .forever, 
                       selectedDays: [.monday, .wednesday, .friday, .saturday], 
                       isLenientTracking: true),
            previousRecord: nil
        )
        
        // Add completions for exercise habit
        if todayWeekday > 3 { // If we've passed Tuesday
            exerciseHabit.weeklyCompletions.append(getDateForWeekday(.tuesday))
        }
        
        if todayWeekday > 4 { // If we've passed Wednesday
            exerciseHabit.weeklyCompletions.append(getDateForWeekday(.wednesday))
            exerciseHabit.currentStreak = 1
        }
        
        // Set completion for reading habit if today is Tuesday
        if todayWeekday == 3 { // If today is Tuesday
            readingHabit.lastCompletedDate = today
            readingHabit.currentStreak = 1
        }
        
        // Set up weekly habits to show up on their scheduled days
        if let currentWeekday = Weekday(rawValue: todayWeekday) {
            // For Call Dad (strict tracking)
            if waterHabit.goal.selectedDays.contains(currentWeekday) {
                waterHabit.lastCompletedDate = nil // Ensure it shows up in Today tab
            }
            
            // For Exercise (lenient tracking)
            if exerciseHabit.goal.selectedDays.contains(currentWeekday) {
                exerciseHabit.lastCompletedDate = nil // Ensure it shows up in Today tab
            }
        }
        
        habits = [waterHabit, readingHabit, meditateHabit, exerciseHabit]
    }
    
    // Helper to get a date for a specific weekday in the current week
    private func getDateForWeekday(_ weekday: Weekday) -> Date {
        let calendar = Calendar.current
        let today = dateSimulator.isSimulationActive ? dateSimulator.currentDate : Date()
        
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
        let today = dateSimulator.isSimulationActive ? dateSimulator.currentDate : Date()
        
        if updatedHabit.isCompletedToday() {
            // Uncheck: Remove today's completion
            updatedHabit.lastCompletedDate = nil
            
            // Remove today from weekly completions
            updatedHabit.weeklyCompletions.removeAll { completion in
                return calendar.isDate(completion, inSameDayAs: today)
            }
            
            // For weekly goals, check if this affects the current week's completion
            if updatedHabit.goal.type == .weekly {
                if let weekStart = updatedHabit.getCurrentWeekStart() {
                    // If the week was previously completed and now isn't, remove it from completed weeks
                    if !updatedHabit.isWeekCompleted(weekStart) {
                        updatedHabit.completedWeeks.removeAll { calendar.isDate($0, equalTo: weekStart, toGranularity: .weekOfYear) }
                    }
                }
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
            
            // For weekly goals, check if this completes the current week
            if updatedHabit.goal.type == .weekly {
                if let weekStart = updatedHabit.getCurrentWeekStart() {
                    if updatedHabit.isWeekCompleted(weekStart) {
                        // Add the week to completed weeks if not already there
                        if !updatedHabit.completedWeeks.contains(where: { calendar.isDate($0, equalTo: weekStart, toGranularity: .weekOfYear) }) {
                            updatedHabit.completedWeeks.append(weekStart)
                            
                            // Update record streak for weekly goals
                            let completedWeeksCount = updatedHabit.completedWeeks.count
                            if completedWeeksCount > updatedHabit.recordStreak {
                                // Save the previous record before updating
                                updatedHabit.previousRecord = updatedHabit.recordStreak
                                updatedHabit.recordStreak = completedWeeksCount
                            }
                        }
                    }
                    
                    // Update current streak for weekly goals
                    let weekday = calendar.component(.weekday, from: today)
                    if let currentWeekday = Weekday(rawValue: weekday) {
                        if updatedHabit.goal.isLenientTracking {
                            // For lenient tracking, simply increment/decrement based on completion
                            if updatedHabit.isCompletedToday() {
                                updatedHabit.currentStreak += 1
                            } else if updatedHabit.currentStreak > 0 {
                                updatedHabit.currentStreak -= 1
                            }
                        } else {
                            // For strict tracking, only increment if it's a selected day
                            if updatedHabit.goal.selectedDays.contains(currentWeekday) {
                                if updatedHabit.isCompletedToday() {
                                    updatedHabit.currentStreak += 1
                                } else if updatedHabit.currentStreak > 0 {
                                    updatedHabit.currentStreak -= 1
                                }
                            }
                        }
                    }
                }
            } else {
                // For non-weekly goals, increment streak as before
                if updatedHabit.isCompletedToday() {
                    updatedHabit.currentStreak += 1
                } else if updatedHabit.currentStreak > 0 {
                    updatedHabit.currentStreak -= 1
                }
                
                // Update record if needed
                if updatedHabit.currentStreak > updatedHabit.recordStreak {
                    // Save the previous record before updating
                    updatedHabit.previousRecord = updatedHabit.recordStreak
                    updatedHabit.recordStreak = updatedHabit.currentStreak
                }
            }
        }
        
        habits[index] = updatedHabit
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
        let today = dateSimulator.isSimulationActive ? dateSimulator.currentDate : Date()
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        
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
        _ = dateSimulator.isSimulationActive ? dateSimulator.currentDate : Date()
        
        for (index, habit) in habits.enumerated() {
            // Skip Daily Task goals
            if case .justForToday = habit.goal.type {
                continue
            }
            
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
            
            let isYesterday = dateSimulator.isSimulationActive ? 
                calendar.isDateInYesterday_Simulated(lastCompleted) : 
                calendar.isDateInYesterday(lastCompleted)
                
            let isToday = dateSimulator.isSimulationActive ? 
                calendar.isDateInToday_Simulated(lastCompleted) : 
                calendar.isDateInToday(lastCompleted)
            
            // If last completion is not yesterday or today, reset streak
            if !isYesterday && !isToday {
                var updatedHabit = habit
                updatedHabit.currentStreak = 0
                habits[index] = updatedHabit
            }
        }
    }
} 