import SwiftUI

struct InfoToggleView: View {
    @Binding var isOn: Bool
    var label: String
    var infoTitle: String
    var infoText: String
    var isDisabled: Bool = false
    
    @State private var showingInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(label)
                    .foregroundColor(isDisabled ? .secondary : .primary)
            }
            .disabled(isDisabled)
            
            Button(action: {
                showingInfo.toggle()
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text(infoTitle)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            .disabled(isDisabled)
            
            if showingInfo {
                Text(infoText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showingInfo)
        .padding(.vertical, 4)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct InfoToggleView_Previews: PreviewProvider {
    @State static var isOn = false
    
    static var previews: some View {
        VStack {
            InfoToggleView(
                isOn: $isOn,
                label: "Lenient Tracking",
                infoTitle: "What is lenient tracking?",
                infoText: """
                With lenient tracking, it doesn't matter which days you do the habit.
                As long as you complete it the desired number of times in a week,
                it is counted as successful. You can choose the days of week for your own tracking,
                but the count is what matters with lenient tracking enabled.
                """
            )
            Divider()
            InfoToggleView(
                isOn: $isOn,
                label: "Lenient Tracking",
                infoTitle: "What is lenient tracking?",
                infoText: "Lenient tracking explanation",
                isDisabled: true
            )
        }
        .padding()
    }
} 