import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    var onToggleCompletion: () -> Void
    var onEdit: () -> Void
    var onResetStreak: () -> Void
    var onResetRecord: () -> Void
    var onOverrideStreak: (Date) -> Void
    
    @State private var showingResetStreakConfirmation = false
    @State private var showingResetRecordConfirmation = false
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                    
                    Text("Streak: \(habit.currentStreak) 🔥 • Record: \(habit.recordStreak)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onToggleCompletion) {
                    Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                        .imageScale(.large)
                        .foregroundColor(habit.isCompletedToday() ? .green : .primary)
                }
            }
        }
        .padding(.vertical, 8)
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
                showingResetRecordConfirmation = true
            } label: {
                Text("Reset\nRecord")
                    .multilineTextAlignment(.center)
            }
            .tint(.red)
            
            Button {
                showingResetStreakConfirmation = true
            } label: {
                Text("Reset\nStreak")
                    .multilineTextAlignment(.center)
            }
            .tint(.orange)
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
            Text("This will reset your all-time record to 0. This action cannot be undone.")
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
                onOverrideStreak: { _ in }
            )
        }
    }
} 