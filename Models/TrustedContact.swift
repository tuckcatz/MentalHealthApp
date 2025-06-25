import Foundation

struct TrustedContact: Identifiable, Codable {
    var id: UUID
    var name: String
    var contactMethod: String
    var identifierNote: String?  // 🆕 Optional field for "your friend from soccer" etc.

    init(
        id: UUID = UUID(),
        name: String,
        contactMethod: String,
        identifierNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.contactMethod = contactMethod
        self.identifierNote = identifierNote
    }
}
