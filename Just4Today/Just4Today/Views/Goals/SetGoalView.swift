import SwiftUI

enum SetGoalMode: Equatable {
    case create
    case edit(Habit)
    
    static func == (lhs: SetGoalMode, rhs: SetGoalMode) -> Bool {
        switch (lhs, rhs) {
        case (.create, .create):
            return true
        case (.edit(let lhsHabit), .edit(let rhsHabit)):
            return lhsHabit.id == rhsHabit.id
        default:
            return false
        }
    }
}

struct SetGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SetGoalViewModel
    @State private var habitName: String = ""
    let mode: SetGoalMode
    let onSave: (Goal?, String) -> Void
    
    init(mode: SetGoalMode, onSave: @escaping (Goal?, String) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .create:
            _viewModel = StateObject(wrappedValue: SetGoalViewModel())
            _habitName = State(initialValue: "New Habit")
        case .edit(let habit):
            _viewModel = StateObject(wrappedValue: SetGoalViewModel(habit: habit))
            _habitName = State(initialValue: habit.name)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("Enter habit name", text: $habitName)
                }
                
                Section(header: Text("Goal Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHOOSE GOAL TYPE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Toggle("Daily Task", isOn: Binding(
                            get: { viewModel.goalType == .justForToday },
                            set: { isJustForToday in
                                if isJustForToday {
                                    // Toggling to Daily Task
                                    viewModel.goalType = .justForToday
                                } else {
                                    // Toggling from Daily Task to Weekly (default non-today option)
                                    viewModel.goalType = .weekly
                                }
                                viewModel.validateGoal()
                            }
                        ))
                        
                        if viewModel.goalType != .justForToday {
                            Picker("Goal Type", selection: $viewModel.goalType) {
                                ForEach(GoalType.allCases.filter { $0 != .justForToday }) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 4)
                            .onChange(of: viewModel.goalType) { oldValue, newValue in
                                viewModel.validateGoal()
                            }
                            
                            // Only show day selector and lenient tracking for weekly goals
                            if viewModel.goalType == .weekly {
                                DaySelectorView(
                                    selectedDays: $viewModel.selectedDays,
                                    isDisabled: false
                                )
                                .padding(.top, 4)
                                
                                InfoToggleView(
                                    isOn: $viewModel.isLenientTracking,
                                    label: "Lenient Tracking",
                                    infoTitle: "What is lenient tracking?",
                                    infoText: """
                                    With lenient tracking, it doesn't matter which days you do the habit.
                                    As long as you complete it the desired number of times in a week,
                                    it is counted as successful. You can choose the days of week for your own tracking,
                                    but the count is what matters with lenient tracking enabled.
                                    """,
                                    isDisabled: false
                                )
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Show Duration section for all goal types except when it's a daily task with no target
                if viewModel.goalType != .justForToday || viewModel.targetType == .timebound || viewModel.targetType == .forever {
                    Section(header: Text("Duration")) {
                        Picker("Target Type", selection: $viewModel.targetType) {
                            ForEach(TargetType.allCases) { type in
                                // Customize label based on goal type
                                if type == .timebound {
                                    let label = viewModel.goalType == .weekly ? "Number of Weeks" : "Number of Days" 
                                    Text(label).tag(type)
                                } else {
                                    Text(type.displayName).tag(type)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                        .onChange(of: viewModel.targetType) { oldValue, newValue in
                            viewModel.validateGoal()
                        }
                        
                        if viewModel.targetType == .timebound {
                            if viewModel.goalType == .weekly {
                                TextField("Number of weeks", text: $viewModel.weeklyTargetWeeks)
                                    .keyboardType(.numberPad)
                                    .onChange(of: viewModel.weeklyTargetWeeks) { oldValue, newValue in
                                        viewModel.validateGoal()
                                    }
                            } else if viewModel.goalType == .totalDays || viewModel.goalType == .justForToday {
                                TextField("Total completions", text: $viewModel.totalDaysTarget)
                                    .keyboardType(.numberPad)
                                    .onChange(of: viewModel.totalDaysTarget) { oldValue, newValue in
                                        viewModel.validateGoal()
                                    }
                            }
                        }
                    }
                }
                
                if !viewModel.isValidGoal && !viewModel.validationMessage.isEmpty {
                    Section {
                        Text(viewModel.validationMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button("Set Goal") {
                        if habitName.isEmpty {
                            // Don't allow empty habit names
                            return
                        }
                        
                        if let goal = viewModel.createGoal() {
                            onSave(goal, habitName)
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!viewModel.isValidGoal || habitName.isEmpty)
                    
                    Button("Clear Goal") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Set Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.validateGoal()
            }
        }
    }
} 