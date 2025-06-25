import Foundation
import SwiftUI

class AlertManager: ObservableObject {
    @Published var lastAlertedContacts: [TrustedContact] = []

    private let lifesaverStore: LifesaverStore

    init(lifesaverStore: LifesaverStore) {
        self.lifesaverStore = lifesaverStore
    }

    /// 🔔 Called by RiskEngine when risk score is critical
    func sendAlerts(for risk: RiskScore) {
        let contacts = lifesaverStore.contacts

        sendAlert(to: contacts) { contact in
            var intro = "Hi – this is a quick heads up from the CheckIn app."
            if let note = contact.identifierNote, !note.isEmpty {
                intro += "\n\nThis is about your contact: \(note)."
            }

            return """
            \(intro)

            They flagged that they’re having a really tough day.
            You're listed as someone they trust.

            A simple check-in from you could mean a lot.
            """
        }
    }

    /// 🔔 Called when user has missed multiple check-ins
    func sendAbsenceAlert(missedDays: Int) {
        let contacts = lifesaverStore.contacts

        sendAlert(to: contacts) { contact in
            var intro = "Hi – this is a quick heads up from the CheckIn app."
            if let note = contact.identifierNote, !note.isEmpty {
                intro += "\n\nThis is about your contact: \(note)."
            }

            return """
            \(intro)

            They’ve missed \(missedDays) check-ins in a row – which could mean they’re having a hard time.
            You're listed as someone they trust.

            A simple check-in from you might go a long way.
            """
        }
    }

    /// 🔔 Called from MissedCheckInMonitor with flexible reason
    func sendMissedCheckInAlert(reason: String) {
        let contacts = lifesaverStore.contacts

        sendAlert(to: contacts) { contact in
            var intro = "Hi – this is a quick heads up from the CheckIn app."
            if let note = contact.identifierNote, !note.isEmpty {
                intro += "\n\nThis is about your contact: \(note)."
            }

            return """
            \(intro)

            We’re reaching out because they may need support right now.
            (\(reason))

            You're listed as someone they trust.

            A quick check-in from you could make a difference.
            """
        }
    }

    /// General alert dispatcher
    func sendAlert(to contacts: [TrustedContact], using messageBuilder: (TrustedContact) -> String) {
        lastAlertedContacts = contacts

        for contact in contacts {
            let message = messageBuilder(contact)
            sendSMSTo(contact: contact, message: message)
        }
    }

    /// Actual API call to your Vapor backend
    private func sendSMSTo(contact: TrustedContact, message: String) {
        guard let url = URL(string: "https://alertservice-r1i9.onrender.com/send-alert") else {
            print("❌ Invalid URL")
            return
        }

        let raw = contact.contactMethod
        let digitsOnly = raw.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard digitsOnly.count == 10 else {
            print("❌ Invalid phone number for \(contact.name): \(raw)")
            return
        }
        let formattedNumber = "+1\(digitsOnly)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "to": formattedNumber,
            "message": message
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to encode alert JSON for \(contact.name): \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Failed to send alert to \(contact.name): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Alert sent to \(contact.name)")
                } else {
                    print("⚠️ Server responded with status code \(httpResponse.statusCode) for \(contact.name)")
                }
            }
        }.resume()
    }
}
