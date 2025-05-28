import SwiftUI

// Define filter enum
enum HabitFilter: String, CaseIterable {
    case all = "All"
    case daily = "Daily"
    case weekly = "Weekly"
}

struct HabitListView: View {
    @StateObject private var viewModel = HabitListViewModel()
    @State private var showingAddSheet = false
    @State private var selectedHabit: Habit?
    @State private var showingTipJar = false
    @State private var showingStats: Habit?
    @State private var showingDateSimulator = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedFilter: HabitFilter = .all
    @ObservedObject private var dateSimulator = DateSimulator.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
                filterTabsView
                
                Group {
                    if viewModel.habits.isEmpty {
                        emptyStateView
                    } else {
                        habitListView
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .imageScale(.medium)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Just for Today")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: .primary.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Date simulator button - always in same position
                        Button {
                            showingDateSimulator = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar.badge.clock")
                                    .imageScale(.medium)
                                    .foregroundColor(dateSimulator.isSimulationActive ? .blue : .primary.opacity(0.8))
                                
                                // Only show weekday label when simulation is active
                                if dateSimulator.isSimulationActive {
                                    Text(Weekday.fromDate(dateSimulator.currentDate).shortName)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
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
                                .foregroundColor(.primary.opacity(0.8))
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
            .sheet(isPresented: $showingDateSimulator) {
                DateSimulatorView()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    // Filter tabs view
    private var filterTabsView: some View {
        HStack(spacing: 0) {
            ForEach(HabitFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                }) {
                    VStack(spacing: 8) {
                        Text(filter.rawValue)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(selectedFilter == filter ? .bold : .medium)
                            .foregroundColor(selectedFilter == filter ? .blue : .primary.opacity(0.6))
                        
                        // Indicator line
                        Rectangle()
                            .fill(selectedFilter == filter ? Color.blue : Color.clear)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .bottom
        )
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
    
    // Filter habits based on selected filter
    private var filteredHabits: [Habit] {
        switch selectedFilter {
        case .all:
            return viewModel.habits
        case .daily:
            // Include both justForToday and totalDays in the Daily tab
            return viewModel.habits.filter { $0.goal.type == .justForToday || $0.goal.type == .totalDays }
        case .weekly:
            return viewModel.habits.filter { $0.goal.type == .weekly }
        }
    }
    
    private var habitListView: some View {
        List {
            ForEach(filteredHabits) { habit in
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

#Preview {
    HabitListView()
}

 