import SwiftUI

struct DaySelectorView: View {
    @Binding var selectedDays: Set<Weekday>
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select days to complete this habit:")
                .font(.subheadline)
                .foregroundColor(isDisabled ? .secondary : .primary)
            
            HStack(spacing: 8) {
                ForEach(Weekday.allCases) { day in
                    Button(action: {
                        toggleDay(day)
                    }) {
                        Text(day.shortName)
                            .font(.subheadline)
                            .fontWeight(selectedDays.contains(day) ? .bold : .regular)
                            .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                            .frame(width: 38, height: 38)
                            .background(
                                Circle()
                                    .fill(selectedDays.contains(day) ? Color.blue : Color(.systemGray6))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isDisabled)
                }
            }
        }
        .padding(.vertical, 8)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
    
    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

struct DaySelectorView_Previews: PreviewProvider {
    @State static var selectedDays: Set<Weekday> = [.monday, .wednesday, .friday]
    
    static var previews: some View {
        VStack {
            DaySelectorView(selectedDays: $selectedDays)
            Divider()
            DaySelectorView(selectedDays: $selectedDays, isDisabled: true)
        }
        .padding()
    }
} 