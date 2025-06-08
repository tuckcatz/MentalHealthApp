import Foundation

struct CheckIn: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var moodRating: Int
    var energyLevel: Int
    var sleepQuality: Int
    var appetiteLevel: Int
    var anxietyLevel: Int
    var interestLevel: Int
    var hopelessnessLevel: Int
    var feelsSafe: Bool
    var hasHarmThoughts: Bool
    var feelings: [String]
    var journalText: String?
    var journalImageData: Data?
}
