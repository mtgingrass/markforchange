//import SwiftUI
//
//struct InfoToggleView: View {
//    @Binding var isOn: Bool
//    var label: String
//    var infoTitle: String
//    var infoText: String
//    var isDisabled: Bool = false
//    
//    @State private var showingInfo = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Toggle(isOn: $isOn) {
//                Text(label)
//                    .foregroundColor(isDisabled ? .secondary : .primary)
//            }
//            .disabled(isDisabled)
//            
//            Button(action: {
//                showingInfo.toggle()
//            }) {
//                HStack {
//                    Image(systemName: "info.circle")
//                        .foregroundColor(.blue)
//                    Text(infoTitle)
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                    Spacer()
//                }
//            }
//            .disabled(isDisabled)
//            
//            if showingInfo {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Doesn’t matter which days you complete the habit. As long as you hit your target number for the week, it counts as successful.")
//                    Text("You can still select preferred days, but only the total count matters.")
//                }
//                .font(.body)
//                .foregroundColor(.secondary)
//                .padding(.horizontal)
//                .transition(.opacity)
//            }
//        }
//        .animation(.easeInOut, value: showingInfo)
//        .padding(.vertical, 4)
//        .opacity(isDisabled ? 0.6 : 1.0)
//    }
//}

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

            ZStack(alignment: .topLeading) {
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

                .sheet(isPresented: $showingInfo) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(infoTitle)
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Doesn’t matter which days you complete the habit. As long as you hit your target number for the week, it counts as successful.")
                            Text("You can still select preferred days, but only the total count matters.")
                        }
                        .font(.body)
                        .foregroundColor(.secondary)

                        Button("Close") {
                            showingInfo = false
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .frame(maxWidth: 350)
                }
                .presentationDetents([.fraction(0.3)])
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
                Doesn’t matter which days you complete the habit. As long as you hit your target number for the week, it counts as successful.

                You can still select preferred days, but only the total count matters.
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

