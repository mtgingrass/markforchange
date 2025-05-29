import SwiftUI

// Define filter enum
enum HabitFilter: String, CaseIterable {
    case all = "Today"
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
                filterTabsView
                habitListContent
            }
            .toolbar {
                toolbarContent
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
    
    // MARK: - Subviews
    
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
    
    private var habitListContent: some View {
        Group {
            if viewModel.habits.isEmpty {
                emptyStateView
            } else {
                habitListView
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
    
    private var toolbarContent: some ToolbarContent {
        Group {
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
                    dateSimulatorButton
                    tipJarButton
                    addButton
                }
            }
        }
    }
    
    private var dateSimulatorButton: some View {
        Button {
            showingDateSimulator = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                    .imageScale(.medium)
                    .foregroundColor(dateSimulator.isSimulationActive ? .blue : .primary.opacity(0.8))
                
                if dateSimulator.isSimulationActive {
                    Text(Weekday.fromDate(dateSimulator.currentDate).shortName)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var tipJarButton: some View {
        Button {
            showingTipJar = true
        } label: {
            Image(systemName: "heart.fill")
                .imageScale(.medium)
                .foregroundColor(.pink)
        }
    }
    
    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
                .imageScale(.medium)
                .foregroundColor(.primary.opacity(0.8))
        }
    }
    
    // MARK: - Filtered Habits
    
    private var filteredHabits: [Habit] {
        let today = dateSimulator.isSimulationActive ? 
            Calendar.current.startOfDay(for: dateSimulator.currentDate) :
            Calendar.current.startOfDay(for: Date())
        let currentWeekday = Calendar.current.component(.weekday, from: today)
        
        switch selectedFilter {
        case .all:
            return viewModel.habits.filter { habit in
                if habit.isCompletedToday() {
                    return false
                }
                
                switch habit.goal.type {
                case .justForToday, .totalDays:
                    return true
                case .weekly:
                    return habit.goal.selectedDays.contains(Weekday(rawValue: currentWeekday) ?? .monday)
                }
            }
        case .daily:
            return viewModel.habits.filter { habit in
                habit.goal.type == .justForToday || habit.goal.type == .totalDays
            }
        case .weekly:
            return viewModel.habits.filter { $0.goal.type == .weekly }
        }
    }
}

#Preview {
    HabitListView()
}

 