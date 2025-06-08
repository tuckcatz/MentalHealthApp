import Foundation
import NaturalLanguage

struct RiskScore {
    let score: Int
    let level: RiskLevel
    let triggers: [String]
}

enum RiskLevel: String {
    case low, moderate, high, critical
}

struct RiskEngine {
    static let keywordWeights: [String: Int] = [
        "hopeless": 30, "worthless": 25, "ending it": 40, "can't go on": 35,
        "numb": 20, "done with this": 30, "no reason to live": 50, "give up": 30,
        "fail": 15, "failure": 20, "useless": 25, "hate myself": 35, "want it to end": 40,
        "tired of everything": 25, "empty": 20, "can't take it": 30, "pointless": 25,
        "helpless": 25, "trapped": 30, "isolated": 20, "suicidal": 50, "end my life": 50
    ]

    static let feelingsWeights: [String: Int] = [
        "overwhelmed": 15,
        "anxious": 10,
        "disconnected": 20,
        "scared": 15,
        "angry": 10,
        "empty": 20,
        "hopeless": 25,
        "worthless": 25
    ]

    static func evaluate(
        journalText: String,
        feelings: [String],
        mood: Int,
        energy: Int,
        sleep: Int,
        appetite: Int,
        anxiety: Int,
        interest: Int,
        hopelessness: Int,
        feelsSafe: Bool,
        hasHarmThoughts: Bool,
        moodTrend: [Int] = [],
        userProfile: UserProfile? = nil
    ) -> RiskScore {
        var score = 0
        var triggers: [String] = []

        let text = journalText.lowercased()

        // 1. Keyword Matching
        for (keyword, weight) in keywordWeights {
            if text.localizedStandardContains(keyword) {
                score += weight
                triggers.append(keyword)
            }
        }

        // 2. Feelings Tag Weighting
        for feeling in feelings.map({ $0.lowercased() }) {
            if let weight = feelingsWeights[feeling] {
                score += weight
                triggers.append("feeling:\(feeling)")
            }
        }

        // 3. Sentiment Boost
        if let sentimentBoost = sentimentScore(from: text) {
            score += sentimentBoost
        }

        // 4. Baseline Delta Scoring (mood, energy, sleep, appetite, anxiety)
        if let profile = userProfile {
            if mood <= profile.baselineMood - 2 {
                score += 10
                triggers.append("mood ↓ vs baseline")
            }
            if energy <= profile.baselineEnergy - 2 {
                score += 10
                triggers.append("energy ↓ vs baseline")
            }
            if sleep <= profile.baselineSleep - 2 {
                score += 10
                triggers.append("sleep ↓ vs baseline")
            }
            if appetite <= profile.baselineAppetite - 2 {
                score += 10
                triggers.append("appetite ↓ vs baseline")
            }
            if anxiety >= profile.baselineAnxiety + 2 {
                score += 10
                triggers.append("anxiety ↑ vs baseline")
            }
        } else {
            if mood <= 3 { score += 10 }
            if energy <= 3 { score += 10 }
        }

        // 5. Low scores across multiple areas
        let lows = [mood, energy, sleep, appetite, anxiety].filter { $0 <= 2 }.count
        if lows >= 4 {
            score += 20
            triggers.append("multiple low scores")
        }

        // 6. Mood trend over 3 days
        if moodTrend.suffix(3).allSatisfy({ $0 <= 3 }) {
            score += 25
            triggers.append("3-day mood drop")
        }

        // 7. Interest / Hopelessness sliders
        if interest <= 3 {
            score += 10
            triggers.append("low interest")
        }

        if hopelessness >= 8 {
            score += 25
            triggers.append("severe hopelessness")
        } else if hopelessness >= 5 {
            score += 15
            triggers.append("moderate hopelessness")
        }

        // 8. Safety Signals
        if hasHarmThoughts {
            score = 100
            triggers.append("harm thoughts")
        } else if !feelsSafe {
            score += 20
            triggers.append("unsafe today")
        }

        // 9. No journal entry with other low scores
        if journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && lows >= 3 {
            score += 10
            triggers.append("low scores + no journal")
        }

        // Final Score Clamp
        score = min(score, 100)

        // Final Tiering
        let level: RiskLevel
        switch score {
        case 0..<31: level = .low
        case 31..<61: level = .moderate
        case 61..<81: level = .high
        default: level = .critical
        }

        return RiskScore(score: score, level: level, triggers: triggers)
    }

    private static func sentimentScore(from text: String) -> Int? {
        guard !text.isEmpty else { return nil }

        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let scoreStr = sentiment?.rawValue, let score = Double(scoreStr) {
            if score <= -0.4 { return 25 }
            else if score <= -0.2 { return 15 }
            else if score <= 0 { return 5 }
            else { return 0 }
        }
        return nil
    }
}
