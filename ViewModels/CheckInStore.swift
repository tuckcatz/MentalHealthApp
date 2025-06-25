import Foundation
import SwiftUI

class CheckInStore: ObservableObject {
    @Published var checkIns: [CheckIn] = [] {
        didSet {
            saveCheckIns()
        }
    }

    @AppStorage("dismissedAbsencePromptAt5Days") var dismissedAbsencePromptAt5Days: Bool = false

    private let checkInKey = "userCheckIns"

    init() {
        loadCheckIns()
    }

    func addCheckIn(
        mood: Int,
        energy: Int,
        sleep: Int,
        appetite: Int,
        anxiety: Int,
        interest: Int,
        hopelessness: Int,
        feelsSafe: Bool,
        hasHarmThoughts: Bool,
        feelings: [String] = [],
        journal: String,
        journalImage: Data?
    ) {
        let newCheckIn = CheckIn(
            date: Date(),
            moodRating: mood,
            energyLevel: energy,
            sleepQuality: sleep,
            appetiteLevel: appetite,
            anxietyLevel: anxiety,
            interestLevel: interest,
            hopelessnessLevel: hopelessness,
            feelsSafe: feelsSafe,
            hasHarmThoughts: hasHarmThoughts,
            feelings: feelings,
            journalText: journal,
            journalImageData: journalImage
        )
        checkIns.append(newCheckIn)
        dismissedAbsencePromptAt5Days = false // Reset alert flag on check-in
    }

    func getLastCheckIns(limit: Int = 5) -> [CheckIn] {
        return Array(checkIns.suffix(limit))
    }

    var hasCheckedInToday: Bool {
        guard let latest = checkIns.last else { return false }
        return Calendar.current.isDateInToday(latest.date)
    }

    var recentMoodTrend: [Int] {
        return checkIns.suffix(3).map { $0.moodRating }
    }

    func missedCheckInDays(inLast days: Int = 5) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var missed = 0

        for i in 1...days {
            if let day = calendar.date(byAdding: .day, value: -i, to: today) {
                let found = checkIns.contains {
                    calendar.isDate($0.date, inSameDayAs: day)
                }
                if !found {
                    missed += 1
                }
            }
        }

        return missed
    }

    // MARK: - Trend Data for RiskEngine

    func getMoodTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.moodRating }
    }

    func getEnergyTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.energyLevel }
    }

    func getSleepTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.sleepQuality }
    }

    func getAppetiteTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.appetiteLevel }
    }

    func getAnxietyTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.anxietyLevel }
    }

    func getInterestTrend(days: Int = 5) -> [Int] {
        checkIns.suffix(days).map { $0.interestLevel }
    }

    private func saveCheckIns() {
        do {
            let data = try JSONEncoder().encode(checkIns)
            UserDefaults.standard.set(data, forKey: checkInKey)
        } catch {
            print("Failed to save check-ins:", error)
        }
    }

    private func loadCheckIns() {
        guard let data = UserDefaults.standard.data(forKey: checkInKey) else { return }
        do {
            checkIns = try JSONDecoder().decode([CheckIn].self, from: data)
        } catch {
            print("Failed to load check-ins:", error)
            checkIns = []
        }
    }

    func clearAll() {
        checkIns = []
        UserDefaults.standard.removeObject(forKey: checkInKey)
        dismissedAbsencePromptAt5Days = false
    }
}
