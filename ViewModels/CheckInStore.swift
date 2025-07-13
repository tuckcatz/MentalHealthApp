import Foundation
import SwiftUI

class CheckInStore: ObservableObject {
    @Published var checkIns: [CheckIn] = [] {
        didSet {
            saveCheckIns()
        }
    }

    @AppStorage("dismissedAbsencePromptAt5Days") var dismissedAbsencePromptAt5Days: Bool = false
    @AppStorage("checkInDeferredUntil") var checkInDeferredUntil: Date = .distantPast

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
        feelings: [FeelingWord] = [],
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
        dismissedAbsencePromptAt5Days = false
        checkInDeferredUntil = .distantPast // ✅ Reset deferral on successful check-in
    }

    func getLastCheckIns(limit: Int = 5) -> [CheckIn] {
        return Array(checkIns.suffix(limit))
    }

    var hasCheckedInToday: Bool {
        let calendar = Calendar.current
        return checkIns.contains {
            calendar.isDateInToday($0.date) &&
            ($0.moodRating != 0 || !($0.journalText ?? "").isEmpty)
        }
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
        checkInDeferredUntil = .distantPast
    }

    // MARK: - Daily Refresh Logic

    func refreshCheckInStatus() {
        let calendar = Calendar.current
        let today = Date()

        // Reset hasCheckedInToday if needed
        if let lastCheckInDate = checkIns.last?.date {
            if !calendar.isDateInToday(lastCheckInDate) {
                objectWillChange.send()
            }
        }

        // Reset checkInDeferredUntil if a new day has started
        if !calendar.isDateInToday(checkInDeferredUntil) {
            checkInDeferredUntil = .distantPast
        }
    }
}
