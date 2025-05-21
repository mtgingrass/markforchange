import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    var onToggleCompletion: () -> Void
    var onEdit: () -> Void
    var onResetStreak: () -> Void
    var onResetRecord: () -> Void
    var onOverrideStreak: (Date) -> Void
    var onRepeatOptionSelected: (RepeatOption) -> Void
    var onDelete: () -> Void
    
    @State private var showingResetStreakConfirmation = false
    @State private var showingResetRecordConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @State private var showingCongratulations = false
    @State private var showingRepeatOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Text("\(habit.currentStreak)")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.blue)
                        Text("\(habit.currentStreak == 1 ? "day" : "days")")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("🔥")
                            .font(.system(.subheadline))
                    }
                }
                .contentShape(Rectangle())
                
                Spacer()
                
                Button(action: {
                    if !habit.isCompletedToday() {
                        onToggleCompletion()
                        if habit.goal.type == .justForToday {
                            showingCongratulations = true
                        }
                    } else {
                        onToggleCompletion()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 2.5)
                            .frame(width: 32, height: 32)
                            .foregroundColor(habit.isCompletedToday() ? .green : .primary.opacity(0.6))
                            .background(
                                Circle()
                                    .fill(habit.isCompletedToday() ? Color.green.opacity(0.15) : Color.clear)
                            )
                            
                        if habit.isCompletedToday() {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        } else {
                            Text(Weekday.today.shortName.prefix(1))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
                .frame(width: 32, height: 32)
                .contentShape(Circle())
                .buttonStyle(PlainButtonStyle())
            }
            
            HStack(spacing: 16) {
                // Progress indicator
                progressCircle
                
                VStack(alignment: .leading, spacing: 6) {
                    // Goal description
                    goalDescriptionView
                    
                    HStack(spacing: 4) {
                        Text("Record:")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                        Text("\(habit.recordStreak)")
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                            .foregroundColor(.purple)
                        Text("\(habit.recordStreak == 1 ? "day" : "days")")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 10)
        .swipeActions(edge: .leading) {
            Button {
                onEdit()
            } label: {
                Text("Set\nGoal")
                    .multilineTextAlignment(.center)
            }
            .tint(.blue)
            
            Button {
                showingDatePicker = true
            } label: {
                Text("Set\nStreak")
                    .multilineTextAlignment(.center)
            }
            .tint(.indigo)
        }
        .swipeActions(edge: .trailing) {
            Button {
                showingDeleteConfirmation = true
            } label: {
                Text("Delete\nHabit")
                    .multilineTextAlignment(.center)
            }
            .tint(.red)
            
            Button {
                showingResetRecordConfirmation = true
            } label: {
                Text("Reset\nRecord")
                    .multilineTextAlignment(.center)
            }
            .tint(.orange)
            
            Button {
                showingResetStreakConfirmation = true
            } label: {
                Text("Reset\nStreak")
                    .multilineTextAlignment(.center)
            }
            .tint(.yellow)
        }
        .alert("Delete Habit?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
        }
        .alert("Reset Streak?", isPresented: $showingResetStreakConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                onResetStreak()
            }
        } message: {
            Text("This will reset your current streak to 0. This action cannot be undone.")
        }
        .alert("Reset Record?", isPresented: $showingResetRecordConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                onResetRecord()
            }
        } message: {
            Text("This will reset your all-time record to your current streak (\(habit.currentStreak)). This action cannot be undone.")
        }
        .alert("Congratulations! 🎉", isPresented: $showingCongratulations) {
            Button("Choose Repeat Option") {
                showingRepeatOptions = true
            }
            Button("Don't Repeat") {
                onRepeatOptionSelected(.none)
            }
        } message: {
            Text("You've completed your daily habit: \(habit.name)")
        }
        .alert("Repeat Options", isPresented: $showingRepeatOptions) {
            Button("Repeat Tomorrow") {
                onRepeatOptionSelected(.tomorrow)
            }
            Button("Repeat Forever") {
                onRepeatOptionSelected(.forever)
            }
            Button("Cancel", role: .cancel) {
                onRepeatOptionSelected(.none)
            }
        } message: {
            Text("Would you like to repeat this habit?")
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Select Start Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
                .navigationTitle("Override Streak")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Set") {
                            onOverrideStreak(selectedDate)
                            showingDatePicker = false
                        }
                    }
                }
            }
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
            return "Just for Today"
            
        case .weekly:
            return "Weekly Goal"
            
        case .totalDays:
            if let target = habit.goal.totalDaysTarget {
                return "Total Days: \(habit.currentStreak)/\(target)"
            }
            return "Total Days Progress"
        }
    }
    
    // Additional details about the goal
    private var goalDetail: String {
        switch habit.goal.type {
        case .justForToday:
            return "Complete this once today"
            
        case .weekly:
            if habit.goal.isLenientTracking {
                return "Lenient tracking: Any \(habit.goal.selectedDays.count) days per week"
            } else {
                return "Strict tracking: On selected days only"
            }
            
        case .totalDays:
            if let target = habit.goal.totalDaysTarget {
                let remaining = max(0, target - habit.currentStreak)
                return "\(remaining) days remaining to goal"
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
                onRepeatOptionSelected: { _ in },
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
                onRepeatOptionSelected: { _ in },
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
                onRepeatOptionSelected: { _ in },
                onDelete: {}
            )
        }
    }
} 