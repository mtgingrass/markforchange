import SwiftUI

struct DateSimulatorView: View {
    @StateObject private var simulator = DateSimulator.shared
    @State private var selectedDate = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Simulation")) {
                    Toggle("Enable Date Simulation", isOn: $simulator.isSimulationActive)
                        .onChange(of: simulator.isSimulationActive) { oldValue, newValue in
                            if newValue {
                                simulator.setSimulatedDate(to: selectedDate)
                            } else {
                                simulator.resetSimulation()
                            }
                        }
                    
                    if simulator.isSimulationActive {
                        DatePicker(
                            "Simulated Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            simulator.setSimulatedDate(to: newValue)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Actions")
                                .font(.headline)
                            
                            Button("Advance to Tomorrow") {
                                simulator.advanceOneDay()
                                selectedDate = simulator.currentDate
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            Divider()
                            
                            Text("Jump to specific day:")
                                .font(.subheadline)
                            
                            HStack(spacing: 8) {
                                ForEach(Weekday.allCases) { day in
                                    Button(day.shortName) {
                                        simulator.moveToWeekday(day)
                                        selectedDate = simulator.currentDate
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Current Date Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current System Date:")
                            Spacer()
                            Text(formatDate(Date()))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Simulated Date:")
                            Spacer()
                            Text(formatDate(simulator.currentDate))
                                .foregroundColor(simulator.isSimulationActive ? .blue : .secondary)
                        }
                        
                        HStack {
                            Text("Current Weekday:")
                            Spacer()
                            Text(Weekday.fromDate(simulator.currentDate).fullName)
                                .foregroundColor(simulator.isSimulationActive ? .blue : .secondary)
                        }
                    }
                }
            }
            .navigationTitle("Date Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset") {
                        simulator.resetSimulation()
                        selectedDate = Date()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DateSimulatorView_Previews: PreviewProvider {
    static var previews: some View {
        DateSimulatorView()
    }
} 