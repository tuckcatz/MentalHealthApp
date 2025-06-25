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
        "overwhelmed": 15, "anxious": 10, "disconnected": 20,
        "scared": 15, "angry": 10, "empty": 20,
        "hopeless": 25, "worthless": 25
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
        energyTrend: [Int] = [],
        sleepTrend: [Int] = [],
        appetiteTrend: [Int] = [],
        anxietyTrend: [Int] = [],
        interestTrend: [Int] = [],
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

        // 4. Baseline Deviation Scoring
        if let profile = userProfile {
            if mood <= profile.baselineMood - 2 {
                score += 10; triggers.append("mood ↓ vs baseline")
            }
            if energy <= profile.baselineEnergy - 2 {
                score += 10; triggers.append("energy ↓ vs baseline")
            }
            if sleep <= profile.baselineSleep - 2 {
                score += 10; triggers.append("sleep ↓ vs baseline")
            }
            if appetite <= profile.baselineAppetite - 2 {
                score += 10; triggers.append("appetite ↓ vs baseline")
            }
            if anxiety >= profile.baselineAnxiety + 2 {
                score += 10; triggers.append("anxiety ↑ vs baseline")
            }
        } else {
            if mood <= 4 { score += 10 }
            if energy <= 4 { score += 10 }
        }

        // 5. Multi-Metric Low Count
        let lows = [mood, energy, sleep, appetite, anxiety].filter { $0 <= 4 }.count
        if lows >= 4 {
            score += 20
            triggers.append("multiple low scores")
        }

        // 6. Trend Evaluation (uses updated TrendAnalyzer)
        var trendFlags = 0
        if let profile = userProfile {
            if TrendAnalyzer.isDownwardTrend(moodTrend, baseline: profile.baselineMood) {
                score += 10; trendFlags += 1
                triggers.append("mood trend ↓")
            }
            if TrendAnalyzer.isDownwardTrend(energyTrend, baseline: profile.baselineEnergy) {
                score += 10; trendFlags += 1
                triggers.append("energy trend ↓")
            }
            if TrendAnalyzer.isFlatBelowBaseline(interestTrend, baseline: profile.baselineInterest) {
                score += 10; trendFlags += 1
                triggers.append("stagnant interest")
            }
            if TrendAnalyzer.isConsistentlyLow(sleepTrend) {
                score += 10; trendFlags += 1
                triggers.append("sleep low x3")
            }
            if TrendAnalyzer.isConsistentlyLow(appetiteTrend) {
                score += 10; trendFlags += 1
                triggers.append("appetite low x3")
            }
        }

        if trendFlags >= 3 {
            score += 10
            triggers.append("multiple trend drops")
        }

        // 7. Interest / Hopelessness
        if interest <= 4 {
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

        // 8. Safety Signals (override all logic if danger present)
        if hasHarmThoughts {
            score = 100
            triggers.append("harm thoughts")
        } else if !feelsSafe {
            score += 20
            triggers.append("unsafe today")
        }

        // 9. Silent Journal + Lows
        if journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && lows >= 3 {
            score += 10
            triggers.append("low scores + no journal")
        }

        // Final Clamp & Risk Level
        score = min(score, 100)
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
        }
        return nil
    }
}
