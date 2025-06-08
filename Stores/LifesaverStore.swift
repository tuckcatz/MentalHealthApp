import Foundation
import SwiftUI

class LifesaverStore: ObservableObject {
    @Published var contacts: [TrustedContact] = []

    private let key = "savedContacts"

    init() {
        load()
    }

    func add(_ contact: TrustedContact) {
        contacts.append(contact)
        save()
    }

    func remove(atOffsets offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        save()
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TrustedContact].self, from: data) {
            contacts = decoded
        }
    }

    func clear() {
        contacts = []
        UserDefaults.standard.removeObject(forKey: key)
    }
}
