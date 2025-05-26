import Foundation
import SwiftUI

/// DateSimulator - A utility for simulating different dates in the app for testing purposes
class DateSimulator: ObservableObject {
    static let shared = DateSimulator()
    
    @Published var simulatedDate: Date?
    @Published var isSimulationActive: Bool = false
    
    // Current date, either simulated or actual
    var currentDate: Date {
        simulatedDate ?? Date()
    }
    
    // Reset simulation and return to using actual date
    func resetSimulation() {
        simulatedDate = nil
        isSimulationActive = false
    }
    
    // Set a specific simulated date
    func setSimulatedDate(to date: Date) {
        simulatedDate = date
        isSimulationActive = true
    }
    
    // Advance the simulated date by one day
    func advanceOneDay() {
        let date = simulatedDate ?? Date()
        simulatedDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        isSimulationActive = true
    }
    
    // Move to a specific day of the week
    func moveToWeekday(_ weekday: Weekday) {
        let calendar = Calendar.current
        let today = simulatedDate ?? Date()
        let currentWeekday = calendar.component(.weekday, from: today)
        let targetWeekday = weekday.rawValue
        
        // Calculate days to add
        var daysToAdd = targetWeekday - currentWeekday
        if daysToAdd <= 0 {
            // Move to next week if target day has already passed or is today
            daysToAdd += 7
        }
        
        simulatedDate = calendar.date(byAdding: .day, value: daysToAdd, to: today)
        isSimulationActive = true
    }
}

// Extension to provide Date functionality that respects simulation
extension Date {
    static func simulatedNow() -> Date {
        return DateSimulator.shared.currentDate
    }
}

// Extension to Calendar to respect simulated dates
extension Calendar {
    func isDateInToday_Simulated(_ date: Date) -> Bool {
        return isDate(date, inSameDayAs: DateSimulator.shared.currentDate)
    }
    
    func isDateInYesterday_Simulated(_ date: Date) -> Bool {
        guard let yesterday = self.date(byAdding: .day, value: -1, to: DateSimulator.shared.currentDate) else {
            return false
        }
        return isDate(date, inSameDayAs: yesterday)
    }
} 