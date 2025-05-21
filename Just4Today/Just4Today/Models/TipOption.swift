import Foundation

struct TipOption: Identifiable {
    let id = UUID()
    let amount: Double
    let description: String
    let emoji: String
} 