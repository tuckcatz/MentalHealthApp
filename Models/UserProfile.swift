import Foundation

struct UserProfile: Codable {
    // Core baseline metrics
    let baselineMood: Int
    let baselineEnergy: Int
    let baselineSleep: Int
    let baselineAnxiety: Int
    let baselineAppetite: Int

    // Additional clinical signals
    let baselineInterest: Int
    let baselineHopelessness: Int

    // Safety & support flags
    let feelsSafe: Bool
    let hasHarmThoughts: Bool
    let hasTrustedContact: Bool

    // Optional personal note
    let personalNote: String?
}
