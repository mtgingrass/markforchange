import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var showingAddSheet = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.habits.isEmpty {
                    emptyStateView
                } else {
                    habitListView
                }
            }
            .navigationTitle("Your Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                SetGoalView(mode: .create) { goal, name in
                    if let goal = goal {
                        let newHabit = Habit(
                            name: name,
                            currentStreak: 0,
                            recordStreak: 0,
                            goal: goal
                        )
                        viewModel.addHabit(newHabit)
                    }
                }
            }
            .sheet(item: $selectedHabit) { habit in
                SetGoalView(mode: .edit(habit)) { goal, name in
                    if let goal = goal {
                        var updatedHabit = habit
                        updatedHabit.name = name
                        updatedHabit.goal = goal
                        viewModel.updateHabit(updatedHabit)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("No habits yet. Tap '+' to get started.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var habitListView: some View {
        List {
            ForEach(viewModel.habits) { habit in
                HabitRowView(
                    habit: habit,
                    onToggleCompletion: {
                        viewModel.toggleHabitCompletion(habit)
                    },
                    onEdit: {
                        selectedHabit = habit
                    },
                    onResetStreak: {
                        viewModel.resetStreak(for: habit)
                    },
                    onResetRecord: {
                        viewModel.resetRecord(for: habit)
                    },
                    onOverrideStreak: { date in
                        viewModel.overrideStreak(for: habit, startDate: date)
                    }
                )
            }
        }
    }
} 