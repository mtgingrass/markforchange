import Foundation

enum GoalType: String, Codable, CaseIterable, Identifiable {
    case justForToday
    case weekly
    case totalDays
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .justForToday: return "Daily Task"
        case .weekly: return "Weekly Target"
        case .totalDays: return "Total Days Target"
        }
    }
}

enum TargetType: String, Codable, CaseIterable, Identifiable {
    case timebound
    case forever
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .timebound: return "For a specific time"
        case .forever: return "Ongoing (Forever)"
        }
    }
}

struct Goal: Codable, Equatable {
    var type: GoalType
    var targetType: TargetType
    var selectedDays: [Weekday]
    var isLenientTracking: Bool
    var weeklyTargetWeeks: Int?
    var totalDaysTarget: Int?
    
    init(type: GoalType = .justForToday,
         targetType: TargetType = .timebound,
         selectedDays: [Weekday] = [],
         isLenientTracking: Bool = false,
         weeklyTargetWeeks: Int? = nil,
         totalDaysTarget: Int? = nil) {
        self.type = type
        self.targetType = targetType
        self.selectedDays = selectedDays
        self.isLenientTracking = isLenientTracking
        self.weeklyTargetWeeks = weeklyTargetWeeks
        self.totalDaysTarget = totalDaysTarget
    }
    
    static let defaultGoal = Goal(type: .justForToday)
}

enum Weekday: Int, Codable, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    static func fromDate(_ date: Date) -> Weekday {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: weekdayNumber) ?? .sunday
    }
    
    static var today: Weekday {
        return fromDate(Date())
    }
} 