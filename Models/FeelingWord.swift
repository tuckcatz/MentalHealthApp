import Foundation

struct FeelingWord: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let word: String
    let riskLevel: RiskLevel
    let category: FeelingCategory

    enum RiskLevel: String, Codable {
        case low, moderate, high, critical
    }
}
