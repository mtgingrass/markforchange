import SwiftUI
import Foundation

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    let tipOptions = [
        TipOption(amount: 2.99, description: "Small Tip", emoji: "☕️"),
        TipOption(amount: 4.99, description: "Medium Tip", emoji: "🍕"),
        TipOption(amount: 9.99, description: "Large Tip", emoji: "🚀")
    ]
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.pink)
                        .padding()
                    
                    Text("Support Just4Today")
                        .font(.title)
                        .bold()
                    
                    Text("Your support helps enable future development.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Tip options
                VStack(spacing: 16) {
                    ForEach(tipOptions) { option in
                        Button {
                            // Tip logic will be implemented later
                            print("Selected tip: \(option.amount)")
                        } label: {
                            HStack {
                                Text(option.emoji)
                                    .font(.system(size: 30))
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading) {
                                    Text(option.description)
                                        .font(.headline)
                                    Text("$\(String(format: "%.2f", option.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Version info
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Thank you note
                Text("Thank you for your support! ❤️")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .padding()
            .navigationTitle("Tip Jar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    TipJarView()
}
