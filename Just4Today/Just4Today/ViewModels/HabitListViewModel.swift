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
        habits = [
            Habit(name: "Drink Water", currentStreak: 5, recordStreak: 12, 
                  goal: Goal(type: .weekly, targetType: .timebound, selectedDays: [.monday, .wednesday, .friday], isLenientTracking: false, weeklyTargetWeeks: 4)),
            Habit(name: "Read 10 Pages", currentStreak: 2, recordStreak: 8,
                  goal: Goal(type: .justForToday)),
            Habit(name: "Meditate", currentStreak: 0, recordStreak: 5,
                  goal: Goal(type: .totalDays, targetType: .timebound, isLenientTracking: true, totalDaysTarget: 100)),
            Habit(name: "Exercise", currentStreak: 3, recordStreak: 15,
                  goal: Goal(type: .weekly, targetType: .forever, selectedDays: [.monday, .wednesday, .friday, .saturday], isLenientTracking: true))
        ]
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        
        var updatedHabit = habit
        
        if updatedHabit.isCompletedToday() {
            // Uncheck: Remove today's completion
            updatedHabit.lastCompletedDate = nil
            // Decrement streak if this was the only streak day
            if updatedHabit.currentStreak > 0 {
                updatedHabit.currentStreak -= 1
            }
        } else {
            // Check: Mark as completed today
            updatedHabit.lastCompletedDate = Date()
            updatedHabit.currentStreak += 1
            
            // Update record if needed
            if updatedHabit.currentStreak > updatedHabit.recordStreak {
                updatedHabit.recordStreak = updatedHabit.currentStreak
            }
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
        updatedHabit.recordStreak = 0
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