import SwiftUI

enum FeelingCategory: String, CaseIterable, Identifiable, Codable {
    // Original categories
    case Angry, Afraid, Sad, Happy, Lonely, Tired, Stressed

    // New structured categories for risk engine
    case positive, neutral, mildNegative, highRisk

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .Angry: return Color.red.opacity(0.8)
        case .Afraid: return Color.orange
        case .Sad: return Color.blue
        case .Happy: return Color.green
        case .Lonely: return Color.purple
        case .Tired: return Color.gray
        case .Stressed: return Color.yellow

        case .positive: return Color.green.opacity(0.7)
        case .neutral: return Color.gray.opacity(0.4)
        case .mildNegative: return Color.orange.opacity(0.7)
        case .highRisk: return Color.red
        }
    }

    var icon: String {
        switch self {
        case .Angry: return "flame.fill"
        case .Afraid: return "exclamationmark.triangle.fill"
        case .Sad: return "cloud.rain.fill"
        case .Happy: return "sun.max.fill"
        case .Lonely: return "person.fill.questionmark"
        case .Tired: return "zzz"
        case .Stressed: return "bolt.trianglebadge.exclamationmark"

        case .positive: return "hand.thumbsup.fill"
        case .neutral: return "circle"
        case .mildNegative: return "exclamationmark.circle"
        case .highRisk: return "exclamationmark.triangle.fill"
        }
    }
}
