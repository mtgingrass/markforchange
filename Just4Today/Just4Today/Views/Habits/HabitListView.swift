import SwiftUI

struct HabitListView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var showingAddSheet = false
    @State private var selectedHabit: Habit?
    @State private var showingTipJar = false
    @State private var showingStats: Habit?
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .imageScale(.medium)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Tip jar button
                        Button {
                            showingTipJar = true
                        } label: {
                            Image(systemName: "heart.fill")
                                .imageScale(.medium)
                                .foregroundColor(.pink)
                        }
                        
                        // Add button
                        Button(action: {
                            showingAddSheet = true
                        }) {
                            Image(systemName: "plus")
                                .imageScale(.medium)
                        }
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
            .sheet(isPresented: $showingTipJar) {
                TipJarView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
                    },
                    onRepeatOptionSelected: { option in
                        viewModel.setRepeatOption(for: habit, option: option)
                    },
                    onDelete: {
                        viewModel.deleteHabit(habit)
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    showingStats = habit
                }
            }
        }
        .sheet(item: $showingStats) { habit in
            HabitStatsView(
                habit: habit,
                onDelete: {
                    viewModel.deleteHabit(habit)
                    showingStats = nil
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

 