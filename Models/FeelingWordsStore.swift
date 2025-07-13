import Foundation

class FeelingWordsStore: ObservableObject {
    @Published var allWords: [FeelingWord] = [
        // 🟢 Low Risk (positive)
        FeelingWord(word: "Calm", riskLevel: .low, category: .positive),
        FeelingWord(word: "Grateful", riskLevel: .low, category: .positive),
        FeelingWord(word: "Content", riskLevel: .low, category: .positive),
        FeelingWord(word: "Hopeful", riskLevel: .low, category: .positive),

        // 🔵 Moderate Risk (mildNegative)
        FeelingWord(word: "Stressed", riskLevel: .moderate, category: .mildNegative),
        FeelingWord(word: "Tired", riskLevel: .moderate, category: .mildNegative),
        FeelingWord(word: "Anxious", riskLevel: .moderate, category: .mildNegative),
        FeelingWord(word: "Overwhelmed", riskLevel: .moderate, category: .mildNegative),
        FeelingWord(word: "Lonely", riskLevel: .moderate, category: .mildNegative),
        FeelingWord(word: "Sad", riskLevel: .moderate, category: .mildNegative),

        // 🔴 High Risk (highRisk)
        FeelingWord(word: "Numb", riskLevel: .high, category: .highRisk),
        FeelingWord(word: "Empty", riskLevel: .high, category: .highRisk),
        FeelingWord(word: "Hollow", riskLevel: .high, category: .highRisk),
        FeelingWord(word: "Dark", riskLevel: .high, category: .highRisk),

        // 🟣 Critical Risk (highRisk)
        FeelingWord(word: "Done", riskLevel: .critical, category: .highRisk),
        FeelingWord(word: "No way out", riskLevel: .critical, category: .highRisk),
        FeelingWord(word: "Broken", riskLevel: .critical, category: .highRisk),
        FeelingWord(word: "End it", riskLevel: .critical, category: .highRisk),
        FeelingWord(word: "Worthless", riskLevel: .critical, category: .highRisk),
        FeelingWord(word: "Disappear", riskLevel: .critical, category: .highRisk)
    ]
}
