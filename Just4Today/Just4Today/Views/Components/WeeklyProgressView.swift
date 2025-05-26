import SwiftUI

struct WeeklyProgressView: View {
    let selectedDays: [Weekday]
    let completedDays: [Weekday]
    let missedDays: [Weekday]
    
    // Use computed property to always get the current today
    var today: Weekday {
        return Weekday.today
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Weekday.allCases) { day in
                dayIndicator(for: day)
            }
        }
    }
    
    private func dayIndicator(for day: Weekday) -> some View {
        let isSelected = selectedDays.contains(day)
        let isCompleted = completedDays.contains(day)
        let isMissed = missedDays.contains(day)
        let isToday = day == today
        
        return ZStack {
            Circle()
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), 
                        lineWidth: isSelected ? 2.5 : 1.5)
                .background(
                    Circle()
                        .fill(backgroundColor(isSelected: isSelected, isCompleted: isCompleted, isMissed: isMissed))
                )
                .frame(width: 28, height: 28)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            } else if isMissed {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(day.shortName.prefix(1))
                    .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? (isToday ? .blue : .primary) : .secondary)
            }
        }
        .overlay(
            Circle()
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: isToday ? 2 : 0)
                .padding(-2)
        )
        // Add a subtle highlight for today
        .background(
            Circle()
                .fill(isToday ? Color.blue.opacity(0.1) : Color.clear)
                .padding(-4)
        )
    }
    
    private func backgroundColor(isSelected: Bool, isCompleted: Bool, isMissed: Bool) -> Color {
        if isCompleted {
            return .green
        } else if isMissed {
            return .red
        } else {
            return .clear
        }
    }
}

struct WeeklyProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Example 1: Some completed, some missed
            WeeklyProgressView(
                selectedDays: [.monday, .wednesday, .friday],
                completedDays: [.monday], 
                missedDays: [.wednesday]
            )
            .padding()
            .previewDisplayName("Mid-week example")
            
            // Example 2: All completed for the week
            WeeklyProgressView(
                selectedDays: [.monday, .wednesday, .friday],
                completedDays: [.monday, .wednesday, .friday, .sunday], 
                missedDays: []
            )
            .padding()
            .previewDisplayName("All completed example")
            
            // Example 3: Lenient tracking example
            WeeklyProgressView(
                selectedDays: [.monday, .wednesday, .friday, .saturday],
                completedDays: [.tuesday, .thursday], 
                missedDays: [.monday]
            )
            .padding()
            .previewDisplayName("Lenient tracking example")
        }
        .previewLayout(.sizeThatFits)
    }
} 