import Foundation
import SwiftUI

class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile? {
        didSet {
            saveProfile()
        }
    }

    private let key = "userProfileData"

    init() {
        loadProfile()
    }

    func setBaseline(
        mood: Int,
        energy: Int,
        sleep: Int,
        anxiety: Int,
        appetite: Int,
        interest: Int,
        hopelessness: Int,
        feelsSafe: Bool,
        hasHarmThoughts: Bool,
        hasTrustedContact: Bool,
        note: String?
    ) {
        profile = UserProfile(
            baselineMood: mood,
            baselineEnergy: energy,
            baselineSleep: sleep,
            baselineAnxiety: anxiety,
            baselineAppetite: appetite,
            baselineInterest: interest,
            baselineHopelessness: hopelessness,
            feelsSafe: feelsSafe,
            hasHarmThoughts: hasHarmThoughts,
            hasTrustedContact: hasTrustedContact,
            personalNote: note
        )
    }

    // MARK: - Accessors for RiskEngine (optional fallbacks)

    var baselineMood: Int { profile?.baselineMood ?? 5 }
    var baselineEnergy: Int { profile?.baselineEnergy ?? 5 }
    var baselineSleep: Int { profile?.baselineSleep ?? 5 }
    var baselineAnxiety: Int { profile?.baselineAnxiety ?? 5 }
    var baselineAppetite: Int { profile?.baselineAppetite ?? 5 }
    var baselineInterest: Int { profile?.baselineInterest ?? 5 }
    var baselineHopelessness: Int { profile?.baselineHopelessness ?? 5 }

    func saveProfile() {
        guard let profile = profile else { return }
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to save user profile: \(error)")
        }
    }

    func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            profile = try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("❌ Failed to load user profile: \(error)")
        }
    }

    func clearProfile() {
        profile = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
}
