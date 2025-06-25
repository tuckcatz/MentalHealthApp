import Foundation

@MainActor
class MissedCheckInMonitor {
    private let checkInStore: CheckInStore
    private let alertManager: AlertManager
    private let userProfile: UserProfile?

    init(checkInStore: CheckInStore, alertManager: AlertManager, userProfile: UserProfile?) {
        self.checkInStore = checkInStore
        self.alertManager = alertManager
        self.userProfile = userProfile
    }

    func evaluateMissedCheckIns() {
        guard let lastCheckIn = checkInStore.checkIns.sorted(by: { $0.date > $1.date }).first?.date else {
            print("No check-ins found.")
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let daysMissed = Calendar.current.dateComponents([.day], from: lastCheckIn, to: today).day ?? 0

        let defaults = UserDefaults.standard
        let lastEval = Date(timeIntervalSince1970: defaults.double(forKey: "lastMissedCheckInEvaluation"))
        if Calendar.current.isDateInToday(lastEval) {
            print("Already evaluated today.")
            return
        }

        print("Missed check-ins: \(daysMissed)")

        switch daysMissed {
        case 2:
            sendNudge(message: "You’ve missed a couple of check-ins. Want to take a moment to check in now?")
        case 3:
            if hadHighOrCriticalRiskInPast() {
                alertManager.sendMissedCheckInAlert(reason: "User has missed 3 days and has history of high risk.")
            } else {
                sendNudge(message: "Still haven’t checked in. Just reminding you we’re here when you’re ready.")
            }
        case 4...5:
            sendNudge(message: "We noticed you've missed a few days. It’s okay — we’re here when you need us.")
        case 6...:
            alertManager.sendMissedCheckInAlert(reason: "User has missed 6+ days of check-ins.")
        default:
            break
        }

        defaults.set(Date().timeIntervalSince1970, forKey: "lastMissedCheckInEvaluation")
    }

    private func hadHighOrCriticalRiskInPast() -> Bool {
        let recent = checkInStore.checkIns.suffix(5)
        for checkIn in recent {
            let risk = RiskEngine.evaluate(
                journalText: checkIn.journalText ?? "",
                feelings: checkIn.feelings,
                mood: checkIn.moodRating,
                energy: checkIn.energyLevel,
                sleep: checkIn.sleepQuality,
                appetite: checkIn.appetiteLevel,
                anxiety: checkIn.anxietyLevel,
                interest: checkIn.interestLevel,
                hopelessness: checkIn.hopelessnessLevel,
                feelsSafe: checkIn.feelsSafe,
                hasHarmThoughts: checkIn.hasHarmThoughts,
                moodTrend: checkInStore.recentMoodTrend,
                userProfile: userProfile
            )
            if risk.level == .high || risk.level == .critical {
                return true
            }
        }
        return false
    }

    private func sendNudge(message: String) {
        print("Nudge sent: \(message)")
        // Future: Trigger local notification or in-app banner
    }
}
