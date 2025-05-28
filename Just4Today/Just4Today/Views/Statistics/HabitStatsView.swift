import SwiftUI

struct HabitStatsView: View {
    @StateObject private var viewModel: HabitStatsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDatePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingResetRecordConfirmation = false
    @State private var selectedDate = Date()
    
    init(habit: Habit,
         onDelete: @escaping () -> Void,
         onResetRecord: @escaping () -> Void,
         onOverrideStreak: @escaping (Date) -> Void) {
        _viewModel = StateObject(wrappedValue: HabitStatsViewModel(
            habit: habit,
            onDelete: onDelete,
            onResetRecord: onResetRecord,
            onOverrideStreak: onOverrideStreak
        ))
    }
    
    var body: some View {
        NavigationView {
            List {
                // Basic Stats Section
                Section("Current Stats") {
                    if viewModel.habit.goal.type == .weekly {
                        StatRow(title: "Completed Weeks", value: "\(viewModel.habit.completedWeeks.count) weeks")
                        StatRow(title: "All-Time Record", value: "\(viewModel.habit.recordStreak) weeks")
                    } else {
                        StatRow(title: "Current Streak", value: "\(viewModel.habit.currentStreak) \(viewModel.habit.currentStreak == 1 ? "day" : "days")")
                        StatRow(title: "All-Time Record", value: "\(viewModel.habit.recordStreak) \(viewModel.habit.recordStreak == 1 ? "day" : "days")")
                    }
                }
                
                // Weekly Stats Section (for weekly habits)
                if viewModel.habit.goal.type == .weekly {
                    Section("Weekly Progress") {
                        StatRow(title: "Selected Days", value: viewModel.selectedDaysText)
                        StatRow(title: "Completed This Week", value: "\(viewModel.completedDaysThisWeek.count) days")
                        StatRow(title: "Missed This Week", value: "\(viewModel.missedDaysThisWeek.count) days")
                        StatRow(title: "Weekly Completion Rate", value: viewModel.weeklyCompletionRate)
                    }
                }
                
                // Goal Information
                Section("Goal Details") {
                    StatRow(title: "Goal Type", value: viewModel.goalTypeDescription)
                    if viewModel.habit.goal.type == .weekly {
                        StatRow(title: "Tracking Mode", value: viewModel.habit.goal.isLenientTracking ? "Lenient" : "Strict")
                    }
                    if case .totalDays = viewModel.habit.goal.type, let target = viewModel.habit.goal.totalDaysTarget {
                        StatRow(title: "Target", value: "\(target) days")
                        StatRow(title: "Progress", value: "\(Int((Double(viewModel.habit.currentStreak) / Double(target)) * 100))%")
                    }
                    if case .justForToday = viewModel.habit.goal.type, viewModel.habit.goal.targetType == .timebound, let target = viewModel.habit.goal.totalDaysTarget {
                        StatRow(title: "Target", value: "\(target) days")
                        StatRow(title: "Progress", value: "\(Int((Double(viewModel.habit.currentStreak) / Double(target)) * 100))%")
                    }
                }
                
                // Danger Zone Section
                Section {
                    Button {
                        showingDatePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Set Streak Manually")
                        }
                    }
                    .foregroundColor(.orange)
                    
                    Button {
                        showingResetRecordConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "record.circle")
                            Text("Reset All-Time Record")
                        }
                    }
                    .foregroundColor(.orange)
                    
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Habit")
                        }
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("These actions cannot be undone. Please proceed with caution.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(viewModel.habit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
                    .navigationTitle("Set Streak Manually")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Set") {
                                viewModel.overrideStreak(selectedDate)
                                showingDatePicker = false
                            }
                        }
                    }
                }
            }
            .alert("Delete Habit?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteHabit()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete '\(viewModel.habit.name)'? This action cannot be undone.")
            }
            .alert("Reset Record?", isPresented: $showingResetRecordConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetRecord()
                }
            } message: {
                Text("This will reset your all-time record to your current streak (\(viewModel.habit.currentStreak)). This action cannot be undone.")
            }
        }
    }
}

// Helper view for consistent stat row layout
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct HabitStatsView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with a weekly habit
        HabitStatsView(
            habit: Habit(
                name: "Exercise",
                currentStreak: 5,
                recordStreak: 12,
                goal: Goal(
                    type: .weekly,
                    selectedDays: [.monday, .wednesday, .friday],
                    isLenientTracking: false
                )
            ),
            onDelete: {},
            onResetRecord: {},
            onOverrideStreak: { _ in }
        )
        
        // Preview with a total days habit
        HabitStatsView(
            habit: Habit(
                name: "Read",
                currentStreak: 25,
                recordStreak: 30,
                goal: Goal(
                    type: .totalDays,
                    targetType: .timebound,
                    totalDaysTarget: 100
                )
            ),
            onDelete: {},
            onResetRecord: {},
            onOverrideStreak: { _ in }
        )
    }
} 