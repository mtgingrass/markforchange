import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    var onToggleCompletion: () -> Void
    var onEdit: () -> Void
    var onResetStreak: () -> Void
    var onResetRecord: () -> Void
    var onOverrideStreak: (Date) -> Void
    var onDelete: () -> Void
    
    @State private var showingResetStreakConfirmation = false
    @State private var showingResetRecordConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @State private var showingStats = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(habit.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.primary)
                        .shadow(color: .primary.opacity(0.1), radius: 1, x: 0, y: 1)
                    
                    HStack(spacing: 4) {
                        if habit.goal.type == .weekly {
                            // Weekly streak
                            Text("\(habit.completedWeeks.count)")
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundColor(.blue)
                            Text("\(habit.completedWeeks.count == 1 ? "week" : "weeks")")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            // Daily streak
                            Text("\(habit.currentStreak)")
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundColor(.blue)
                            Text("\(habit.currentStreak == 1 ? "day" : "days")")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            // Regular streak display for non-weekly goals
                            Text("\(habit.currentStreak)")
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundColor(.blue)
                            Text("\(habit.currentStreak == 1 ? "day" : "days")")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    onToggleCompletion()
                }) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 3)
                            .frame(width: 44, height: 44)
                            .foregroundColor(habit.isCompletedToday() ? .green : .primary.opacity(0.6))
                            .background(
                                Circle()
                                    .fill(habit.isCompletedToday() ? Color.green.opacity(0.15) : Color.clear)
                            )
                            
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(habit.isCompletedToday() ? .green : .primary.opacity(0.15))
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack(spacing: 20) {
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5)
                        .opacity(0.3)
                        .foregroundColor(progressColor.opacity(0.5))
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0.0, to: min(progressValue, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .foregroundColor(progressColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .frame(width: 50, height: 50)
                        .animation(.linear, value: progressValue)
                    
                    if habit.goal.type == .justForToday {
                        Image(systemName: habit.isCompletedToday() ? "star.fill" : "star")
                            .font(.system(size: 18))
                            .foregroundColor(habit.isCompletedToday() ? .yellow : .gray)
                    } else {
                        Text("\(Int(progressValue * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(progressColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    // Goal description
                    Text(goalTitle)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    if habit.goal.type == .weekly {
                        HStack {
                            Text(habit.goal.isLenientTracking ? "Lenient Tracking" : "Strict Tracking")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        WeeklyProgressView(
                            selectedDays: habit.goal.selectedDays,
                            completedDays: habit.completedDaysThisWeek(),
                            missedDays: habit.missedDaysThisWeek()
                        )
                    }
                    
                    HStack(spacing: 4) {
                        Text("Record:")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                        Text("\(habit.recordStreak)")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.purple)
                        Text(habit.goal.type == .weekly ? 
                            "\(habit.recordStreak == 1 ? "week" : "weeks")" :
                            "\(habit.recordStreak == 1 ? "day" : "days")")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 12)
        .swipeActions(edge: .leading) {
            Button {
                onEdit()
            } label: {
                Text("Set\nGoal")
                    .multilineTextAlignment(.center)
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            Button {
                showingResetStreakConfirmation = true
            } label: {
                Text("Reset\nStreak")
                    .multilineTextAlignment(.center)
            }
            .tint(.yellow)
        }
        .alert("Reset Streak?", isPresented: $showingResetStreakConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                onResetStreak()
            }
        } message: {
            Text("This will reset your current streak to 0. This action cannot be undone.")
        }
        .sheet(isPresented: $showingStats) {
            HabitStatsView(
                habit: habit,
                onDelete: onDelete,
                onResetRecord: onResetRecord,
                onOverrideStreak: { date in
                    onOverrideStreak(date)
                }
            )
        }
    }
    
    // Progress Circle based on goal type
    private var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .opacity(0.3)
                .foregroundColor(progressColor.opacity(0.5))
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0.0, to: min(progressValue, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .frame(width: 40, height: 40)
                .animation(.linear, value: progressValue)
            
            if habit.goal.type == .justForToday {
                Image(systemName: habit.isCompletedToday() ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundColor(habit.isCompletedToday() ? .yellow : .gray)
            } else {
                Text("\(Int(progressValue * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(progressColor)
            }
        }
    }
    
    // Goal description text
    private var goalDescriptionView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(goalTitle)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.7))
            
            if habit.goal.type == .weekly {
                WeeklyProgressView(
                    selectedDays: habit.goal.selectedDays,
                    completedDays: habit.completedDaysThisWeek(),
                    missedDays: habit.missedDaysThisWeek()
                )
            }
            
            Text(goalDetail)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // Progress value between 0 and 1
    private var progressValue: Double {
        switch habit.goal.type {
        case .justForToday:
            return habit.isCompletedToday() ? 1.0 : 0.0
            
        case .weekly:
            let completedDays = habit.completedDaysThisWeek().count
            let targetDays = habit.goal.selectedDays.count
            return targetDays > 0 ? Double(completedDays) / Double(targetDays) : 0
            
        case .totalDays:
            if let totalTarget = habit.goal.totalDaysTarget, totalTarget > 0 {
                return min(Double(habit.currentStreak) / Double(totalTarget), 1.0)
            }
            return Double(habit.currentStreak) / 100.0 // Default to 100 days if no target
        }
    }
    
    // Dynamic color for progress
    private var progressColor: Color {
        if progressValue < 0.3 {
            return .red
        } else if progressValue < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    // Title describing the goal type
    private var goalTitle: String {
        switch habit.goal.type {
        case .justForToday:
            if habit.goal.targetType == .timebound, let target = habit.goal.totalDaysTarget {
                return "Total Days: \(habit.currentStreak)/\(target)"
            } else if habit.goal.targetType == .forever {
                return "Total Days: \(habit.currentStreak)/∞"
            }
            return "Daily Task"
            
        case .weekly:
            return ""
            
        case .totalDays:
            if habit.goal.targetType == .timebound, let target = habit.goal.totalDaysTarget {
                return "Total Days: \(habit.currentStreak)/\(target)"
            } else if habit.goal.targetType == .forever {
                return "Total Days: \(habit.currentStreak)/∞"
            }
            return "Total Days Progress"
        }
    }
    
    // Additional details about the goal
    private var goalDetail: String {
        switch habit.goal.type {
        case .justForToday:
            if habit.goal.targetType == .timebound, let target = habit.goal.totalDaysTarget {
                let remaining = max(0, target - habit.currentStreak)
                return "\(remaining) days remaining to goal"
            } else if habit.goal.targetType == .forever {
                return "Track your progress over time"
            }
            return "Complete this once today"
            
        case .weekly:
            if habit.goal.isLenientTracking {
                return "Lenient tracking: Any \(habit.goal.selectedDays.count) days per week"
            } else {
                return "Strict tracking: On selected days only"
            }
            
        case .totalDays:
            if habit.goal.targetType == .timebound, let target = habit.goal.totalDaysTarget {
                let remaining = max(0, target - habit.currentStreak)
                return "\(remaining) days remaining to goal"
            } else if habit.goal.targetType == .forever {
                return "Track your progress over time"
            }
            return "Track your progress over time"
        }
    }
}

struct HabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            HabitRowView(
                habit: Habit(
                    name: "Drink Water",
                    currentStreak: 5,
                    recordStreak: 12,
                    goal: Goal(type: .weekly, selectedDays: [.monday, .wednesday, .friday], isLenientTracking: false)
                ),
                onToggleCompletion: {},
                onEdit: {},
                onResetStreak: {},
                onResetRecord: {},
                onOverrideStreak: { _ in },
                onDelete: {}
            )
            
            HabitRowView(
                habit: Habit(
                    name: "Read 10 Pages",
                    currentStreak: 2,
                    recordStreak: 8,
                    goal: Goal(type: .justForToday)
                ),
                onToggleCompletion: {},
                onEdit: {},
                onResetStreak: {},
                onResetRecord: {},
                onOverrideStreak: { _ in },
                onDelete: {}
            )
            
            HabitRowView(
                habit: Habit(
                    name: "Meditate",
                    currentStreak: 25,
                    recordStreak: 30,
                    goal: Goal(type: .totalDays, targetType: .timebound, isLenientTracking: true, totalDaysTarget: 100)
                ),
                onToggleCompletion: {},
                onEdit: {},
                onResetStreak: {},
                onResetRecord: {},
                onOverrideStreak: { _ in },
                onDelete: {}
            )
        }
    }
} 