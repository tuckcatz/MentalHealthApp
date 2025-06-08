import Foundation
import SwiftUI

class AlertManager: ObservableObject {
    @Published var lastAlertedContacts: [TrustedContact] = []

    private let lifesaverStore: LifesaverStore

    init(lifesaverStore: LifesaverStore) {
        self.lifesaverStore = lifesaverStore
    }

    func sendAlert(to contacts: [TrustedContact], reason: String) {
        lastAlertedContacts = contacts

        for contact in contacts {
            // Placeholder for SMS/notification logic
            print("🚨 Alert sent to \(contact.name): \(reason)")
        }
    }

    /// Risk-based alert (triggered after a critical score)
    func sendAlerts(for risk: RiskScore) {
        let contacts = lifesaverStore.contacts
        let reason = """
        🚨 Risk Alert
        Score: \(risk.score)
        Triggers: \(risk.triggers.joined(separator: ", "))
        Please check in with your contact.
        """
        sendAlert(to: contacts, reason: reason)
    }

    /// Absence-based alert (e.g. missed 5 check-ins)
    func sendAbsenceAlert(missedDays: Int) {
        let contacts = lifesaverStore.contacts
        let reason = """
        🚨 Absence Alert
        Your contact has missed \(missedDays) consecutive check-ins.
        This could be a sign of withdrawal or distress. Please consider reaching out.
        """
        sendAlert(to: contacts, reason: reason)
    }
}
