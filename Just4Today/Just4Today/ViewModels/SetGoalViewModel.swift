import Foundation
import SwiftUI
import Combine

class SetGoalViewModel: ObservableObject {
    @Published var goalType: GoalType = .justForToday
    @Published var targetType: TargetType = .timebound
    @Published var selectedDays: Set<Weekday> = []
    @Published var isLenientTracking: Bool = false
    @Published var weeklyTargetWeeks: String = ""
    @Published var totalDaysTarget: String = ""
    
    // Original values to support cancel behavior
    private var originalGoal: Goal
    private var originalHabit: Habit?
    
    // Validation state
    @Published var isValidGoal: Bool = true
    @Published var validationMessage: String = ""
    
    init(habit: Habit? = nil) {
        self.originalHabit = habit
        
        if let habit = habit {
            self.originalGoal = habit.goal
            self.loadFromHabit(habit)
        } else {
            self.originalGoal = Goal.defaultGoal
        }
    }
    
    func loadFromHabit(_ habit: Habit) {
        goalType = habit.goal.type
        targetType = habit.goal.targetType
        selectedDays = Set(habit.goal.selectedDays)
        isLenientTracking = habit.goal.isLenientTracking
        
        if let weeks = habit.goal.weeklyTargetWeeks {
            weeklyTargetWeeks = "\(weeks)"
        }
        
        if let totalDays = habit.goal.totalDaysTarget {
            totalDaysTarget = "\(totalDays)"
        }
    }
    
    func resetToDefaults() {
        goalType = .justForToday
        targetType = .timebound
        selectedDays = []
        isLenientTracking = false
        weeklyTargetWeeks = ""
        totalDaysTarget = ""
        validateGoal()
    }
    
    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
        validateGoal()
    }
    
    func validateGoal() {
        // Just for Today is always valid
        if goalType == .justForToday {
            isValidGoal = true
            validationMessage = ""
            return
        }
        
        // Weekly goals need day selection
        if goalType == .weekly && selectedDays.isEmpty {
            isValidGoal = false
            validationMessage = "Please select at least one day of the week"
            return
        }
        
        // If Target is Forever, we don't need additional validation
        if targetType == .forever {
            isValidGoal = true
            validationMessage = ""
            return
        }
        
        // Check target-specific validation
        switch goalType {
        case .weekly:
            let hasWeeks = !weeklyTargetWeeks.isEmpty && Int(weeklyTargetWeeks) != nil
            isValidGoal = hasWeeks
            
            if !hasWeeks {
                validationMessage = "Please enter the number of weeks"
            } else {
                validationMessage = ""
            }
            
        case .totalDays:
            let hasTotalDays = !totalDaysTarget.isEmpty && Int(totalDaysTarget) != nil
            isValidGoal = hasTotalDays
            
            if !hasTotalDays {
                validationMessage = "Please enter the total number of days"
            } else {
                validationMessage = ""
            }
            
        default:
            // Handle all other cases
            isValidGoal = true
            validationMessage = ""
        }
    }
    
    func createGoal() -> Goal? {
        validateGoal()
        
        guard isValidGoal else {
            return nil
        }
        
        // Only set numeric values if target type is timebound and relevant to the goal type
        let weeklyWeeks = targetType == .timebound && goalType == .weekly ? Int(weeklyTargetWeeks) : nil
        let totalDays = targetType == .timebound && goalType == .totalDays ? Int(totalDaysTarget) : nil
        
        // For total days goal type, don't require day selection
        let days = goalType == .weekly ? Array(selectedDays) : []
        
        return Goal(
            type: goalType,
            targetType: targetType,
            selectedDays: days,
            isLenientTracking: isLenientTracking,
            weeklyTargetWeeks: weeklyWeeks,
            totalDaysTarget: totalDays
        )
    }
} 